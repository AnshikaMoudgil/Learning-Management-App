-- ============================================================
-- Migration: Drop instructor_id from meeting_provider_accounts
-- The Zoom connection is now system-wide (instructor_id IS NULL)
-- ============================================================

-- 1. Drop old RLS policies that reference instructor_id
DROP POLICY IF EXISTS "Users can read own provider accounts" ON public.meeting_provider_accounts;
DROP POLICY IF EXISTS "Users can manage own provider accounts" ON public.meeting_provider_accounts;
DROP POLICY IF EXISTS "Admins can read all provider accounts" ON public.meeting_provider_accounts;

-- 2. Create new RLS policies (admin/superadmin only, since this is system-wide)
CREATE POLICY "Admins can read provider accounts"
    ON public.meeting_provider_accounts FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid()
            AND role IN ('admin', 'superadmin', 'instructor')
        )
    );

CREATE POLICY "Superadmins can manage provider accounts"
    ON public.meeting_provider_accounts FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid()
            AND role IN ('admin', 'superadmin')
        )
    );

-- 3. Drop the per-instructor index
DROP INDEX IF EXISTS idx_provider_accounts_instructor;

-- 4. Drop the instructor_id column
ALTER TABLE public.meeting_provider_accounts DROP COLUMN IF EXISTS instructor_id;
