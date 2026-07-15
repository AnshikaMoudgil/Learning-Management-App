-- ============================================================
-- Migration: Cart tables, payment_items, grouped checkout RPC
-- ============================================================

-- 1. Cart tables
CREATE TABLE IF NOT EXISTS public.carts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.cart_items (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    cart_id UUID NOT NULL REFERENCES public.carts(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE (cart_id, course_id)
);

CREATE INDEX IF NOT EXISTS idx_cart_items_cart_id ON public.cart_items(cart_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_course_id ON public.cart_items(course_id);

ALTER TABLE public.carts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own cart" ON public.carts
    FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can manage own cart items" ON public.cart_items
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.carts WHERE carts.id = cart_items.cart_id AND carts.user_id = auth.uid())
    ) WITH CHECK (
        EXISTS (SELECT 1 FROM public.carts WHERE carts.id = cart_items.cart_id AND carts.user_id = auth.uid())
    );

DROP TRIGGER IF EXISTS set_carts_updated_at ON public.carts;
CREATE TRIGGER set_carts_updated_at
    BEFORE UPDATE ON public.carts
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- 2. Payment items for grouped checkout
ALTER TABLE public.payments ALTER COLUMN course_id DROP NOT NULL;

CREATE TABLE IF NOT EXISTS public.payment_items (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    payment_id UUID NOT NULL REFERENCES public.payments(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    coupon_id UUID REFERENCES public.coupons(id) ON DELETE SET NULL,
    base_amount NUMERIC(10,2) NOT NULL,
    discount_amount NUMERIC(10,2) DEFAULT 0.00 NOT NULL,
    amount_paid NUMERIC(10,2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_payment_items_payment_id ON public.payment_items(payment_id);
CREATE INDEX IF NOT EXISTS idx_payment_items_course_id ON public.payment_items(course_id);

ALTER TABLE public.payment_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own payment items" ON public.payment_items
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.payments p WHERE p.id = payment_items.payment_id AND p.user_id = auth.uid())
    );

-- 3. Updated complete_payment_and_enroll with grouped fulfillment
CREATE OR REPLACE FUNCTION public.complete_payment_and_enroll(
    p_order_id TEXT,
    p_payment_id TEXT,
    p_signature TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_payment public.payments%ROWTYPE;
    v_item RECORD;
    v_course public.courses%ROWTYPE;
    v_enrollment_id UUID;
    v_coupon_rows INTEGER;
    v_already_processed BOOLEAN := FALSE;
    v_user_cart_id UUID;
    v_has_items BOOLEAN;
BEGIN
    -- Lock parent payment
    SELECT * INTO v_payment FROM public.payments WHERE razorpay_order_id = p_order_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Payment order not found' USING ERRCODE = 'P0002';
    END IF;

    -- Return early if already completed
    IF v_payment.status = 'completed' THEN
        RETURN jsonb_build_object(
            'status', 'completed',
            'paymentId', v_payment.id,
            'alreadyProcessed', TRUE
        );
    END IF;

    IF v_payment.status <> 'pending' THEN
        RAISE EXCEPTION 'Payment is not pending' USING ERRCODE = 'P0001';
    END IF;

    IF v_payment.expires_at <= NOW() THEN
        UPDATE public.payments SET status = 'expired' WHERE id = v_payment.id;
        RAISE EXCEPTION 'Payment order expired' USING ERRCODE = 'P0001';
    END IF;

    -- Check for duplicate razorpay_payment_id
    IF EXISTS (
        SELECT 1 FROM public.payments
        WHERE razorpay_payment_id = p_payment_id AND id <> v_payment.id
    ) THEN
        RAISE EXCEPTION 'Razorpay payment id already used' USING ERRCODE = '23505';
    END IF;

    -- Complete parent payment
    UPDATE public.payments
    SET status = 'completed',
        razorpay_payment_id = p_payment_id,
        razorpay_signature = p_signature
    WHERE id = v_payment.id AND status = 'pending';

    IF NOT FOUND THEN
        v_already_processed := TRUE;
    END IF;

    IF NOT v_already_processed THEN
        -- Check if this payment has payment_items (grouped checkout)
        SELECT EXISTS(
            SELECT 1 FROM public.payment_items WHERE payment_id = v_payment.id
        ) INTO v_has_items;

        IF v_has_items THEN
            -- Grouped checkout: loop through payment_items
            FOR v_item IN SELECT * FROM public.payment_items WHERE payment_id = v_payment.id LOOP
                SELECT * INTO v_course FROM public.courses WHERE id = v_item.course_id FOR UPDATE;
                IF NOT FOUND THEN
                    RAISE EXCEPTION 'Course not found: %', v_item.course_id USING ERRCODE = 'P0002';
                END IF;

                IF v_item.coupon_id IS NOT NULL THEN
                    UPDATE public.coupons
                    SET uses_count = uses_count + 1
                    WHERE id = v_item.coupon_id AND (max_uses IS NULL OR uses_count < max_uses);

                    GET DIAGNOSTICS v_coupon_rows = ROW_COUNT;
                    IF v_coupon_rows = 0 THEN
                        RAISE EXCEPTION 'Coupon exhausted during fulfillment' USING ERRCODE = 'P0001';
                    END IF;
                END IF;

                SELECT id INTO v_enrollment_id FROM public.enrollments
                WHERE user_id = v_payment.user_id AND course_id = v_item.course_id AND status = 'active' FOR UPDATE;

                IF v_enrollment_id IS NULL THEN
                    INSERT INTO public.enrollments (user_id, course_id, status, validity_end_at, progress_percent)
                    VALUES (
                        v_payment.user_id,
                        v_item.course_id,
                        'active',
                        CASE WHEN v_course.validity_days IS NULL THEN NULL ELSE NOW() + make_interval(days => v_course.validity_days) END,
                        0
                    );
                ELSE
                    UPDATE public.enrollments
                    SET status = 'active',
                        validity_end_at = CASE WHEN v_course.validity_days IS NULL THEN validity_end_at
                            ELSE GREATEST(COALESCE(validity_end_at, NOW()), NOW()) + make_interval(days => v_course.validity_days) END
                    WHERE id = v_enrollment_id;
                END IF;
            END LOOP;

            -- Clear cart items for this payment
            SELECT id INTO v_user_cart_id FROM public.carts WHERE user_id = v_payment.user_id;
            IF v_user_cart_id IS NOT NULL THEN
                DELETE FROM public.cart_items
                WHERE cart_id = v_user_cart_id
                  AND course_id IN (SELECT course_id FROM public.payment_items WHERE payment_id = v_payment.id);
            END IF;
        ELSE
            -- Single course checkout (backward compatible)
            SELECT * INTO v_course FROM public.courses WHERE id = v_payment.course_id FOR UPDATE;
            IF NOT FOUND THEN
                RAISE EXCEPTION 'Course not found' USING ERRCODE = 'P0002';
            END IF;

            IF v_payment.coupon_id IS NOT NULL THEN
                UPDATE public.coupons
                SET uses_count = uses_count + 1
                WHERE id = v_payment.coupon_id AND (max_uses IS NULL OR uses_count < max_uses);

                GET DIAGNOSTICS v_coupon_rows = ROW_COUNT;
                IF v_coupon_rows = 0 THEN
                    RAISE EXCEPTION 'Coupon exhausted during fulfillment' USING ERRCODE = 'P0001';
                END IF;
            END IF;

            SELECT id INTO v_enrollment_id FROM public.enrollments
            WHERE user_id = v_payment.user_id AND course_id = v_payment.course_id AND status = 'active' FOR UPDATE;

            IF v_enrollment_id IS NULL THEN
                INSERT INTO public.enrollments (user_id, course_id, status, validity_end_at, progress_percent)
                VALUES (
                    v_payment.user_id,
                    v_payment.course_id,
                    'active',
                    CASE WHEN v_course.validity_days IS NULL THEN NULL ELSE NOW() + make_interval(days => v_course.validity_days) END,
                    0
                );
            ELSE
                UPDATE public.enrollments
                SET status = 'active',
                    validity_end_at = CASE WHEN v_course.validity_days IS NULL THEN validity_end_at
                        ELSE GREATEST(COALESCE(validity_end_at, NOW()), NOW()) + make_interval(days => v_course.validity_days) END
                WHERE id = v_enrollment_id;
            END IF;
        END IF;
    END IF;

    RETURN jsonb_build_object(
        'status', 'completed',
        'paymentId', v_payment.id,
        'alreadyProcessed', v_already_processed
    );
END;
$$;

REVOKE ALL ON FUNCTION public.complete_payment_and_enroll(TEXT, TEXT, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.complete_payment_and_enroll(TEXT, TEXT, TEXT) TO service_role;

-- 4. Helper: auto-create cart on first item insert
CREATE OR REPLACE FUNCTION public.ensure_cart_for_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.carts (user_id)
    VALUES (NEW.user_id)
    ON CONFLICT (user_id) DO NOTHING;
    RETURN NEW;
END;
$$;

-- 5. Function to get or create cart
CREATE OR REPLACE FUNCTION public.get_or_create_cart(p_user_id UUID)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_cart_id UUID;
BEGIN
    SELECT id INTO v_cart_id FROM public.carts WHERE user_id = p_user_id;
    IF v_cart_id IS NULL THEN
        INSERT INTO public.carts (user_id) VALUES (p_user_id) RETURNING id INTO v_cart_id;
    END IF;
    RETURN v_cart_id;
END;
$$;

REVOKE ALL ON FUNCTION public.get_or_create_cart(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_or_create_cart(UUID) TO service_role;
