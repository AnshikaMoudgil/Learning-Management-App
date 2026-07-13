import { NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

type AuthResult = { error: string; status: number } | { user: { id: string }; adminClient: any };

async function authorize(request: Request): Promise<AuthResult> {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || '';
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY || '';

  if (!serviceRoleKey || serviceRoleKey === 'placeholder-service-key') {
    return { error: 'Service role key not configured.', status: 500 };
  }

  const authHeader = request.headers.get('Authorization');
  if (!authHeader) {
    return { error: 'No authorization token provided.', status: 401 };
  }

  const token = authHeader.replace('Bearer ', '');
  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  const { data: { user }, error: authError } = await adminClient.auth.getUser(token);
  if (authError || !user) {
    return { error: 'Invalid session.', status: 401 };
  }

  const { data: callerProfile } = await adminClient
    .from('profiles')
    .select('role')
    .eq('id', user.id)
    .maybeSingle();

  if (!callerProfile || !['admin', 'superadmin'].includes(callerProfile.role)) {
    return { error: 'Access Denied.', status: 403 };
  }

  return { user, adminClient };
}

export async function GET(request: Request) {
  try {
    const auth = await authorize(request);
    if ('error' in auth) {
      return NextResponse.json({ error: auth.error }, { status: auth.status });
    }

    const { data: coupons, error } = await auth.adminClient
      .from('coupons')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 500 });
    }

    return NextResponse.json({ coupons: coupons || [] });
  } catch (err: unknown) {
    return NextResponse.json({ error: err instanceof Error ? err.message : 'Server error' }, { status: 500 });
  }
}

export async function POST(request: Request) {
  try {
    const auth = await authorize(request);
    if ('error' in auth) {
      return NextResponse.json({ error: auth.error }, { status: auth.status });
    }

    const body = await request.json();
    const { code, discount_type, discount_value, max_uses, min_purchase_amount, starts_at, expires_at, is_active } = body;

    if (!code?.trim()) {
      return NextResponse.json({ error: 'Coupon code is required.' }, { status: 400 });
    }

    if (!discount_type || !['percentage', 'fixed'].includes(discount_type)) {
      return NextResponse.json({ error: 'Discount type must be percentage or fixed.' }, { status: 400 });
    }

    if (discount_value === undefined || discount_value <= 0) {
      return NextResponse.json({ error: 'Discount value must be greater than 0.' }, { status: 400 });
    }

    const { data, error } = await auth.adminClient
      .from('coupons')
      .insert({
        code: code.trim().toUpperCase(),
        discount_type,
        discount_value,
        max_uses: max_uses ?? null,
        min_purchase_amount: min_purchase_amount ?? 0,
        starts_at: starts_at || null,
        expires_at: expires_at || null,
        is_active: is_active ?? true,
      })
      .select('*')
      .single();

    if (error) {
      if (error.code === '23505') {
        return NextResponse.json({ error: 'A coupon with this code already exists.' }, { status: 409 });
      }
      return NextResponse.json({ error: error.message }, { status: 500 });
    }

    return NextResponse.json({ coupon: data });
  } catch (err: unknown) {
    return NextResponse.json({ error: err instanceof Error ? err.message : 'Server error' }, { status: 500 });
  }
}

export async function PATCH(request: Request) {
  try {
    const auth = await authorize(request);
    if ('error' in auth) {
      return NextResponse.json({ error: auth.error }, { status: auth.status });
    }

    const body = await request.json();
    const { id, ...updates } = body;

    if (!id) {
      return NextResponse.json({ error: 'Coupon ID is required.' }, { status: 400 });
    }

    const allowedFields = ['code', 'discount_type', 'discount_value', 'max_uses', 'min_purchase_amount', 'starts_at', 'expires_at', 'is_active'];
    const sanitized: Record<string, unknown> = {};

    for (const field of allowedFields) {
      if (updates[field] !== undefined) {
        sanitized[field] = field === 'code' ? String(updates[field]).trim().toUpperCase() : updates[field];
      }
    }

    if (Object.keys(sanitized).length === 0) {
      return NextResponse.json({ error: 'No valid fields to update.' }, { status: 400 });
    }

    const { data, error } = await auth.adminClient
      .from('coupons')
      .update(sanitized)
      .eq('id', id)
      .select('*')
      .single();

    if (error) {
      if (error.code === '23505') {
        return NextResponse.json({ error: 'A coupon with this code already exists.' }, { status: 409 });
      }
      return NextResponse.json({ error: error.message }, { status: 500 });
    }

    return NextResponse.json({ coupon: data });
  } catch (err: unknown) {
    return NextResponse.json({ error: err instanceof Error ? err.message : 'Server error' }, { status: 500 });
  }
}
