import { NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

// GET: Fetch dashboard stats using service role (bypasses RLS)
export async function GET(request: Request) {
  try {
    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || '';
    const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY || '';
    const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || '';

    if (!serviceRoleKey || serviceRoleKey === 'placeholder-service-key') {
      return NextResponse.json({ error: 'Service role key not configured.' }, { status: 500 });
    }

    // 1. Verify caller token
    const authHeader = request.headers.get('Authorization');
    if (!authHeader) {
      return NextResponse.json({ error: 'No authorization token.' }, { status: 401 });
    }

    const token = authHeader.replace('Bearer ', '');
    const callerClient = createClient(supabaseUrl, anonKey, { auth: { persistSession: false } });
    const { data: { user }, error: authError } = await callerClient.auth.getUser(token);
    if (authError || !user) {
      return NextResponse.json({ error: 'Invalid session.' }, { status: 401 });
    }

    // 2. Use service role to count
    const adminClient = createClient(supabaseUrl, serviceRoleKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    });

    const [
      { count: totalCourses },
      { count: publishedCourses },
      { count: totalLearners },
      { count: totalStaff },
    ] = await Promise.all([
      adminClient.from('courses').select('*', { count: 'exact', head: true }),
      adminClient.from('courses').select('*', { count: 'exact', head: true }).eq('is_published', true),
      adminClient.from('profiles').select('*', { count: 'exact', head: true }).eq('role', 'learner'),
      adminClient.from('profiles').select('*', { count: 'exact', head: true }).in('role', ['admin', 'superadmin', 'instructor']),
    ]);

    return NextResponse.json({
      totalCourses: totalCourses || 0,
      publishedCourses: publishedCourses || 0,
      totalLearners: totalLearners || 0,
      totalStaff: totalStaff || 0,
    });
  } catch (err: any) {
    return NextResponse.json({ error: err.message || 'Server error' }, { status: 500 });
  }
}
