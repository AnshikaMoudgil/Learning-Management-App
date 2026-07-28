-- ============================================================
-- Migration: Scope media_assets RLS to enrolled users + staff
-- ============================================================
-- SCHEMA-08: The previous policy let ALL authenticated users
-- read every media asset's metadata (leaks checksums, status,
-- processing errors across tenants).

DO $$
BEGIN
    -- Drop the overly permissive policy
    DROP POLICY IF EXISTS "Authenticated users can read media asset metadata"
        ON public.media_assets;

    -- Create scoped policy: enrolled users see assets linked to
    -- their course lessons; admins/instructors see everything
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE tablename = 'media_assets'
          AND policyname = 'Enrolled users and staff can read media assets'
    ) THEN
        CREATE POLICY "Enrolled users and staff can read media assets"
            ON public.media_assets FOR SELECT
            USING (
                EXISTS (
                    SELECT 1 FROM public.profiles
                    WHERE id = auth.uid()
                      AND role IN ('admin', 'superadmin', 'instructor')
                )
                OR EXISTS (
                    SELECT 1 FROM public.course_lessons cl
                    JOIN public.enrollments e
                      ON e.course_id = cl.course_id
                     AND e.user_id = auth.uid()
                     AND e.status = 'active'
                     AND (e.validity_end_at IS NULL OR e.validity_end_at > NOW())
                    WHERE cl.video_asset_id = media_assets.id
                )
            );
    END IF;
END;
$$;
