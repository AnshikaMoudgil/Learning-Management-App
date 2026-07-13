import { NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

export async function GET(request: Request) {
  try {
    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || '';
    const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY || '';

    if (!serviceRoleKey || serviceRoleKey === 'placeholder-service-key') {
      return NextResponse.json({ error: 'Service role key not configured.' }, { status: 500 });
    }

    const authHeader = request.headers.get('Authorization');
    if (!authHeader) {
      return NextResponse.json({ error: 'No authorization token provided.' }, { status: 401 });
    }

    const token = authHeader.replace('Bearer ', '');
    const adminClient = createClient(supabaseUrl, serviceRoleKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    });

    const { data: { user }, error: authError } = await adminClient.auth.getUser(token);
    if (authError || !user) {
      return NextResponse.json({ error: 'Invalid session.' }, { status: 401 });
    }

    const { data: callerProfile } = await adminClient
      .from('profiles')
      .select('role')
      .eq('id', user.id)
      .maybeSingle();

    if (!callerProfile || !['admin', 'superadmin'].includes(callerProfile.role)) {
      return NextResponse.json({ error: 'Access Denied.' }, { status: 403 });
    }

    const url = new URL(request.url);
    const statusFilter = url.searchParams.get('status');

    let query = adminClient
      .from('payments')
      .select('*')
      .order('created_at', { ascending: false });

    if (statusFilter && ['pending', 'completed', 'failed', 'expired', 'refunded'].includes(statusFilter)) {
      query = query.eq('status', statusFilter);
    }

    const { data: payments, error } = await query;

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 500 });
    }

    const userIds = [...new Set((payments || []).map((p: any) => p.user_id).filter(Boolean))];
    const couponIds = [...new Set((payments || []).map((p: any) => p.coupon_id).filter(Boolean))];

    const [profilesResult, couponsResult] = await Promise.all([
      userIds.length > 0
        ? adminClient.from('profiles').select('id, full_name, email').in('id', userIds)
        : { data: [] },
      couponIds.length > 0
        ? adminClient.from('coupons').select('id, code, discount_type, discount_value').in('id', couponIds)
        : { data: [] },
    ]);

    const profilesMap = (profilesResult.data || []).reduce((acc: any, p: any) => {
      acc[p.id] = { full_name: p.full_name, email: p.email };
      return acc;
    }, {} as Record<string, { full_name: string | null; email: string | null }>);

    const couponsMap = (couponsResult.data || []).reduce((acc: any, c: any) => {
      acc[c.id] = { code: c.code, discount_type: c.discount_type, discount_value: c.discount_value };
      return acc;
    }, {} as Record<string, { code: string; discount_type: string; discount_value: number }>);

    const mergedPayments = (payments || []).map((p: any) => ({
      ...p,
      user: profilesMap[p.user_id] ?? null,
      coupon: p.coupon_id ? (couponsMap[p.coupon_id] ?? null) : null,
    }));

    return NextResponse.json({ payments: mergedPayments });
  } catch (err: unknown) {
    return NextResponse.json({ error: err instanceof Error ? err.message : 'Server error' }, { status: 500 });
  }
}
