-- Add fcm_token column to public.devices
ALTER TABLE public.devices ADD COLUMN IF NOT EXISTS fcm_token TEXT;
