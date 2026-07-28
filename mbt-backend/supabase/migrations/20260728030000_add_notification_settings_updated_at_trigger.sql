-- ============================================================
-- Migration: Add updated_at trigger to notification_settings
-- ============================================================
-- SCHEMA-07: notification_settings has an updated_at column
-- but no BEFORE UPDATE trigger to maintain it.

DROP TRIGGER IF EXISTS set_notification_settings_updated_at
    ON public.notification_settings;

CREATE TRIGGER set_notification_settings_updated_at
    BEFORE UPDATE ON public.notification_settings
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
