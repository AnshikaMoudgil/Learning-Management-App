-- Create learner_profiles table
CREATE TABLE IF NOT EXISTS public.learner_profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    full_name TEXT,
    avatar_url TEXT,
    device_id TEXT,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    is_deleted BOOLEAN DEFAULT FALSE NOT NULL,
    onboarding_completed BOOLEAN DEFAULT FALSE NOT NULL,
    last_login_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.learner_profiles ENABLE ROW LEVEL SECURITY;

-- Create policies for client interaction
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'learner_profiles' AND policyname = 'Allow public read access to active profiles') THEN
        CREATE POLICY "Allow public read access to active profiles" 
        ON public.learner_profiles 
        FOR SELECT 
        USING (is_deleted = FALSE AND is_active = TRUE);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'learner_profiles' AND policyname = 'Allow individuals to update their own profile') THEN
        CREATE POLICY "Allow individuals to update their own profile" 
        ON public.learner_profiles 
        FOR UPDATE 
        USING (auth.uid() = id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'learner_profiles' AND policyname = 'Allow individuals to insert their own profile') THEN
        CREATE POLICY "Allow individuals to insert their own profile" 
        ON public.learner_profiles 
        FOR INSERT 
        WITH CHECK (auth.uid() = id);
    END IF;
END;
$$;

-- Create a function to automatically create a profile entry on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF to_regclass('public.learner_profiles') IS NOT NULL THEN
        INSERT INTO public.learner_profiles (id, full_name, avatar_url, onboarding_completed)
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

GRANT EXECUTE ON FUNCTION public.handle_new_user() TO authenticated;
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO service_role;

-- Trigger to run the function on auth.users signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Trigger to update the updated_at column
DROP TRIGGER IF EXISTS set_updated_at ON public.learner_profiles;
DROP FUNCTION IF EXISTS public.update_updated_at_column();

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at
    BEFORE INSERT OR UPDATE ON public.learner_profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
