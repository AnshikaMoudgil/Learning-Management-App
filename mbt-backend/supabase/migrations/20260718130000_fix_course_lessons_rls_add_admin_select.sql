-- ============================================================
-- Migration: Fix course_lessons RLS — add admin/instructor SELECT
-- ============================================================
-- The previous migration (20260713103000) replaced the open SELECT
-- policy with one restricted to free_preview or enrolled users only.
-- This blocks admins/instructors from reading back lessons they
-- create via the admin panel (they're not enrolled in the course).
--
-- This migration adds a separate SELECT policy for admin/instructor
-- roles so they can manage all lessons.
-- ============================================================

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'course_lessons' AND policyname = 'Admins and instructors can read all course lessons') THEN
        CREATE POLICY "Admins and instructors can read all course lessons"
            ON public.course_lessons FOR SELECT
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
