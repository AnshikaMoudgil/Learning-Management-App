-- ============================================================
-- Migration: Fix complete_payment_and_enroll regression
--
-- The renewal rewrite (20260731000000) accidentally dropped several
-- behaviors of the standard fulfillment path. This migration redefines
-- the RPC to preserve the renewal path AND restore:
--   - validity_end_at derived from courses.validity_days (with stacking
--     when an active enrollment already exists)
--   - coupon uses_count increment on fulfillment
--   - cart_items cleanup after purchase
--   - payment expiry check (expires_at <= NOW() -> expired)
--   - duplicate razorpay_payment_id check
--   - SET search_path for the SECURITY DEFINER function
--
-- NOTE: Uses SELECT ... FOR UPDATE + INSERT/UPDATE instead of
-- ON CONFLICT because enrollments only has a PARTIAL unique index
-- (user_id, course_id) WHERE status = 'active', which a plain
-- ON CONFLICT (user_id, course_id) target does not match.
-- ============================================================

CREATE OR REPLACE FUNCTION public.complete_payment_and_enroll(
  p_order_id   TEXT,
  p_payment_id TEXT,
  p_signature  TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_payment       public.payments%ROWTYPE;
  v_plan          public.course_renewal_plans%ROWTYPE;
  v_enrollment    public.enrollments%ROWTYPE;
  v_new_validity  TIMESTAMPTZ;
  v_base          TIMESTAMPTZ;
  v_item          RECORD;
  v_course        public.courses%ROWTYPE;
  v_coupon_rows   INTEGER;
  v_has_items     BOOLEAN;
  v_user_cart_id  UUID;
BEGIN
  -- Lock and fetch the pending payment
  SELECT * INTO v_payment
  FROM public.payments
  WHERE razorpay_order_id = p_order_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Payment order not found: %', p_order_id USING ERRCODE = 'P0002';
  END IF;

  IF v_payment.status = 'completed' THEN
    -- Idempotent: already processed
    RETURN jsonb_build_object('paymentId', v_payment.id, 'status', 'already_completed');
  END IF;

  IF v_payment.status <> 'pending' THEN
    RAISE EXCEPTION 'Payment is not in pending state: %', v_payment.status USING ERRCODE = 'P0001';
  END IF;

  IF v_payment.expires_at <= NOW() THEN
    UPDATE public.payments SET status = 'expired' WHERE id = v_payment.id;
    RAISE EXCEPTION 'Payment order expired' USING ERRCODE = 'P0001';
  END IF;

  -- Reject reused razorpay payment ids
  IF EXISTS (
    SELECT 1 FROM public.payments
    WHERE razorpay_payment_id = p_payment_id AND id <> v_payment.id
  ) THEN
    RAISE EXCEPTION 'Razorpay payment id already used' USING ERRCODE = '23505';
  END IF;

  -- Mark payment completed
  UPDATE public.payments
  SET
    status                = 'completed',
    razorpay_payment_id   = p_payment_id,
    razorpay_signature    = p_signature
  WHERE id = v_payment.id AND status = 'pending';

  IF NOT FOUND THEN
    RETURN jsonb_build_object('paymentId', v_payment.id, 'status', 'already_completed');
  END IF;

  -- ── Renewal path ──────────────────────────────────────────────
  IF v_payment.renewal_plan_id IS NOT NULL THEN
    SELECT * INTO v_plan
    FROM public.course_renewal_plans
    WHERE id = v_payment.renewal_plan_id;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'Renewal plan not found: %', v_payment.renewal_plan_id;
    END IF;

    -- Find the user's existing enrollment for this course
    SELECT * INTO v_enrollment
    FROM public.enrollments
    WHERE user_id = v_payment.user_id
      AND course_id = v_payment.course_id
    ORDER BY enrolled_at DESC
    LIMIT 1
    FOR UPDATE;

    -- Compute stacked validity:
    --   If current validity is still in the future -> extend from there
    --   Otherwise -> extend from NOW()
    v_base := GREATEST(NOW(), COALESCE(v_enrollment.validity_end_at, NOW()));

    IF v_plan.duration_unit = 'days' THEN
      v_new_validity := v_base + (v_plan.duration_value || ' days')::INTERVAL;
    ELSIF v_plan.duration_unit = 'months' THEN
      v_new_validity := v_base + (v_plan.duration_value || ' months')::INTERVAL;
    ELSE  -- years
      v_new_validity := v_base + (v_plan.duration_value || ' years')::INTERVAL;
    END IF;

    IF FOUND THEN
      -- Update existing enrollment
      UPDATE public.enrollments
      SET
        validity_end_at = v_new_validity,
        status          = 'active'
      WHERE id = v_enrollment.id;
    ELSE
      -- No prior enrollment — create one (edge case)
      INSERT INTO public.enrollments (user_id, course_id, status, validity_end_at, enrolled_at)
      VALUES (v_payment.user_id, v_payment.course_id, 'active', v_new_validity, NOW());
    END IF;

    RETURN jsonb_build_object(
      'paymentId',       v_payment.id,
      'status',          'renewed',
      'newValidityEndAt', v_new_validity
    );
  END IF;

  -- ── Standard enrollment path ──────────────────────────────────
  SELECT EXISTS(
    SELECT 1 FROM public.payment_items WHERE payment_id = v_payment.id
  ) INTO v_has_items;

  IF v_has_items THEN
    -- Grouped checkout: loop through payment_items
    FOR v_item IN
      SELECT * FROM public.payment_items WHERE payment_id = v_payment.id
    LOOP
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

      IF EXISTS (
        SELECT 1 FROM public.enrollments
        WHERE user_id = v_payment.user_id
          AND course_id = v_item.course_id
          AND status = 'active'
      ) THEN
        -- Already active: stack validity
        UPDATE public.enrollments
        SET status = 'active',
            validity_end_at = CASE WHEN v_course.validity_days IS NULL THEN validity_end_at
              ELSE GREATEST(COALESCE(validity_end_at, NOW()), NOW()) + make_interval(days => v_course.validity_days) END
        WHERE user_id = v_payment.user_id AND course_id = v_item.course_id;
      ELSE
        INSERT INTO public.enrollments (user_id, course_id, status, validity_end_at, enrolled_at, progress_percent)
        VALUES (
          v_payment.user_id,
          v_item.course_id,
          'active',
          CASE WHEN v_course.validity_days IS NULL THEN NULL ELSE NOW() + make_interval(days => v_course.validity_days) END,
          NOW(),
          0
        );
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
    -- Single course checkout
    SELECT * INTO v_course FROM public.courses WHERE id = v_payment.course_id FOR UPDATE;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Course not found: %', v_payment.course_id USING ERRCODE = 'P0002';
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

    IF EXISTS (
      SELECT 1 FROM public.enrollments
      WHERE user_id = v_payment.user_id
        AND course_id = v_payment.course_id
        AND status = 'active'
    ) THEN
      UPDATE public.enrollments
      SET status = 'active',
          validity_end_at = CASE WHEN v_course.validity_days IS NULL THEN validity_end_at
            ELSE GREATEST(COALESCE(validity_end_at, NOW()), NOW()) + make_interval(days => v_course.validity_days) END
      WHERE user_id = v_payment.user_id AND course_id = v_payment.course_id;
    ELSE
      INSERT INTO public.enrollments (user_id, course_id, status, validity_end_at, enrolled_at, progress_percent)
      VALUES (
        v_payment.user_id,
        v_payment.course_id,
        'active',
        CASE WHEN v_course.validity_days IS NULL THEN NULL ELSE NOW() + make_interval(days => v_course.validity_days) END,
        NOW(),
        0
      );
    END IF;
  END IF;

  RETURN jsonb_build_object('paymentId', v_payment.id, 'status', 'enrolled');
END;
$$;

REVOKE ALL ON FUNCTION public.complete_payment_and_enroll(TEXT, TEXT, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.complete_payment_and_enroll(TEXT, TEXT, TEXT) TO service_role;
