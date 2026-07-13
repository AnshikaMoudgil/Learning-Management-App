-- Create instructor_profiles table for extended instructor info
CREATE TABLE IF NOT EXISTS public.instructor_profiles (
    id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    specialization TEXT,
    bio TEXT,
    phone TEXT,
    qualifications TEXT[] DEFAULT '{}',
    experience_years INTEGER,
    education TEXT,
    social_links JSONB DEFAULT '{}'::jsonb,
    is_approved BOOLEAN DEFAULT FALSE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

ALTER TABLE public.instructor_profiles ENABLE ROW LEVEL SECURITY;

-- Instructors can read/update their own profile, admins can read/update all
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'instructor_profiles' AND policyname = 'Instructors can read own profile') THEN
        CREATE POLICY "Instructors can read own profile"
            ON public.instructor_profiles FOR SELECT
            USING (auth.uid() = id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'instructor_profiles' AND policyname = 'Instructors can update own profile') THEN
        CREATE POLICY "Instructors can update own profile"
            ON public.instructor_profiles FOR UPDATE
            USING (auth.uid() = id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'instructor_profiles' AND policyname = 'Instructors can insert own profile') THEN
        CREATE POLICY "Instructors can insert own profile"
            ON public.instructor_profiles FOR INSERT
            WITH CHECK (auth.uid() = id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'instructor_profiles' AND policyname = 'Admins can read all instructor profiles') THEN
        CREATE POLICY "Admins can read all instructor profiles"
            ON public.instructor_profiles FOR SELECT
            USING (
                EXISTS (
                    SELECT 1 FROM public.profiles
                    WHERE id = auth.uid()
                    AND role IN ('admin', 'superadmin')
                )
            );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'instructor_profiles' AND policyname = 'Admins can update all instructor profiles') THEN
        CREATE POLICY "Admins can update all instructor profiles"
            ON public.instructor_profiles FOR UPDATE
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

-- Re-add created_by to courses (was dropped in a previous migration)
ALTER TABLE public.courses ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_courses_created_by ON public.courses(created_by);

-- Update RLS: instructors can only update/delete courses they created
DO $$
BEGIN
    DROP POLICY IF EXISTS "Admins and instructors can update courses" ON public.courses;
END;
$$;

CREATE POLICY "Admins and instructors can update courses"
    ON public.courses
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid()
            AND role IN ('admin', 'superadmin')
        )
        OR
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid()
            AND role = 'instructor'
            AND public.courses.created_by = auth.uid()
        )
    );

DO $$
BEGIN
    DROP POLICY IF EXISTS "Admins and instructors can delete courses" ON public.courses;
END;
$$;

CREATE POLICY "Admins and instructors can delete courses"
    ON public.courses
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid()
            AND role IN ('admin', 'superadmin')
        )
        OR
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid()
            AND role = 'instructor'
            AND public.courses.created_by = auth.uid()
        )
    );

-- Auto-update trigger for instructor_profiles updated_at
CREATE OR REPLACE FUNCTION public.update_instructor_profiles_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_instructor_profiles_updated_at ON public.instructor_profiles;
CREATE TRIGGER set_instructor_profiles_updated_at
    BEFORE UPDATE ON public.instructor_profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_instructor_profiles_updated_at();
