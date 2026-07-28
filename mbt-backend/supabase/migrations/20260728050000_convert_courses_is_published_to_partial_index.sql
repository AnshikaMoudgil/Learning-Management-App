-- ============================================================
-- Migration: Convert courses.is_published to partial index
-- ============================================================
-- All backend queries filter is_published = TRUE only.
-- A full btree on a boolean column is wasteful; a partial
-- index WHERE is_published = TRUE is smaller and equally fast.

DROP INDEX IF EXISTS public.idx_courses_is_published;

CREATE INDEX IF NOT EXISTS idx_courses_published
    ON public.courses(id)
    WHERE is_published = TRUE;
