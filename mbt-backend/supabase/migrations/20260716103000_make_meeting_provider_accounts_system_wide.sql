-- ============================================================
-- Migration: Make Meeting Provider Accounts System-Wide
-- ============================================================

-- 1. Make instructor_id NULLABLE
ALTER TABLE public.meeting_provider_accounts 
    ALTER COLUMN instructor_id DROP NOT NULL;

-- 2. Drop the old unique constraint (instructor_id, provider)
ALTER TABLE public.meeting_provider_accounts 
    DROP CONSTRAINT IF EXISTS meeting_provider_accounts_instructor_id_provider_key;

-- 3. Add a unique index for the system-wide provider connection
CREATE UNIQUE INDEX IF NOT EXISTS idx_meeting_provider_accounts_system_provider 
    ON public.meeting_provider_accounts (provider) 
    WHERE instructor_id IS NULL;
