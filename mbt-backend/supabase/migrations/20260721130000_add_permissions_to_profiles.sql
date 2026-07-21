-- Add dynamic permission columns to the profiles table
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS allowed_sections TEXT[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS allowed_actions TEXT[] DEFAULT '{}';
