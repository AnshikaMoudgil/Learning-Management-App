-- Add email column to profiles table as nullable
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS email TEXT;

-- Backfill emails from auth.users to public.profiles
UPDATE public.profiles p
SET email = u.email
FROM auth.users u
WHERE p.id = u.id AND p.email IS NULL;

-- Update handle_new_user trigger function to include email
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF to_regclass('public.profiles') IS NOT NULL THEN
        INSERT INTO public.profiles (id, full_name, avatar_url, onboarding_completed, email)
        VALUES (
            new.id,
            coalesce(new.raw_user_meta_data->>'custom_full_name', new.raw_user_meta_data->>'full_name', ''),
            coalesce(new.raw_user_meta_data->>'custom_avatar_url', new.raw_user_meta_data->>'avatar_url', ''),
            FALSE,
            new.email
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
