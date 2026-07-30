import { NextResponse } from 'next/server';
import { getSupabaseAdmin } from '@/app/lib/supabaseClient';

export async function GET(request: Request) {
  try {
    const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY || '';
    if (!serviceRoleKey || serviceRoleKey === 'placeholder-service-key') {
      return NextResponse.json({ error: 'Internal server error.' }, { status: 500 });
    }

    const authHeader = request.headers.get('Authorization');
    if (!authHeader) {
      return NextResponse.json({ error: 'No authorization token.' }, { status: 401 });
    }

    const token = authHeader.replace('Bearer ', '');
    const adminClient = getSupabaseAdmin();

    const { data: { user }, error: authError } = await adminClient.auth.getUser(token);
    if (authError || !user) {
      return NextResponse.json({ error: 'Invalid session.' }, { status: 401 });
    }

    const { data, error } = await adminClient.rpc('get_dashboard_stats');

    if (error) {
      console.error('[Dashboard Stats API] RPC error:', error);
      return NextResponse.json({ error: error.message }, { status: 500 });
    }

    const response = NextResponse.json(data);
    response.headers.set('Cache-Control', 's-maxage=300, stale-while-revalidate=600');
    return response;
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : 'Server error';
    console.error('[Dashboard Stats API]', message, err);
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
