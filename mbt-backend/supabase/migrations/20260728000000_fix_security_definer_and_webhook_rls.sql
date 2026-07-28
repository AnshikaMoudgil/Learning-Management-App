-- ============================================================
-- Migration: Fix SECURITY DEFINER search_path + webhook_logs RLS
-- ============================================================

-- 1. Fix fn_sync_enrollment_progress: add SET search_path to
--    prevent search_path hijacking (SCHEMA-01)
CREATE OR REPLACE FUNCTION public.fn_sync_enrollment_progress()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_total INT;
    v_done  INT;
BEGIN
    SELECT COUNT(*) INTO v_total
    FROM public.course_lessons
    WHERE course_id = NEW.course_id;

    IF v_total > 0 THEN
        SELECT COUNT(*) INTO v_done
        FROM public.user_lesson_progress
        WHERE user_id   = NEW.user_id
          AND course_id = NEW.course_id
          AND is_completed = TRUE;

        UPDATE public.enrollments
        SET progress_percent = ROUND((v_done::FLOAT / v_total::FLOAT) * 100),
            updated_at       = NOW()
        WHERE user_id   = NEW.user_id
          AND course_id = NEW.course_id
          AND status    = 'active';
    END IF;

    RETURN NEW;
END;
$$;

-- 2. Fix webhook_logs RLS: add an admin-only SELECT policy
--    (SCHEMA-10 — table has RLS enabled but zero policies,
--     causing default-deny for any authenticated client)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE tablename = 'webhook_logs'
          AND policyname = 'Admins can read webhook logs'
    ) THEN
        CREATE POLICY "Admins can read webhook logs"
            ON public.webhook_logs FOR SELECT
            USING (
                EXISTS (
                    SELECT 1 FROM public.profiles
                    WHERE id = auth.uid()
                      AND role IN ('admin', 'superadmin')
                )
            );
    END IF;
END;
$$;
