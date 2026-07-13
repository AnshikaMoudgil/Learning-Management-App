-- Create device_change_requests table
CREATE TABLE IF NOT EXISTS public.device_change_requests (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    old_fingerprint TEXT,
    new_fingerprint TEXT NOT NULL,
    reason TEXT,
    status TEXT DEFAULT 'pending' NOT NULL CHECK (status IN ('pending', 'approved', 'rejected')),
    reviewed_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_dcr_user_id ON public.device_change_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_dcr_status ON public.device_change_requests(status);
CREATE INDEX IF NOT EXISTS idx_dcr_reviewed_by ON public.device_change_requests(reviewed_by);

ALTER TABLE public.device_change_requests ENABLE ROW LEVEL SECURITY;

-- RLS policies
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'device_change_requests' AND policyname = 'Users can read own requests') THEN
        CREATE POLICY "Users can read own requests"
        ON public.device_change_requests
        FOR SELECT
        USING (auth.uid() = user_id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'device_change_requests' AND policyname = 'Users can insert own requests') THEN
        CREATE POLICY "Users can insert own requests"
        ON public.device_change_requests
        FOR INSERT
        WITH CHECK (auth.uid() = user_id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'device_change_requests' AND policyname = 'Admins can read all requests') THEN
        CREATE POLICY "Admins can read all requests"
        ON public.device_change_requests
        FOR SELECT
        USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin')));
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'device_change_requests' AND policyname = 'Admins can update all requests') THEN
        CREATE POLICY "Admins can update all requests"
        ON public.device_change_requests
        FOR UPDATE
        USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin')));
    END IF;
END;
$$;

-- Trigger for updated_at
CREATE OR REPLACE FUNCTION public.update_device_change_requests_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_device_change_requests_updated_at ON public.device_change_requests;
CREATE TRIGGER set_device_change_requests_updated_at
    BEFORE UPDATE ON public.device_change_requests
    FOR EACH ROW EXECUTE FUNCTION public.update_device_change_requests_updated_at();
