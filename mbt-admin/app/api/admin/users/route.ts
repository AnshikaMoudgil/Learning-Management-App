import { NextResponse } from 'next/server';
import { getSupabaseAdmin } from '@/app/lib/supabaseClient';

// GET: List all profiles (Admin & SuperAdmin only)
export async function GET(request: Request) {
  try {
    const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY || '';

    if (!serviceRoleKey || serviceRoleKey === 'placeholder-service-key') {
      return NextResponse.json({ error: 'Service role key not configured.' }, { status: 500 });
    }

    const authHeader = request.headers.get('Authorization');
    if (!authHeader) {
      return NextResponse.json({ error: 'No authorization token provided.' }, { status: 401 });
    }

    const token = authHeader.replace('Bearer ', '');
    const adminClient = getSupabaseAdmin();

    const [
      { data: { user }, error: authError },
      { data: allProfiles, error: listError },
      { data: authUsers, error: authListError },
    ] = await Promise.all([
      adminClient.auth.getUser(token),
      adminClient.from('profiles').select('id, full_name, email, phone, role, status, created_at, allowed_sections, allowed_actions').order('created_at', { ascending: false }),
      adminClient.auth.admin.listUsers(),
    ]);

    if (authError || !user) {
      return NextResponse.json({ error: 'Invalid session.' }, { status: 401 });
    }

    if (listError) {
      console.error('Database query error in /api/admin/users:', listError);
      return NextResponse.json({ error: listError.message }, { status: 500 });
    }

    const callerProfile = (allProfiles || []).find((p) => p.id === user.id);
    const allowedRoles = ['admin', 'superadmin', 'instructor'];
    if (!callerProfile || !allowedRoles.includes(callerProfile.role)) {
      return NextResponse.json({ error: 'Access Denied.' }, { status: 403 });
    }

    const authUserMap = new Map((authUsers?.users || []).map((u: any) => [u.id, u]));

    const enrichedProfiles = (allProfiles || []).map((p) => {
      const authUser = authUserMap.get(p.id);
      const meta = authUser?.raw_app_meta_data || {};
      const providers: string[] = meta.providers || [];
      return {
        ...p,
        provider: providers[0] || 'email',
        last_sign_in_at: authUser?.last_sign_in_at || null,
      };
    });

    const response = NextResponse.json({ profiles: enrichedProfiles });
    response.headers.set('Cache-Control', 's-maxage=60, stale-while-revalidate=300');
    return response;
  } catch (err: unknown) {
    return NextResponse.json({ error: err instanceof Error ? err.message : 'Server error' }, { status: 500 });
  }
}
