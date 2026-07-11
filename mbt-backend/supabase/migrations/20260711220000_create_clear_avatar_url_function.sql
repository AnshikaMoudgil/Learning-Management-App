CREATE OR REPLACE FUNCTION public.clear_avatar_url(p_user_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    UPDATE public.learner_profiles
    SET avatar_url = NULL
    WHERE id = p_user_id;
END;
$$;
