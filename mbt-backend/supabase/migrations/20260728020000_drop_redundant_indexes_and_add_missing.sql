-- ============================================================
-- Migration: Drop redundant indexes, add missing ones
-- ============================================================

-- SCHEMA-03: idx_notifications_user_id is redundant
-- Composites (idx_notifications_is_read, idx_notifications_user_type,
-- idx_notifications_user_created) all cover user_id as leftmost prefix.
DROP INDEX IF EXISTS public.idx_notifications_user_id;

-- SCHEMA-06: idx_enrollments_course_id is redundant
-- idx_enrollments_course_user_status(course_id, user_id, status)
-- already covers course_id leftmost prefix.
DROP INDEX IF EXISTS public.idx_enrollments_course_id;

-- SCHEMA-04: Convert idx_sessions_status to a partial index
-- Only live/scheduled sessions are queried by status hot-path.
DROP INDEX IF EXISTS public.idx_sessions_status;
CREATE INDEX IF NOT EXISTS idx_sessions_status_active
    ON public.sessions(status)
    WHERE status IN ('scheduled', 'live');

-- SCHEMA-09: Add index on instructor_profiles.is_approved
-- for admin approval workflow queries.
CREATE INDEX IF NOT EXISTS idx_instructor_profiles_approved
    ON public.instructor_profiles(is_approved);
