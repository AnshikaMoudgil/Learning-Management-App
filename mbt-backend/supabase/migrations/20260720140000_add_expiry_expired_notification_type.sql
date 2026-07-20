-- ============================================================
-- Migration: Add 'expiry_expired' to notifications type check
-- ============================================================

ALTER TABLE public.notifications
DROP CONSTRAINT IF EXISTS notifications_type_check;

ALTER TABLE public.notifications
ADD CONSTRAINT notifications_type_check
CHECK (type IN (
    'session_created', 'session_updated', 'session_cancelled',
    'reminder_24h', 'reminder_1h', 'reminder_10min',
    'recording_ready',
    'session_live',
    'payment_confirmation',
    'expiry_alert',
    'expiry_expired',
    'device_login',
    'announcement'
));
