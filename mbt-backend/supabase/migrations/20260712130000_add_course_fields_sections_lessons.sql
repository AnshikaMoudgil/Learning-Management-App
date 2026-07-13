-- ============================================================
-- Migration: Add missing course fields + course_sections + course_lessons
-- Schema only (no seed data)
-- ============================================================

-- 1. Add missing columns to courses table
ALTER TABLE public.courses
    ADD COLUMN IF NOT EXISTS instructor_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS average_rating NUMERIC(2,1) DEFAULT 0.0,
    ADD COLUMN IF NOT EXISTS reviews_count INTEGER DEFAULT 0,
    ADD COLUMN IF NOT EXISTS is_bestseller BOOLEAN DEFAULT FALSE NOT NULL,
    ADD COLUMN IF NOT EXISTS total_lessons INTEGER DEFAULT 0,
    ADD COLUMN IF NOT EXISTS learning_outcomes JSONB DEFAULT '[]'::jsonb,
    ADD COLUMN IF NOT EXISTS requirements JSONB DEFAULT '[]'::jsonb;

CREATE INDEX IF NOT EXISTS idx_courses_instructor_id ON public.courses(instructor_id);
CREATE INDEX IF NOT EXISTS idx_courses_is_bestseller ON public.courses(is_bestseller);

-- 2. Create course_sections table
CREATE TABLE IF NOT EXISTS public.course_sections (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_course_sections_course_id ON public.course_sections(course_id);
CREATE INDEX IF NOT EXISTS idx_course_sections_sort_order ON public.course_sections(course_id, sort_order);

ALTER TABLE public.course_sections ENABLE ROW LEVEL SECURITY;

-- 3. Create course_lessons table
CREATE TABLE IF NOT EXISTS public.course_lessons (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    section_id UUID NOT NULL REFERENCES public.course_sections(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    video_url TEXT,
    video_duration TEXT,
    is_free_preview BOOLEAN DEFAULT FALSE NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_course_lessons_section_id ON public.course_lessons(section_id);
CREATE INDEX IF NOT EXISTS idx_course_lessons_course_id ON public.course_lessons(course_id);
CREATE INDEX IF NOT EXISTS idx_course_lessons_sort_order ON public.course_lessons(section_id, sort_order);

ALTER TABLE public.course_lessons ENABLE ROW LEVEL SECURITY;

-- 4. RLS policies for course_sections
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'course_sections' AND policyname = 'Authenticated users can read course sections') THEN
        CREATE POLICY "Authenticated users can read course sections"
            ON public.course_sections FOR SELECT
            USING (auth.uid() IS NOT NULL);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'course_sections' AND policyname = 'Admins and instructors can manage course sections') THEN
        CREATE POLICY "Admins and instructors can manage course sections"
            ON public.course_sections FOR INSERT
            WITH CHECK (
                EXISTS (
                    SELECT 1 FROM public.profiles
                    WHERE id = auth.uid()
                    AND role IN ('admin', 'superadmin', 'instructor')
                )
            );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'course_sections' AND policyname = 'Admins and instructors can update course sections') THEN
        CREATE POLICY "Admins and instructors can update course sections"
            ON public.course_sections FOR UPDATE
            USING (
                EXISTS (
                    SELECT 1 FROM public.profiles
                    WHERE id = auth.uid()
                    AND role IN ('admin', 'superadmin', 'instructor')
                )
            );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'course_sections' AND policyname = 'Admins and instructors can delete course sections') THEN
        CREATE POLICY "Admins and instructors can delete course sections"
            ON public.course_sections FOR DELETE
            USING (
                EXISTS (
                    SELECT 1 FROM public.profiles
                    WHERE id = auth.uid()
                    AND role IN ('admin', 'superadmin', 'instructor')
                )
            );
    END IF;
END;
$$;

-- 5. RLS policies for course_lessons
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'course_lessons' AND policyname = 'Authenticated users can read course lessons') THEN
        CREATE POLICY "Authenticated users can read course lessons"
            ON public.course_lessons FOR SELECT
            USING (auth.uid() IS NOT NULL);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'course_lessons' AND policyname = 'Admins and instructors can manage course lessons') THEN
        CREATE POLICY "Admins and instructors can manage course lessons"
            ON public.course_lessons FOR INSERT
            WITH CHECK (
                EXISTS (
                    SELECT 1 FROM public.profiles
                    WHERE id = auth.uid()
                    AND role IN ('admin', 'superadmin', 'instructor')
                )
            );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'course_lessons' AND policyname = 'Admins and instructors can update course lessons') THEN
        CREATE POLICY "Admins and instructors can update course lessons"
            ON public.course_lessons FOR UPDATE
            USING (
                EXISTS (
                    SELECT 1 FROM public.profiles
                    WHERE id = auth.uid()
                    AND role IN ('admin', 'superadmin', 'instructor')
                )
            );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'course_lessons' AND policyname = 'Admins and instructors can delete course lessons') THEN
        CREATE POLICY "Admins and instructors can delete course lessons"
            ON public.course_lessons FOR DELETE
            USING (
                EXISTS (
                    SELECT 1 FROM public.profiles
                    WHERE id = auth.uid()
                    AND role IN ('admin', 'superadmin', 'instructor')
                )
            );
    END IF;
END;
$$;

-- 6. Auto-update triggers for course_sections and course_lessons
CREATE OR REPLACE FUNCTION public.update_course_sections_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_course_sections_updated_at ON public.course_sections;
CREATE TRIGGER set_course_sections_updated_at
    BEFORE UPDATE ON public.course_sections
    FOR EACH ROW EXECUTE FUNCTION public.update_course_sections_updated_at();

CREATE OR REPLACE FUNCTION public.update_course_lessons_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_course_lessons_updated_at ON public.course_lessons;
CREATE TRIGGER set_course_lessons_updated_at
    BEFORE UPDATE ON public.course_lessons
    FOR EACH ROW EXECUTE FUNCTION public.update_course_lessons_updated_at();
