-- ============================================================
-- Migration: LMS Course Details Restructure
-- Adds module linking to sessions/resources, lesson progress tracking
-- ============================================================

-- ============================================================
-- 1. Add section_id to sessions
--    Links a live class session to a specific module/section
-- ============================================================
ALTER TABLE public.sessions
    ADD COLUMN IF NOT EXISTS section_id UUID
        REFERENCES public.course_sections(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_sessions_section_id ON public.sessions(section_id);

-- ============================================================
-- 2. Add section_id to course_resources
--    Links a downloadable resource to a specific module/section
-- ============================================================
ALTER TABLE public.course_resources
    ADD COLUMN IF NOT EXISTS section_id UUID
        REFERENCES public.course_sections(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_course_resources_section_id ON public.course_resources(section_id);

-- ============================================================
-- 3. Add title and thumbnail_url to session_recordings
--    Allows displaying a human-readable name and preview image
-- ============================================================
ALTER TABLE public.session_recordings
    ADD COLUMN IF NOT EXISTS title        TEXT,
    ADD COLUMN IF NOT EXISTS thumbnail_url TEXT;

-- ============================================================
-- 4. Create user_lesson_progress table
--    Tracks per-user, per-lesson completion and watch position
-- ============================================================
CREATE TABLE IF NOT EXISTS public.user_lesson_progress (
    id              UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id         UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    course_id       UUID        NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    lesson_id       UUID        NOT NULL REFERENCES public.course_lessons(id) ON DELETE CASCADE,
    is_completed    BOOLEAN     NOT NULL DEFAULT FALSE,
    watched_seconds INTEGER     NOT NULL DEFAULT 0,
    last_watched_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_user_lesson_progress UNIQUE (user_id, lesson_id)
);

CREATE INDEX IF NOT EXISTS idx_ulp_user_course ON public.user_lesson_progress(user_id, course_id);
CREATE INDEX IF NOT EXISTS idx_ulp_lesson_id   ON public.user_lesson_progress(lesson_id);

ALTER TABLE public.user_lesson_progress ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE tablename = 'user_lesson_progress'
          AND policyname = 'Users can manage their own lesson progress'
    ) THEN
        CREATE POLICY "Users can manage their own lesson progress"
            ON public.user_lesson_progress FOR ALL
            USING (auth.uid() = user_id)
            WITH CHECK (auth.uid() = user_id);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE tablename = 'user_lesson_progress'
          AND policyname = 'Admins can read all lesson progress'
    ) THEN
        CREATE POLICY "Admins can read all lesson progress"
            ON public.user_lesson_progress FOR SELECT
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

DROP TRIGGER IF EXISTS set_ulp_updated_at ON public.user_lesson_progress;
CREATE TRIGGER set_ulp_updated_at
    BEFORE UPDATE ON public.user_lesson_progress
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ============================================================
-- 5. Auto-sync enrollment progress_percent
--    Fires whenever a lesson is marked complete / incomplete
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_sync_enrollment_progress()
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_sync_enrollment_progress ON public.user_lesson_progress;
CREATE TRIGGER trg_sync_enrollment_progress
    AFTER INSERT OR UPDATE OF is_completed
    ON public.user_lesson_progress
    FOR EACH ROW EXECUTE FUNCTION public.fn_sync_enrollment_progress();
