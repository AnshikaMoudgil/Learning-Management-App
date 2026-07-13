-- ============================================================
-- Migration: Payments, coupons, enrollments, resources, webhooks
-- ============================================================

CREATE TABLE IF NOT EXISTS public.coupons (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    code TEXT NOT NULL,
    discount_type TEXT NOT NULL CHECK (discount_type IN ('percentage', 'fixed')),
    discount_value NUMERIC(10,2) NOT NULL CHECK (discount_value > 0),
    max_uses INTEGER CHECK (max_uses IS NULL OR max_uses >= 0),
    uses_count INTEGER DEFAULT 0 NOT NULL CHECK (uses_count >= 0),
    min_purchase_amount NUMERIC(10,2) DEFAULT 0.00 NOT NULL CHECK (min_purchase_amount >= 0),
    starts_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    CHECK (expires_at IS NULL OR starts_at IS NULL OR expires_at > starts_at)
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_coupons_code_upper ON public.coupons (UPPER(code));
CREATE INDEX IF NOT EXISTS idx_coupons_active ON public.coupons(is_active);

CREATE TABLE IF NOT EXISTS public.enrollments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'active' NOT NULL CHECK (status IN ('active', 'expired', 'refunded')),
    validity_end_at TIMESTAMPTZ,
    progress_percent INTEGER DEFAULT 0 NOT NULL CHECK (progress_percent >= 0 AND progress_percent <= 100),
    enrolled_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_enrollments_active_user_course
    ON public.enrollments(user_id, course_id)
    WHERE status = 'active';
CREATE INDEX IF NOT EXISTS idx_enrollments_user_id ON public.enrollments(user_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_course_id ON public.enrollments(course_id);

CREATE TABLE IF NOT EXISTS public.payments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    coupon_id UUID REFERENCES public.coupons(id) ON DELETE SET NULL,
    base_amount NUMERIC(10,2) NOT NULL CHECK (base_amount >= 0),
    discount_amount NUMERIC(10,2) DEFAULT 0.00 NOT NULL CHECK (discount_amount >= 0),
    amount_paid NUMERIC(10,2) NOT NULL CHECK (amount_paid >= 0),
    amount_subunits INTEGER NOT NULL CHECK (amount_subunits >= 0),
    currency TEXT DEFAULT 'INR' NOT NULL,
    razorpay_order_id TEXT NOT NULL,
    razorpay_payment_id TEXT,
    razorpay_signature TEXT,
    status TEXT DEFAULT 'pending' NOT NULL CHECK (status IN ('pending', 'completed', 'failed', 'expired', 'refunded')),
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_payments_razorpay_order_id ON public.payments(razorpay_order_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_payments_razorpay_payment_id
    ON public.payments(razorpay_payment_id)
    WHERE razorpay_payment_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_payments_user_course_status
    ON public.payments(user_id, course_id, status, expires_at);

CREATE TABLE IF NOT EXISTS public.course_resources (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    file_url TEXT NOT NULL,
    file_size TEXT,
    file_type TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_course_resources_course_id ON public.course_resources(course_id);

CREATE TABLE IF NOT EXISTS public.webhook_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    razorpay_event_id TEXT,
    razorpay_order_id TEXT,
    razorpay_payment_id TEXT,
    event_type TEXT NOT NULL,
    payload JSONB NOT NULL,
    signature_verified BOOLEAN DEFAULT FALSE NOT NULL,
    processed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_webhook_logs_razorpay_event_id
    ON public.webhook_logs(razorpay_event_id)
    WHERE razorpay_event_id IS NOT NULL;

CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_coupons_updated_at ON public.coupons;
CREATE TRIGGER set_coupons_updated_at
    BEFORE UPDATE ON public.coupons
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS set_enrollments_updated_at ON public.enrollments;
CREATE TRIGGER set_enrollments_updated_at
    BEFORE UPDATE ON public.enrollments
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS set_payments_updated_at ON public.payments;
CREATE TRIGGER set_payments_updated_at
    BEFORE UPDATE ON public.payments
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS set_course_resources_updated_at ON public.course_resources;
CREATE TRIGGER set_course_resources_updated_at
    BEFORE UPDATE ON public.course_resources
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.coupons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.course_resources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.webhook_logs ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'coupons' AND policyname = 'Authenticated users can read active coupons') THEN
        CREATE POLICY "Authenticated users can read active coupons"
            ON public.coupons FOR SELECT
            USING (
                auth.uid() IS NOT NULL
                AND is_active = TRUE
                AND (starts_at IS NULL OR starts_at <= NOW())
                AND (expires_at IS NULL OR expires_at > NOW())
            );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'coupons' AND policyname = 'Admins can manage coupons') THEN
        CREATE POLICY "Admins can manage coupons"
            ON public.coupons FOR ALL
            USING (
                EXISTS (
                    SELECT 1 FROM public.profiles
                    WHERE id = auth.uid()
                    AND role IN ('admin', 'superadmin')
                )
            )
            WITH CHECK (
                EXISTS (
                    SELECT 1 FROM public.profiles
                    WHERE id = auth.uid()
                    AND role IN ('admin', 'superadmin')
                )
            );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'enrollments' AND policyname = 'Users can read own enrollments') THEN
        CREATE POLICY "Users can read own enrollments"
            ON public.enrollments FOR SELECT
            USING (user_id = auth.uid());
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'payments' AND policyname = 'Users can read own payments') THEN
        CREATE POLICY "Users can read own payments"
            ON public.payments FOR SELECT
            USING (user_id = auth.uid());
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'course_resources' AND policyname = 'Enrolled users can read course resources') THEN
        CREATE POLICY "Enrolled users can read course resources"
            ON public.course_resources FOR SELECT
            USING (
                EXISTS (
                    SELECT 1 FROM public.enrollments e
                    WHERE e.course_id = course_resources.course_id
                    AND e.user_id = auth.uid()
                    AND e.status = 'active'
                    AND (e.validity_end_at IS NULL OR e.validity_end_at > NOW())
                )
            );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'course_resources' AND policyname = 'Admins and instructors can manage course resources') THEN
        CREATE POLICY "Admins and instructors can manage course resources"
            ON public.course_resources FOR ALL
            USING (
                EXISTS (
                    SELECT 1 FROM public.profiles
                    WHERE id = auth.uid()
                    AND role IN ('admin', 'superadmin', 'instructor')
                )
            )
            WITH CHECK (
                EXISTS (
                    SELECT 1 FROM public.profiles
                    WHERE id = auth.uid()
                    AND role IN ('admin', 'superadmin', 'instructor')
                )
            );
    END IF;
