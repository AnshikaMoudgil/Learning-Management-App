-- The updated_at column was never added to the table, but the trigger
-- referencing it was created. Drop the broken trigger and function.

DROP TRIGGER IF EXISTS set_updated_at ON public.learner_profiles;
DROP FUNCTION IF EXISTS public.update_updated_at_column();
