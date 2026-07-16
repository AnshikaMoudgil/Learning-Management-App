-- Migration: Refactor session_recordings to be provider-agnostic
-- Phase 8 database changes

ALTER TABLE public.session_recordings
    ADD COLUMN provider TEXT NOT NULL DEFAULT 'cloudinary',
    ADD COLUMN storage_key TEXT,
    ADD COLUMN file_name TEXT,
    ADD COLUMN mime_type TEXT,
    ADD COLUMN uploaded_at TIMESTAMPTZ DEFAULT NOW();

-- Rename r2_url to storage_url
ALTER TABLE public.session_recordings
    RENAME COLUMN r2_url TO storage_url;

-- Rename processing_status to status
-- First drop the check constraint on processing_status if it exists
-- The check constraint in the original migration was implicit or auto-named
-- We can drop and re-add/rename constraint safely
ALTER TABLE public.session_recordings
    DROP CONSTRAINT IF EXISTS session_recordings_processing_status_check;

ALTER TABLE public.session_recordings
    RENAME COLUMN processing_status TO status;

ALTER TABLE public.session_recordings
    ADD CONSTRAINT session_recordings_status_check
    CHECK (status IN ('none', 'processing', 'ready', 'failed'));
