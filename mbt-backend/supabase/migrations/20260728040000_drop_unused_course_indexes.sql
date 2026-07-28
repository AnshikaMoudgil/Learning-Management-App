-- ============================================================
-- Migration: Drop unused course indexes
-- ============================================================

-- idx_courses_is_bestseller: never used in any backend query
-- filter — only returned as a display field. (SCHEMA-02)
DROP INDEX IF EXISTS public.idx_courses_is_bestseller;

-- idx_courses_created_by: never used as a query filter in
-- backend code. (SCHEMA-02)
DROP INDEX IF EXISTS public.idx_courses_created_by;
