-- ============================================================
-- Migration: Add new notification types (payment, expiry, device, announcement)
-- ============================================================

DO $$
DECLARE
    constraint_name text;
BEGIN
    -- Find any CHECK constraint on notifications.type
    SELECT con.conname INTO constraint_name
    FROM pg_constraint con
    JOIN pg_class rel ON rel.oid = con.conrelid
    WHERE rel.relname = 'notifications'
    AND con.contype = 'c'
    AND pg_get_constraintdef(con.oid) LIKE '%type%';

    IF constraint_name IS NOT NULL THEN
        EXECUTE format('ALTER TABLE public.notifications DROP CONSTRAINT %I', constraint_name);
    END IF;
END
$$;

ALTER TABLE public.notifications
ADD CONSTRAINT notifications_type_check
CHECK (type IN (
    'session_created', 'session_updated', 'session_cancelled',
    'reminder_24h', 'reminder_1h', 'reminder_10min',
    'recording_ready',
    'session_live',
    'payment_confirmation',
    'expiry_alert',
    'device_login',
    'announcement'
));
