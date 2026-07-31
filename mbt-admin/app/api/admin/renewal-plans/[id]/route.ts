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

// PATCH /api/admin/renewal-plans/[id]
export async function PATCH(
  request: Request,
  { params }: { params: Promise<{ id: string }> },
) {
  try {
    const { id } = await params;
    const auth = await authorize(request);
    if ('error' in auth) return NextResponse.json({ error: auth.error }, { status: auth.status });

    const csrf = await validateCsrf(request);
    if (!csrf.valid) return NextResponse.json({ error: csrf.error }, { status: 401 });

    const body = await request.json();
    const allowedFields = ['label', 'duration_value', 'duration_unit', 'price', 'sort_order', 'is_active'];
    const sanitized: Record<string, unknown> = {};

    for (const field of allowedFields) {
      if (body[field] !== undefined) {
        sanitized[field] = body[field];
      }
    }

    if (sanitized.duration_unit && !['days', 'months', 'years'].includes(sanitized.duration_unit as string)) {
      return NextResponse.json({ error: 'Duration unit must be days, months, or years.' }, { status: 400 });
    }

    if (Object.keys(sanitized).length === 0) {
      return NextResponse.json({ error: 'No valid fields to update.' }, { status: 400 });
    }

    const { data, error } = await auth.adminClient
      .from('course_renewal_plans')
      .update(sanitized)
      .eq('id', id)
      .select('*')
      .single();

    if (error) return NextResponse.json({ error: error.message }, { status: 500 });
    return NextResponse.json({ plan: data });
  } catch (err: unknown) {
    return NextResponse.json({ error: err instanceof Error ? err.message : 'Server error' }, { status: 500 });
  }
}

// DELETE /api/admin/renewal-plans/[id]
export async function DELETE(
  request: Request,
  { params }: { params: Promise<{ id: string }> },
) {
  try {
    const { id } = await params;
    const auth = await authorize(request);
    if ('error' in auth) return NextResponse.json({ error: auth.error }, { status: auth.status });

    const csrf = await validateCsrf(request);
    if (!csrf.valid) return NextResponse.json({ error: csrf.error }, { status: 401 });

    const { error } = await auth.adminClient
      .from('course_renewal_plans')
      .delete()
      .eq('id', id);

    if (error) return NextResponse.json({ error: error.message }, { status: 500 });
    return NextResponse.json({ success: true });
  } catch (err: unknown) {
    return NextResponse.json({ error: err instanceof Error ? err.message : 'Server error' }, { status: 500 });
  }
}
