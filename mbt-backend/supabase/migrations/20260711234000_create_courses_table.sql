DO $$ BEGIN
    CREATE TYPE public.course_level AS ENUM ('beginner', 'intermediate', 'advanced');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS public.courses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    slug TEXT NOT NULL,
    short_description TEXT,
    description TEXT,
    thumbnail_url TEXT,
    preview_video_url TEXT,
    language TEXT DEFAULT 'English' NOT NULL,
    level public.course_level DEFAULT 'beginner' NOT NULL,
    category TEXT,
    price NUMERIC(10,2) DEFAULT 0.00 NOT NULL,
    discount_price NUMERIC(10,2),
    validity_days INTEGER,
    estimated_duration TEXT,
    is_published BOOLEAN DEFAULT FALSE NOT NULL,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    updated_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_courses_slug ON public.courses(slug);
CREATE INDEX IF NOT EXISTS idx_courses_category ON public.courses(category);
CREATE INDEX IF NOT EXISTS idx_courses_is_published ON public.courses(is_published);

ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'courses' AND policyname = 'Authenticated users can read courses') THEN
        CREATE POLICY "Authenticated users can read courses"
        ON public.courses
        FOR SELECT
        USING (auth.uid() IS NOT NULL);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'courses' AND policyname = 'Admins and instructors can insert courses') THEN
        CREATE POLICY "Admins and instructors can insert courses"
        ON public.courses
        FOR INSERT
        WITH CHECK (
            EXISTS (
                SELECT 1 FROM public.profiles
                WHERE id = auth.uid()
                AND role IN ('admin', 'superadmin', 'instructor')
            )
        );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'courses' AND policyname = 'Admins and instructors can update courses') THEN
        CREATE POLICY "Admins and instructors can update courses"
        ON public.courses
        FOR UPDATE
        USING (
            EXISTS (
                SELECT 1 FROM public.profiles
                WHERE id = auth.uid()
                AND role IN ('admin', 'superadmin', 'instructor')
            )
        );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'courses' AND policyname = 'Admins and instructors can delete courses') THEN
        CREATE POLICY "Admins and instructors can delete courses"
        ON public.courses
        FOR DELETE
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

CREATE OR REPLACE FUNCTION public.update_courses_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_courses_updated_at ON public.courses;
CREATE TRIGGER set_courses_updated_at
    BEFORE UPDATE ON public.courses
    FOR EACH ROW EXECUTE FUNCTION public.update_courses_updated_at();
