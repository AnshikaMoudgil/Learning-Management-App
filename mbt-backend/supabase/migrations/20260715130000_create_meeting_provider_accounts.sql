-- ============================================================
-- Migration: Meeting Provider Accounts
-- Stores per-instructor OAuth tokens for Zoom (and future providers)
-- Tokens are encrypted at rest by the application layer
-- ============================================================

CREATE TABLE IF NOT EXISTS public.meeting_provider_accounts (
    id              UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
    instructor_id   UUID        NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    provider        TEXT        NOT NULL DEFAULT 'zoom'
                                CHECK (provider IN ('zoom')),
    provider_user_id TEXT,
    email           TEXT,
    access_token    TEXT        NOT NULL,
    refresh_token   TEXT        NOT NULL,
    expires_at      TIMESTAMPTZ,
    connected_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    status          TEXT        NOT NULL DEFAULT 'connected'
                                CHECK (status IN ('connected', 'disconnected', 'expired')),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- One Zoom connection per instructor
    UNIQUE (instructor_id, provider)
);

CREATE INDEX IF NOT EXISTS idx_provider_accounts_instructor
    ON public.meeting_provider_accounts(instructor_id);

CREATE INDEX IF NOT EXISTS idx_provider_accounts_provider
    ON public.meeting_provider_accounts(provider);

-- ============================================================
-- updated_at trigger
-- ============================================================
DROP TRIGGER IF EXISTS set_meeting_provider_accounts_updated_at
    ON public.meeting_provider_accounts;
CREATE TRIGGER set_meeting_provider_accounts_updated_at
    BEFORE UPDATE ON public.meeting_provider_accounts
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ============================================================
-- RLS: instructors manage their own provider accounts
-- ============================================================
ALTER TABLE public.meeting_provider_accounts ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE tablename = 'meeting_provider_accounts'
        AND policyname = 'Users can read own provider accounts'
    ) THEN
        CREATE POLICY "Users can read own provider accounts"
            ON public.meeting_provider_accounts FOR SELECT
            USING (instructor_id = auth.uid());
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE tablename = 'meeting_provider_accounts'
        AND policyname = 'Users can manage own provider accounts'
    ) THEN
        CREATE POLICY "Users can manage own provider accounts"
            ON public.meeting_provider_accounts FOR ALL
            USING (instructor_id = auth.uid())
            WITH CHECK (instructor_id = auth.uid());
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE tablename = 'meeting_provider_accounts'
        AND policyname = 'Admins can read all provider accounts'
    ) THEN
        CREATE POLICY "Admins can read all provider accounts"
            ON public.meeting_provider_accounts FOR SELECT
            USING (
                EXISTS (
                    SELECT 1 FROM public.profiles
                    WHERE id = auth.uid()
                    AND role IN ('admin', 'superadmin')
                )
            );
    END IF;
END;
$$;
