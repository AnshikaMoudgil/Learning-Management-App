-- ============================================================
-- Migration: In-app notifications table
-- ============================================================

CREATE TABLE IF NOT EXISTS public.notifications (
    id         UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id    UUID        NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    type       TEXT        NOT NULL
                           CHECK (type IN (
                               'session_created', 'session_updated', 'session_cancelled',
                               'reminder_24h', 'reminder_1h', 'reminder_10min',
                               'recording_ready'
                           )),
    title      TEXT        NOT NULL,
    body       TEXT        NOT NULL,
    data       JSONB,
    is_read    BOOLEAN     NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id    ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read    ON public.notifications(user_id, is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON public.notifications(created_at DESC);

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
    -- Users can only read their own notifications
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'notifications' AND policyname = 'Users can read own notifications') THEN
        CREATE POLICY "Users can read own notifications"
            ON public.notifications FOR SELECT
            USING (user_id = auth.uid());
    END IF;

    -- Users can mark their own notifications as read
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'notifications' AND policyname = 'Users can update own notifications') THEN
        CREATE POLICY "Users can update own notifications"
            ON public.notifications FOR UPDATE
            USING (user_id = auth.uid())
            WITH CHECK (user_id = auth.uid());
    END IF;

    -- Admins can manage all notifications
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'notifications' AND policyname = 'Admins can manage notifications') THEN
        CREATE POLICY "Admins can manage notifications"
            ON public.notifications FOR ALL
            USING (
                EXISTS (
                    SELECT 1 FROM public.profiles
                    WHERE id = auth.uid()
                    AND role IN ('admin', 'superadmin')
                )
            )
            WITH CHECK (
                EXISTS (
                    SELECT 1 FROM public.profiles
                    WHERE id = auth.uid()
                    AND role IN ('admin', 'superadmin')
                )
            );
    END IF;
END;
$$;
