-- Create enum types
DO $$ BEGIN
    CREATE TYPE public.user_role AS ENUM ('learner', 'admin', 'superadmin', 'instructor');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE public.user_status AS ENUM ('ACTIVE', 'SUSPENDED', 'BLOCKED');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- Rename table
ALTER TABLE IF EXISTS public.learner_profiles RENAME TO profiles;

-- Add new columns
ALTER TABLE public.profiles
    ADD COLUMN IF NOT EXISTS role public.user_role DEFAULT 'learner' NOT NULL,
    ADD COLUMN IF NOT EXISTS status public.user_status DEFAULT 'ACTIVE' NOT NULL,
    ADD COLUMN IF NOT EXISTS about TEXT;

-- Remove device_id column
ALTER TABLE public.profiles DROP COLUMN IF EXISTS device_id;

-- Drop old policies on the old table name
DROP POLICY IF EXISTS "Allow public read access to active profiles" ON public.profiles;
DROP POLICY IF EXISTS "Allow individuals to update their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Allow individuals to insert their own profile" ON public.profiles;

-- Recreate policies on the renamed table
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'profiles' AND policyname = 'Allow public read access to active profiles') THEN
        CREATE POLICY "Allow public read access to active profiles"
        ON public.profiles
        FOR SELECT
        USING (is_deleted = FALSE AND status = 'ACTIVE');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'profiles' AND policyname = 'Allow individuals to update their own profile') THEN
        CREATE POLICY "Allow individuals to update their own profile"
        ON public.profiles
        FOR UPDATE
        USING (auth.uid() = id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'profiles' AND policyname = 'Allow individuals to insert their own profile') THEN
        CREATE POLICY "Allow individuals to insert their own profile"
        ON public.profiles
        FOR INSERT
        WITH CHECK (auth.uid() = id);
    END IF;
END;
$$;

-- Update the handle_new_user function to use the new table name
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF to_regclass('public.profiles') IS NOT NULL THEN
        INSERT INTO public.profiles (id, full_name, avatar_url, onboarding_completed)
        VALUES (
            new.id,
            coalesce(new.raw_user_meta_data->>'custom_full_name', new.raw_user_meta_data->>'full_name', ''),
            coalesce(new.raw_user_meta_data->>'custom_avatar_url', new.raw_user_meta_data->>'avatar_url', ''),
            FALSE
        )
        ON CONFLICT (id) DO NOTHING;
    END IF;

    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'handle_new_user failed for user %, sqlstate %, message %', new.id, SQLSTATE, SQLERRM;
        RETURN NEW;
END;
$$;

-- Update the clear_avatar_url function to use the new table name
CREATE OR REPLACE FUNCTION public.clear_avatar_url(p_user_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    UPDATE public.profiles
    SET avatar_url = NULL
    WHERE id = p_user_id;
END;
$$;

-- Drop old triggers referencing the old table name
DROP TRIGGER IF EXISTS set_updated_at ON public.profiles;
DO $$ BEGIN
    IF to_regclass('public.learner_profiles') IS NOT NULL THEN
        DROP TRIGGER IF EXISTS set_updated_at ON public.learner_profiles;
    END IF;
END $$;
DROP FUNCTION IF EXISTS public.update_updated_at_column();
