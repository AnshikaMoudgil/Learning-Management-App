-- ============================================================
-- Migration: Add created_by column to sessions table
-- Separates "Course Instructor" (from course.instructor_id)
-- from "Created By" (the user who created the session)
-- ============================================================

-- Add created_by column
ALTER TABLE public.sessions
ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL;

-- Index for created_by
CREATE INDEX IF NOT EXISTS idx_sessions_created_by ON public.sessions(created_by);

-- Backfill created_by with existing instructor_id values
UPDATE public.sessions SET created_by = instructor_id WHERE created_by IS NULL;

-- Fix existing sessions' instructor_id to point to the course instructor
-- (they were incorrectly set to the creator before this migration)
UPDATE public.sessions s
SET instructor_id = c.instructor_id
FROM public.courses c
WHERE s.course_id = c.id
  AND c.instructor_id IS NOT NULL
  AND s.instructor_id IS DISTINCT FROM c.instructor_id;

-- Make created_by NOT NULL after backfill
ALTER TABLE public.sessions ALTER COLUMN created_by SET NOT NULL;
