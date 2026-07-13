-- Remove device-change cooldown column from profiles if it exists
-- Cooldown is now derived from MAX(reviewed_at) on device_change_requests
ALTER TABLE public.profiles DROP COLUMN IF EXISTS last_device_change_at;
