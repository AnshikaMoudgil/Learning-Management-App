export interface Device {
  id: string;
  user_id: string;
  fingerprint: string;
  platform: string | null;
  is_active: boolean;
  bound_at: string;
  last_seen_at: string;
  created_at: string;
  updated_at: string;
}
