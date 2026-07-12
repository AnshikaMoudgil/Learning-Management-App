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

    // 1. Verify caller is authenticated and has an allowed role
    const authHeader = request.headers.get('Authorization');
    if (!authHeader) {
      return NextResponse.json({ error: 'No authorization token provided.' }, { status: 401 });
    }

    const token = authHeader.replace('Bearer ', '');
    const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || '';
    const callerClient = createClient(supabaseUrl, anonKey, { auth: { persistSession: false } });

    const { data: { user }, error: authError } = await callerClient.auth.getUser(token);
    if (authError || !user) {
      return NextResponse.json({ error: 'Invalid session.' }, { status: 401 });
    }

    // 2. Use service role client to get caller role
    const adminClient = createClient(supabaseUrl, serviceRoleKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    });

    const { data: callerProfile, error: profileError } = await adminClient
      .from('profiles')
      .select('role')
      .eq('id', user.id)
      .single();

    if (profileError || !callerProfile) {
      return NextResponse.json({ error: 'Caller profile not found.' }, { status: 403 });
    }

    const allowedRoles = ['admin', 'superadmin', 'instructor'];
    if (!allowedRoles.includes(callerProfile.role)) {
      return NextResponse.json({ error: 'Access Denied.' }, { status: 403 });
    }

    // 3. Fetch all profiles using service role (bypasses RLS)
    const { data: profiles, error: listError } = await adminClient
      .from('profiles')
      .select('id, full_name, email, role, status, created_at')
      .order('created_at', { ascending: false });

    if (listError) {
      console.error('Database query error in /api/admin/users:', listError);
      return NextResponse.json({ error: listError.message }, { status: 500 });
    }

    return NextResponse.json({ profiles: profiles || [] });
  } catch (err: any) {
    return NextResponse.json({ error: err.message || 'Server error' }, { status: 500 });
  }
}
