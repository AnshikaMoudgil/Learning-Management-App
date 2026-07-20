-- ============================================================
-- Migration: Dedicated media assets for course lesson videos
-- ============================================================

CREATE TABLE IF NOT EXISTS public.media_assets (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    provider TEXT NOT NULL DEFAULT 'pending',
    storage_key TEXT,
    storage_url TEXT,
    checksum TEXT NOT NULL,
    mime_type TEXT NOT NULL,
    size BIGINT NOT NULL DEFAULT 0,
    duration NUMERIC,
    width INTEGER,
    height INTEGER,
    fps NUMERIC,
    codec TEXT,
    bitrate INTEGER,
    thumbnail_url TEXT,
    status TEXT NOT NULL DEFAULT 'PENDING'
        CHECK (status IN ('PENDING', 'UPLOADING', 'PROCESSING', 'READY', 'FAILED', 'CANCELLED', 'DELETED')),
    processing_error TEXT,
    uploaded_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    uploaded_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_media_assets_checksum_active
    ON public.media_assets(checksum)
    WHERE status <> 'DELETED';
CREATE INDEX IF NOT EXISTS idx_media_assets_status ON public.media_assets(status);
CREATE INDEX IF NOT EXISTS idx_media_assets_uploaded_by ON public.media_assets(uploaded_by);

ALTER TABLE public.course_lessons
    ADD COLUMN IF NOT EXISTS video_asset_id UUID REFERENCES public.media_assets(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_course_lessons_video_asset_id
    ON public.course_lessons(video_asset_id);

CREATE TABLE IF NOT EXISTS public.media_asset_audit_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    media_asset_id UUID REFERENCES public.media_assets(id) ON DELETE SET NULL,
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    action TEXT NOT NULL CHECK (action IN ('upload', 'delete', 'playback_request', 'processing_failure')),
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_media_asset_audit_logs_asset_id
    ON public.media_asset_audit_logs(media_asset_id);
CREATE INDEX IF NOT EXISTS idx_media_asset_audit_logs_user_id
    ON public.media_asset_audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_media_asset_audit_logs_created_at
    ON public.media_asset_audit_logs(created_at DESC);

ALTER TABLE public.media_assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.media_asset_audit_logs ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'media_assets' AND policyname = 'Authenticated users can read media asset metadata') THEN
        CREATE POLICY "Authenticated users can read media asset metadata"
            ON public.media_assets FOR SELECT
            USING (auth.uid() IS NOT NULL);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'media_assets' AND policyname = 'Admins and instructors can manage media assets') THEN
        CREATE POLICY "Admins and instructors can manage media assets"
            ON public.media_assets FOR ALL
            USING (
                EXISTS (
                    SELECT 1 FROM public.profiles
                    WHERE id = auth.uid()
                    AND role IN ('admin', 'superadmin', 'instructor')
                )
            )
            WITH CHECK (
                EXISTS (
                    SELECT 1 FROM public.profiles
                    WHERE id = auth.uid()
                    AND role IN ('admin', 'superadmin', 'instructor')
                )
            );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'media_asset_audit_logs' AND policyname = 'Admins can read media audit logs') THEN
        CREATE POLICY "Admins can read media audit logs"
            ON public.media_asset_audit_logs FOR SELECT
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

CREATE OR REPLACE FUNCTION public.update_media_assets_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_media_assets_updated_at ON public.media_assets;
CREATE TRIGGER set_media_assets_updated_at
    BEFORE UPDATE ON public.media_assets
    FOR EACH ROW EXECUTE FUNCTION public.update_media_assets_updated_at();