END;
$$;

DROP POLICY IF EXISTS "Authenticated users can read course lessons" ON public.course_lessons;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'course_lessons' AND policyname = 'Users can read preview or enrolled lessons') THEN
        CREATE POLICY "Users can read preview or enrolled lessons"
            ON public.course_lessons FOR SELECT
            USING (
                auth.uid() IS NOT NULL
                AND (
                    is_free_preview = TRUE
                    OR EXISTS (
                        SELECT 1 FROM public.enrollments e
                        WHERE e.course_id = course_lessons.course_id
                        AND e.user_id = auth.uid()
                        AND e.status = 'active'
                        AND (e.validity_end_at IS NULL OR e.validity_end_at > NOW())
                    )
                )
            );
    END IF;
END;
$$;

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
    v_course public.courses%ROWTYPE;
    v_enrollment_id UUID;
    v_coupon_rows INTEGER := 0;
    v_already_processed BOOLEAN := FALSE;
BEGIN
    SELECT *
    INTO v_payment
    FROM public.payments
    WHERE razorpay_order_id = p_order_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Payment order not found' USING ERRCODE = 'P0002';
    END IF;

    IF v_payment.status = 'completed' THEN
        SELECT id
        INTO v_enrollment_id
        FROM public.enrollments
        WHERE user_id = v_payment.user_id
          AND course_id = v_payment.course_id
          AND status = 'active'
        LIMIT 1;

        RETURN jsonb_build_object(
            'status', 'completed',
            'paymentId', v_payment.id,
            'enrollmentId', v_enrollment_id,
            'alreadyProcessed', TRUE
        );
    END IF;

    IF v_payment.status <> 'pending' THEN
        RAISE EXCEPTION 'Payment is not pending' USING ERRCODE = 'P0001';
    END IF;

    IF v_payment.expires_at <= NOW() THEN
        UPDATE public.payments
        SET status = 'expired'
        WHERE id = v_payment.id;
        RAISE EXCEPTION 'Payment order expired' USING ERRCODE = 'P0001';
    END IF;

    IF EXISTS (
        SELECT 1 FROM public.payments
        WHERE razorpay_payment_id = p_payment_id
          AND id <> v_payment.id
    ) THEN
        RAISE EXCEPTION 'Razorpay payment id already used' USING ERRCODE = '23505';
    END IF;

    SELECT *
    INTO v_course
    FROM public.courses
    WHERE id = v_payment.course_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Course not found' USING ERRCODE = 'P0002';
    END IF;

    UPDATE public.payments
    SET status = 'completed',
        razorpay_payment_id = p_payment_id,
        razorpay_signature = p_signature
    WHERE id = v_payment.id
      AND status = 'pending';

    IF NOT FOUND THEN
        v_already_processed := TRUE;
    END IF;

    IF v_payment.coupon_id IS NOT NULL AND NOT v_already_processed THEN
        UPDATE public.coupons
        SET uses_count = uses_count + 1
        WHERE id = v_payment.coupon_id
          AND (max_uses IS NULL OR uses_count < max_uses);

        GET DIAGNOSTICS v_coupon_rows = ROW_COUNT;

        IF v_coupon_rows = 0 THEN
            RAISE EXCEPTION 'Coupon exhausted during fulfillment' USING ERRCODE = 'P0001';
        END IF;
    END IF;

    SELECT id
    INTO v_enrollment_id
    FROM public.enrollments
    WHERE user_id = v_payment.user_id
      AND course_id = v_payment.course_id
      AND status = 'active'
    FOR UPDATE;

    IF v_enrollment_id IS NULL THEN
        INSERT INTO public.enrollments (
            user_id,
            course_id,
            status,
            validity_end_at,
            progress_percent
        )
        VALUES (
            v_payment.user_id,
            v_payment.course_id,
            'active',
            CASE
                WHEN v_course.validity_days IS NULL THEN NULL
                ELSE NOW() + make_interval(days => v_course.validity_days)
            END,
            0
        )
        RETURNING id INTO v_enrollment_id;
    ELSE
        UPDATE public.enrollments
        SET status = 'active',
            validity_end_at = CASE
                WHEN v_course.validity_days IS NULL THEN validity_end_at
                ELSE GREATEST(COALESCE(validity_end_at, NOW()), NOW()) + make_interval(days => v_course.validity_days)
            END
        WHERE id = v_enrollment_id;
    END IF;

    RETURN jsonb_build_object(
        'status', 'completed',
        'paymentId', v_payment.id,
        'enrollmentId', v_enrollment_id,
        'alreadyProcessed', v_already_processed
    );
END;
$$;

REVOKE ALL ON FUNCTION public.complete_payment_and_enroll(TEXT, TEXT, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.complete_payment_and_enroll(TEXT, TEXT, TEXT) TO service_role;
