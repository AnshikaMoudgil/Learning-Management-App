import { NextResponse } from 'next/server';
import { getSupabaseAdmin } from '@/app/lib/supabaseClient';
import { validateCsrf } from '@/lib/csrf';

export async function GET(request: Request) {
  try {
    const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY || '';

    if (!serviceRoleKey || serviceRoleKey === 'placeholder-service-key') {
      return NextResponse.json({ error: 'Internal server error.' }, { status: 500 });
    }

    const authHeader = request.headers.get('Authorization');
    if (!authHeader) {
      return NextResponse.json({ error: 'No authorization token provided.' }, { status: 401 });
    }

    const token = authHeader.replace('Bearer ', '');
    const adminClient = getSupabaseAdmin();

    const { data: { user }, error: authError } = await adminClient.auth.getUser(token);
    if (authError || !user) {
      return NextResponse.json({ error: 'Invalid session.' }, { status: 401 });
    }

    const { data: callerProfile } = await adminClient
      .from('profiles')
      .select('role, allowed_sections')
      .eq('id', user.id)
      .maybeSingle();

    const hasAccess = callerProfile && (
      callerProfile.role === 'superadmin' ||
      callerProfile.role === 'admin' ||
      (callerProfile.allowed_sections || []).includes('Device Requests')
    );

    if (!hasAccess) {
      return NextResponse.json({ error: 'Access Denied.' }, { status: 403 });
    }

    const url = new URL(request.url);
    const page = Math.max(1, parseInt(url.searchParams.get('page') || '1'));
    const limit = Math.min(50, Math.max(1, parseInt(url.searchParams.get('limit') || '20')));
    const from = (page - 1) * limit;
    const to = from + limit - 1;

    const { data: requests, count: totalCount, error: listError } = await adminClient
      .from('device_change_requests')
      .select('*', { count: 'exact' })
      .order('created_at', { ascending: false })
      .range(from, to);

    if (listError) {
      return NextResponse.json({ error: listError.message }, { status: 500 });
    }

    const userIds = [...new Set((requests || []).map((r: { user_id: string }) => r.user_id).filter(Boolean))];
    const reviewerIds = [...new Set((requests || []).map((r: { reviewed_by: string }) => r.reviewed_by).filter(Boolean))];
    const profileIds = [...new Set([...userIds, ...reviewerIds])];

    let profilesMap: Record<string, { full_name: string | null; email: string | null }> = {};

    if (profileIds.length > 0) {
      const { data: profiles } = await adminClient
        .from('profiles')
        .select('id, full_name, email')
        .in('id', profileIds);

      profilesMap = (profiles || []).reduce((acc, p) => {
        acc[p.id] = { full_name: p.full_name, email: p.email };
        return acc;
      }, {} as Record<string, { full_name: string | null; email: string | null }>);
    }

    const mergedRequests = (requests || []).map((req: { user_id: string; reviewed_by: string | null } & Record<string, unknown>) => ({
      ...req,
      user: profilesMap[req.user_id] ?? null,
      reviewer: req.reviewed_by ? (profilesMap[req.reviewed_by] ?? null) : null,
    }));

    const response = NextResponse.json({ requests: mergedRequests, total: totalCount, page, limit });
    response.headers.set('Cache-Control', 's-maxage=300, stale-while-revalidate=600');
    return response;
  } catch (err: unknown) {
    return NextResponse.json({ error: err instanceof Error ? err.message : 'Server error' }, { status: 500 });
  }
}

export async function PATCH(request: Request) {
  try {
    const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY || '';

    if (!serviceRoleKey || serviceRoleKey === 'placeholder-service-key') {
      return NextResponse.json({ error: 'Internal server error.' }, { status: 500 });
    }

    const authHeader = request.headers.get('Authorization');
    if (!authHeader) {
      return NextResponse.json({ error: 'No authorization token provided.' }, { status: 401 });
    }

    const token = authHeader.replace('Bearer ', '');
    const adminClient = getSupabaseAdmin();

    const { data: { user }, error: authError } = await adminClient.auth.getUser(token);
    if (authError || !user) {
      return NextResponse.json({ error: 'Invalid session.' }, { status: 401 });
    }

    const csrf = await validateCsrf(request);
    if (!csrf.valid) {
      return NextResponse.json({ error: csrf.error }, { status: 401 });
    }

    const { data: callerProfile } = await adminClient
      .from('profiles')
      .select('role, allowed_sections, allowed_actions')
      .eq('id', user.id)
      .maybeSingle();

    const hasAccess = callerProfile && (
      callerProfile.role === 'superadmin' ||
      callerProfile.role === 'admin' ||
      (callerProfile.allowed_actions || []).includes('Accept / Reject Device Requests') ||
      (callerProfile.allowed_sections || []).includes('Device Requests')
    );

    if (!hasAccess) {
      return NextResponse.json({ error: 'Access Denied.' }, { status: 403 });
    }

    const body = await request.json();
    const { requestId, status } = body;

    if (!requestId || !['approved', 'rejected'].includes(status)) {
      return NextResponse.json({ error: 'Invalid requestId or status.' }, { status: 400 });
    }

    const { data: changeRequest, error: fetchError } = await adminClient
      .from('device_change_requests')
      .select('*')
      .eq('id', requestId)
      .maybeSingle();

    if (fetchError || !changeRequest) {
      return NextResponse.json({ error: 'Request not found.' }, { status: 404 });
    }

    const { error: updateError } = await adminClient
      .from('device_change_requests')
      .update({
        status,
        reviewed_by: user.id,
        reviewed_at: new Date().toISOString(),
      })
      .eq('id', requestId);

    if (updateError) {
      return NextResponse.json({ error: updateError.message }, { status: 500 });
    }

    // If approved, deactivate old device and update the cooldown
    if (status === 'approved') {
      const userId = changeRequest.user_id;
      const newFingerprint = changeRequest.new_fingerprint;

      // Deactivate current active device
      await adminClient
        .from('devices')
        .update({ is_active: false })
        .eq('user_id', userId)
        .eq('is_active', true);

      // Upsert new device
      const { error: upsertError } = await adminClient
        .from('devices')
        .upsert({
          user_id: userId,
          fingerprint: newFingerprint,
          is_active: true,
        }, { onConflict: 'user_id,fingerprint' });

      if (upsertError) {
        console.error('Failed to upsert new device:', upsertError);
      }

    }

    return NextResponse.json({ success: true, status });
  } catch (err: unknown) {
    return NextResponse.json({ error: err instanceof Error ? err.message : 'Server error' }, { status: 500 });
  }
}
