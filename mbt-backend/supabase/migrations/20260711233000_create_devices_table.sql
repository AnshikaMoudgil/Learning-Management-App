CREATE TABLE IF NOT EXISTS public.devices (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    fingerprint TEXT NOT NULL,
    platform TEXT,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    bound_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    last_seen_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_devices_user_id ON public.devices(user_id);
CREATE INDEX IF NOT EXISTS idx_devices_fingerprint ON public.devices(fingerprint);
CREATE UNIQUE INDEX IF NOT EXISTS idx_devices_user_fingerprint ON public.devices(user_id, fingerprint);

ALTER TABLE public.devices ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'devices' AND policyname = 'Allow users to read their own devices') THEN
        CREATE POLICY "Allow users to read their own devices"
        ON public.devices
        FOR SELECT
        USING (auth.uid() = user_id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'devices' AND policyname = 'Allow users to insert their own devices') THEN
        CREATE POLICY "Allow users to insert their own devices"
        ON public.devices
        FOR INSERT
        WITH CHECK (auth.uid() = user_id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'devices' AND policyname = 'Allow users to update their own devices') THEN
        CREATE POLICY "Allow users to update their own devices"
        ON public.devices
        FOR UPDATE
        USING (auth.uid() = user_id);
    END IF;
END;
$$;

-- Trigger to update updated_at
CREATE OR REPLACE FUNCTION public.update_devices_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_devices_updated_at ON public.devices;
CREATE TRIGGER set_devices_updated_at
    BEFORE UPDATE ON public.devices
    FOR EACH ROW EXECUTE FUNCTION public.update_devices_updated_at();
