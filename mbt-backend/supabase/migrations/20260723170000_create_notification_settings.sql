-- Create notification_settings table
CREATE TABLE IF NOT EXISTS public.notification_settings (
    user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    live_class_reminders BOOLEAN DEFAULT TRUE NOT NULL,
    course_expiry_alerts BOOLEAN DEFAULT TRUE NOT NULL,
    payment_confirmations BOOLEAN DEFAULT TRUE NOT NULL,
    device_transfer_status BOOLEAN DEFAULT TRUE NOT NULL,
    promotional_marketing BOOLEAN DEFAULT TRUE NOT NULL,
    push_notifications BOOLEAN DEFAULT TRUE NOT NULL,
    email BOOLEAN DEFAULT TRUE NOT NULL,
    sms BOOLEAN DEFAULT TRUE NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Enable RLS
ALTER TABLE public.notification_settings ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
    -- Users can only read their own notification settings
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'notification_settings' AND policyname = 'Users can read own notification settings') THEN
        CREATE POLICY "Users can read own notification settings"
            ON public.notification_settings FOR SELECT
            USING (user_id = auth.uid());
    END IF;

    -- Users can update their own notification settings
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'notification_settings' AND policyname = 'Users can update own notification settings') THEN
        CREATE POLICY "Users can update own notification settings"
            ON public.notification_settings FOR UPDATE
            USING (user_id = auth.uid())
            WITH CHECK (user_id = auth.uid());
    END IF;

    -- Users can insert their own notification settings
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'notification_settings' AND policyname = 'Users can insert own notification settings') THEN
        CREATE POLICY "Users can insert own notification settings"
            ON public.notification_settings FOR INSERT
            WITH CHECK (user_id = auth.uid());
    END IF;
END;
$$;
