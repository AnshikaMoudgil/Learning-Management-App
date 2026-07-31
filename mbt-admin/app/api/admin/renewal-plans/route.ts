import { NextResponse } from 'next/server';
import { getSupabaseAdmin } from '@/app/lib/supabaseClient';
import { validateCsrf } from '@/lib/csrf';

interface CallerProfile {
  role: string;
  allowed_sections: string[] | null;
  allowed_actions: string[] | null;
}

type AuthResult =
  | { error: string; status: number }
  | { user: { id: string }; adminClient: ReturnType<typeof getSupabaseAdmin>; callerProfile: CallerProfile };

async function authorize(request: Request): Promise<AuthResult> {
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY || '';
  if (!serviceRoleKey || serviceRoleKey === 'placeholder-service-key') {
    return { error: 'Internal server error.', status: 500 };
  }

  const authHeader = request.headers.get('Authorization');
  if (!authHeader) return { error: 'No authorization token provided.', status: 401 };

  const token = authHeader.replace('Bearer ', '');
  const adminClient = getSupabaseAdmin();

  const { data: { user }, error: authError } = await adminClient.auth.getUser(token);
  if (authError || !user) return { error: 'Invalid session.', status: 401 };

  const { data: callerProfile } = await adminClient
    .from('profiles')
    .select('role, allowed_sections, allowed_actions')
    .eq('id', user.id)
    .maybeSingle();

  const hasAccess = callerProfile && (
    callerProfile.role === 'superadmin' ||
    callerProfile.role === 'admin' ||
    (callerProfile.allowed_sections || []).includes('Manage Courses')
  );

  if (!hasAccess) return { error: 'Access Denied.', status: 403 };
  return { user, adminClient, callerProfile };
}

// GET /api/admin/renewal-plans?courseId=<uuid>
export async function GET(request: Request) {
  try {
    const auth = await authorize(request);
    if ('error' in auth) return NextResponse.json({ error: auth.error }, { status: auth.status });

    const { searchParams } = new URL(request.url);
    const courseId = searchParams.get('courseId');
    if (!courseId) return NextResponse.json({ error: 'courseId is required.' }, { status: 400 });

    const { data, error } = await auth.adminClient
      .from('course_renewal_plans')
      .select('*')
      .eq('course_id', courseId)
      .order('sort_order', { ascending: true });

    if (error) return NextResponse.json({ error: error.message }, { status: 500 });
    return NextResponse.json({ plans: data || [] });
  } catch (err: unknown) {
    return NextResponse.json({ error: err instanceof Error ? err.message : 'Server error' }, { status: 500 });
  }
}

// POST /api/admin/renewal-plans
export async function POST(request: Request) {
  try {
    const auth = await authorize(request);
    if ('error' in auth) return NextResponse.json({ error: auth.error }, { status: auth.status });

    const csrf = await validateCsrf(request);
    if (!csrf.valid) return NextResponse.json({ error: csrf.error }, { status: 401 });

    const body = await request.json();
    const { course_id, label, duration_value, duration_unit, price, sort_order, is_active } = body;

    if (!course_id) return NextResponse.json({ error: 'course_id is required.' }, { status: 400 });
    if (!label?.trim()) return NextResponse.json({ error: 'Label is required.' }, { status: 400 });
    if (!duration_value || duration_value <= 0) return NextResponse.json({ error: 'Duration value must be positive.' }, { status: 400 });
    if (!['days', 'months', 'years'].includes(duration_unit)) return NextResponse.json({ error: 'Duration unit must be days, months, or years.' }, { status: 400 });
    if (price === undefined || price < 0) return NextResponse.json({ error: 'Price must be >= 0.' }, { status: 400 });

    const { data, error } = await auth.adminClient
      .from('course_renewal_plans')
      .insert({
        course_id,
        label: label.trim(),
        duration_value: Number(duration_value),
        duration_unit,
        price: Number(price),
        sort_order: sort_order ?? 0,
        is_active: is_active ?? true,
      })
      .select('*')
      .single();

    if (error) return NextResponse.json({ error: error.message }, { status: 500 });
    return NextResponse.json({ plan: data }, { status: 201 });
  } catch (err: unknown) {
    return NextResponse.json({ error: err instanceof Error ? err.message : 'Server error' }, { status: 500 });
  }
}
