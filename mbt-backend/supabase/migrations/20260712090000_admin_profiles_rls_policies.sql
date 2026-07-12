-- Drop recursive policies first to fix the database recursion error
DROP POLICY IF EXISTS "Admins can read all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Admins can update user profiles" ON public.profiles;

-- Create helper function with SECURITY DEFINER to bypass RLS and avoid circular dependency
CREATE OR REPLACE FUNCTION public.get_user_role(p_user_id UUID)
RETURNS public.user_role
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_role public.user_role;
BEGIN
  SELECT role INTO v_role FROM public.profiles WHERE id = p_user_id;
  RETURN v_role;
END;
$$;

-- Allow admins and superadmins to read ALL profiles (using the helper to prevent recursion)
CREATE POLICY "Admins can read all profiles"
ON public.profiles
FOR SELECT
USING (
  public.get_user_role(auth.uid()) IN ('admin', 'superadmin', 'instructor')
);

-- Allow admins and superadmins to update user profiles (using the helper to prevent recursion)
CREATE POLICY "Admins can update user profiles"
ON public.profiles
FOR UPDATE
USING (
  public.get_user_role(auth.uid()) IN ('admin', 'superadmin')
);
