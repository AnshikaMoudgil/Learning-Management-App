-- Drop unused course columns: description and preview_video_url
ALTER TABLE public.courses DROP COLUMN IF EXISTS description;
ALTER TABLE public.courses DROP COLUMN IF EXISTS preview_video_url;

-- Rebuild the search index without description
DROP INDEX IF EXISTS idx_courses_search_document;
ALTER TABLE public.courses DROP COLUMN IF EXISTS search_document;
ALTER TABLE public.courses ADD COLUMN search_document tsvector
  GENERATED ALWAYS AS (
    to_tsvector('english', coalesce(title, '') || ' ' || coalesce(category, ''))
  ) STORED;
CREATE INDEX IF NOT EXISTS idx_courses_search_document ON courses USING GIN (search_document);
