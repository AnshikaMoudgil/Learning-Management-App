import { NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

// GET: List all profiles (Admin & SuperAdmin only)
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

    const [
      { data: { user }, error: authError },
      { data: allProfiles, error: listError },
    ] = await Promise.all([
      adminClient.auth.getUser(token),
      adminClient.from('profiles').select('id, full_name, email, role, status, created_at').order('created_at', { ascending: false }),
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

    return NextResponse.json({ profiles: allProfiles || [] });
  } catch (err: unknown) {
    return NextResponse.json({ error: err instanceof Error ? err.message : 'Server error' }, { status: 500 });
  }
}
