import { NextResponse } from 'next/server';
import { getSupabaseAdmin } from '@/app/lib/supabaseClient';

// Helper to authenticate caller
async function checkSuperAdmin(request: Request) {
  const authHeader = request.headers.get('Authorization');
  if (!authHeader) return false;

  const token = authHeader.replace('Bearer ', '');
  const adminClient = getSupabaseAdmin();

  const { data: { user }, error: authError } = await adminClient.auth.getUser(token);
  if (authError || !user) return false;

  const { data: profile, error: profileError } = await adminClient
    .from('profiles')
    .select('role')
    .eq('id', user.id)
    .single();

  if (profileError || !profile) return false;
  return profile.role === 'superadmin';
}

// DELETE: Delete a user from auth.users (SuperAdmin only)
export async function DELETE(request: Request, { params }: { params: Promise<{ id: string }> }) {
  try {
    const isSuperAdmin = await checkSuperAdmin(request);
    if (!isSuperAdmin) {
      return NextResponse.json({ error: 'Access Denied: Only superadmins can delete users.' }, { status: 403 });
    }

    const { id: targetUserId } = await params;

    if (!targetUserId) {
      return NextResponse.json({ error: 'Target User ID is required.' }, { status: 400 });
    }

    const adminClient = getSupabaseAdmin();
    
    // Delete from auth.users (this cascades to profiles and other related data)
    const { error: deleteError } = await adminClient.auth.admin.deleteUser(targetUserId);

    if (deleteError) {
      return NextResponse.json({ error: deleteError.message }, { status: 400 });
    }

    return NextResponse.json({ success: true });
  } catch (err: unknown) {
    return NextResponse.json({ error: err instanceof Error ? err.message : 'Server error' }, { status: 500 });
  }
}
