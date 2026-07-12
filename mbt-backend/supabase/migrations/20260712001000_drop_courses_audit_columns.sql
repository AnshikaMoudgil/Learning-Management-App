ALTER TABLE public.courses DROP COLUMN IF EXISTS created_by;
ALTER TABLE public.courses DROP COLUMN IF EXISTS updated_by;

-- Create courses storage bucket for course images (thumbnails, previews, etc.)
INSERT INTO storage.buckets (id, name, public, avif_autodetection, file_size_limit, allowed_mime_types)
VALUES ('courses', 'courses', true, false, 2097152, '{image/png,image/jpeg,image/webp,image/gif}')
ON CONFLICT (id) DO NOTHING;

-- Allow public read access to course images
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'objects' AND policyname = 'Public read access for courses') THEN
        CREATE POLICY "Public read access for courses"
        ON storage.objects FOR SELECT
        USING (bucket_id = 'courses');
    END IF;
END;
$$;

-- Allow admins and instructors to upload course images
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'objects' AND policyname = 'Admin upload for courses') THEN
        CREATE POLICY "Admin upload for courses"
        ON storage.objects FOR INSERT
        WITH CHECK (
            bucket_id = 'courses'
            AND EXISTS (
                SELECT 1 FROM public.profiles
                WHERE id = auth.uid()
                AND role IN ('admin', 'superadmin', 'instructor')
            )
        );
    END IF;
END;
$$;

-- Allow admins and instructors to update course images
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'objects' AND policyname = 'Admin update for courses') THEN
        CREATE POLICY "Admin update for courses"
        ON storage.objects FOR UPDATE
        USING (
            bucket_id = 'courses'
            AND EXISTS (
                SELECT 1 FROM public.profiles
                WHERE id = auth.uid()
                AND role IN ('admin', 'superadmin', 'instructor')
            )
        );
    END IF;
END;
$$;

-- Allow admins and instructors to delete course images
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'objects' AND policyname = 'Admin delete for courses') THEN
        CREATE POLICY "Admin delete for courses"
        ON storage.objects FOR DELETE
        USING (
            bucket_id = 'courses'
            AND EXISTS (
                SELECT 1 FROM public.profiles
                WHERE id = auth.uid()
                AND role IN ('admin', 'superadmin', 'instructor')
            )
        );
    END IF;
END;
$$;
