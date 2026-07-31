-- ============================================================
-- Migration: Course Renewal Plans
-- ============================================================

-- 1. Create the course_renewal_plans table
CREATE TABLE IF NOT EXISTS course_renewal_plans (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id       UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  label           TEXT NOT NULL,                      -- e.g. "3 Months"
  duration_value  INT NOT NULL CHECK (duration_value > 0),
  duration_unit   TEXT NOT NULL CHECK (duration_unit IN ('days', 'months', 'years')),
  price           NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
  sort_order      INT NOT NULL DEFAULT 0,
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_renewal_plans_course_id
  ON course_renewal_plans(course_id);

-- 2. Add renewal_plan_id to the payments table
ALTER TABLE payments
  ADD COLUMN IF NOT EXISTS renewal_plan_id UUID REFERENCES course_renewal_plans(id);

-- 3. Enable RLS on course_renewal_plans (read for authenticated, full for service role)
ALTER TABLE course_renewal_plans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow authenticated to read active plans"
  ON course_renewal_plans
  FOR SELECT
  TO authenticated
  USING (is_active = TRUE);

-- 4. Updated at trigger
CREATE OR REPLACE FUNCTION update_renewal_plan_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_renewal_plans_updated_at
  BEFORE UPDATE ON course_renewal_plans
  FOR EACH ROW EXECUTE FUNCTION update_renewal_plan_updated_at();

-- ============================================================
-- 5. Update the complete_payment_and_enroll RPC
--    to support validity stacking on renewal.
-- ============================================================

CREATE OR REPLACE FUNCTION complete_payment_and_enroll(
  p_order_id   TEXT,
  p_payment_id TEXT,
  p_signature  TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_payment         payments%ROWTYPE;
  v_plan            course_renewal_plans%ROWTYPE;
  v_enrollment      enrollments%ROWTYPE;
  v_new_validity    TIMESTAMPTZ;
  v_result          JSONB;
BEGIN
  -- Lock and fetch the pending payment
  SELECT * INTO v_payment
  FROM payments
  WHERE razorpay_order_id = p_order_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Payment order not found: %', p_order_id;
  END IF;

  IF v_payment.status = 'completed' THEN
    -- Idempotent: already processed
    RETURN jsonb_build_object('paymentId', v_payment.id, 'status', 'already_completed');
  END IF;

  IF v_payment.status <> 'pending' THEN
    RAISE EXCEPTION 'Payment is not in pending state: %', v_payment.status;
  END IF;

  -- Mark payment completed
  UPDATE payments
  SET
    status                = 'completed',
    razorpay_payment_id   = p_payment_id,
    razorpay_signature    = p_signature
  WHERE id = v_payment.id;

  -- ── Renewal path ──────────────────────────────────────────────
  IF v_payment.renewal_plan_id IS NOT NULL THEN
    SELECT * INTO v_plan
    FROM course_renewal_plans
    WHERE id = v_payment.renewal_plan_id;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'Renewal plan not found: %', v_payment.renewal_plan_id;
    END IF;

    -- Find the user's existing enrollment for this course
    SELECT * INTO v_enrollment
    FROM enrollments
    WHERE user_id = v_payment.user_id
      AND course_id = v_payment.course_id
    ORDER BY enrolled_at DESC
    LIMIT 1
    FOR UPDATE;

    -- Compute stacked validity:
    --   If current validity is still in the future → extend from there
    --   Otherwise → extend from NOW()
    DECLARE
      v_base TIMESTAMPTZ := GREATEST(NOW(), COALESCE(v_enrollment.validity_end_at, NOW()));
    BEGIN
      IF v_plan.duration_unit = 'days' THEN
        v_new_validity := v_base + (v_plan.duration_value || ' days')::INTERVAL;
      ELSIF v_plan.duration_unit = 'months' THEN
        v_new_validity := v_base + (v_plan.duration_value || ' months')::INTERVAL;
      ELSE  -- years
        v_new_validity := v_base + (v_plan.duration_value || ' years')::INTERVAL;
      END IF;
    END;

    IF FOUND THEN
      -- Update existing enrollment
      UPDATE enrollments
      SET
        validity_end_at = v_new_validity,
        status          = 'active'
      WHERE id = v_enrollment.id;
    ELSE
      -- No prior enrollment — create one (edge case)
      INSERT INTO enrollments (user_id, course_id, status, validity_end_at, enrolled_at)
      VALUES (v_payment.user_id, v_payment.course_id, 'active', v_new_validity, NOW());
    END IF;

    RETURN jsonb_build_object(
      'paymentId',       v_payment.id,
      'status',          'renewed',
      'newValidityEndAt', v_new_validity
    );
  END IF;

  -- ── Standard enrollment path (unchanged behaviour) ────────────
  IF EXISTS (
    SELECT 1 FROM enrollments
    WHERE user_id = v_payment.user_id
      AND course_id = v_payment.course_id
      AND status = 'active'
  ) THEN
    RAISE EXCEPTION 'already enrolled';
  END IF;

  INSERT INTO enrollments (user_id, course_id, status, enrolled_at)
  SELECT v_payment.user_id, pi.course_id, 'active', NOW()
  FROM payment_items pi
  WHERE pi.payment_id = v_payment.id
  ON CONFLICT (user_id, course_id) DO UPDATE
    SET status = 'active', enrolled_at = NOW();

  RETURN jsonb_build_object('paymentId', v_payment.id, 'status', 'enrolled');
END;
$$;
