import { NextResponse } from 'next/server';
import { getSupabaseAdmin } from '@/app/lib/supabaseClient';
import { validateCsrf } from '@/lib/csrf';

// Helper to authenticate the caller and get their role
async function checkCallerRole(request: Request) {
  const authHeader = request.headers.get('Authorization');
  if (!authHeader) return { error: 'No authorization token provided', role: null, userId: null };

  const token = authHeader.replace('Bearer ', '');
  const adminClient = getSupabaseAdmin();

  const { data: { user }, error: authError } = await adminClient.auth.getUser(token);
  if (authError || !user) {
    return { error: 'Invalid session token', role: null, userId: null };
  }

  const { data: profile, error: profileError } = await adminClient
    .from('profiles')
    .select('role')
    .eq('id', user.id)
    .single();

  if (profileError || !profile) {
    return { error: 'Caller profile not found', role: null, userId: null };
  }

  return { error: null, role: profile.role, userId: user.id };
}

// POST: Create / Invite a new user (SuperAdmin only)
export async function POST(request: Request) {
  try {
    const { error: authError, role: callerRole } = await checkCallerRole(request);
    if (authError) {
      return NextResponse.json({ error: authError }, { status: 401 });
    }

    const csrf = await validateCsrf(request);
    if (!csrf.valid) {
      return NextResponse.json({ error: csrf.error }, { status: 401 });
    }

    if (callerRole !== 'superadmin') {
      return NextResponse.json({ error: 'Access Denied: Only superadmins can invite users.' }, { status: 403 });
    }

    const { email, password, role, full_name } = await request.json();

    if (!email || !password || !role) {
      return NextResponse.json({ error: 'Email, password and role are required.' }, { status: 400 });
    }

    const adminClient = getSupabaseAdmin();

    // 1. Create user in auth.users
    const { data: authData, error: createError } = await adminClient.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: { full_name: full_name || 'Invited Staff' }
    });

    if (createError || !authData.user) {
      return NextResponse.json({ error: createError?.message || 'Failed to create user.' }, { status: 400 });
    }

    // 2. The handle_new_user trigger creates a profile automatically,
    // but we want to update their role to the invited role.
    const { error: updateError } = await adminClient
      .from('profiles')
      .update({ role, email, full_name: full_name || null })
      .eq('id', authData.user.id);

    if (updateError) {
      return NextResponse.json({ error: 'User invited but profile role setup failed.' }, { status: 500 });
    }

    return NextResponse.json({ success: true, user: authData.user });
  } catch (err: unknown) {
    return NextResponse.json({ error: err instanceof Error ? err.message : 'Server error' }, { status: 500 });
  }
}

// PATCH: Update user role / status (Admin & SuperAdmin)
export async function PATCH(request: Request) {
  try {
    const { error: authError, role: callerRole } = await checkCallerRole(request);
    if (authError) {
      return NextResponse.json({ error: authError }, { status: 401 });
    }

    const csrf = await validateCsrf(request);
    if (!csrf.valid) {
      return NextResponse.json({ error: csrf.error }, { status: 401 });
    }

    const { targetUserId, role, status, allowed_sections, allowed_actions } = await request.json();

    if (!targetUserId) {
      return NextResponse.json({ error: 'Target User ID is required.' }, { status: 400 });
    }

    // Role Promotion rule validations:
    // SuperAdmin can change role and status of any user.
    // Admin can change roles to Admin, SuperAdmin, or Instructor, but cannot suspend/delete users (which is restricted to SuperAdmins).
    if (callerRole !== 'superadmin' && callerRole !== 'admin') {
      return NextResponse.json({ error: 'Access Denied.' }, { status: 403 });
    }

    if (status && callerRole !== 'superadmin') {
      return NextResponse.json({ error: 'Access Denied: Only superadmins can suspend accounts.' }, { status: 403 });
    }

    if ((allowed_sections !== undefined || allowed_actions !== undefined) && callerRole !== 'superadmin') {
      return NextResponse.json({ error: 'Access Denied: Only superadmins can configure permissions.' }, { status: 403 });
    }

    const updatePayload: Record<string, any> = {};
    if (role) updatePayload.role = role;
    if (status) updatePayload.status = status;
    if (allowed_sections !== undefined) updatePayload.allowed_sections = allowed_sections;
    if (allowed_actions !== undefined) updatePayload.allowed_actions = allowed_actions;

    const adminClient = getSupabaseAdmin();
    const { error: updateError } = await adminClient
      .from('profiles')
      .update(updatePayload)
      .eq('id', targetUserId);

    if (updateError) {
      return NextResponse.json({ error: updateError.message }, { status: 400 });
    }

    return NextResponse.json({ success: true });
  } catch (err: unknown) {
    return NextResponse.json({ error: err instanceof Error ? err.message : 'Server error' }, { status: 500 });
  }
}
