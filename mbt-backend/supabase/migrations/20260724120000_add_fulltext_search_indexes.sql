-- Add Full-Text Search (FTS) support for search and course filtering
-- Replaces unanchored ILIKE scans with indexed tsvector lookups

-- 1. Add tsvector columns
ALTER TABLE courses ADD COLUMN IF NOT EXISTS search_document tsvector
  GENERATED ALWAYS AS (
    to_tsvector('english', coalesce(title, '') || ' ' || coalesce(description, '') || ' ' || coalesce(category, ''))
  ) STORED;

ALTER TABLE course_lessons ADD COLUMN IF NOT EXISTS search_document tsvector
  GENERATED ALWAYS AS (
    to_tsvector('english', coalesce(title, ''))
  ) STORED;

ALTER TABLE profiles ADD COLUMN IF NOT EXISTS search_document tsvector
  GENERATED ALWAYS AS (
    to_tsvector('english', coalesce(full_name, ''))
  ) STORED;

-- 2. GIN indexes for fast full-text search
CREATE INDEX IF NOT EXISTS idx_courses_search_document ON courses USING GIN (search_document);
CREATE INDEX IF NOT EXISTS idx_course_lessons_search_document ON course_lessons USING GIN (search_document);
CREATE INDEX IF NOT EXISTS idx_profiles_search_document ON profiles USING GIN (search_document);

-- 3. Missing FKs and hot-path indexes (per audit)
CREATE INDEX IF NOT EXISTS idx_enrollments_user_id ON enrollments(user_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_course_id ON enrollments(course_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_course_user_status ON enrollments(course_id, user_id, status);
CREATE INDEX IF NOT EXISTS idx_courses_slug ON courses(slug);
CREATE INDEX IF NOT EXISTS idx_notifications_user_type ON notifications(user_id, type);
CREATE INDEX IF NOT EXISTS idx_notifications_user_created ON notifications(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_payment_items_payment_id ON payment_items(payment_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_lesson_progress_user_lesson ON user_lesson_progress(user_id, lesson_id);
