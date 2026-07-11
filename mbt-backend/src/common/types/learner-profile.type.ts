export interface LearnerProfile {
  id: string;
  full_name: string | null;
  avatar_url: string | null;
  device_id: string | null;
  is_active: boolean;
  is_deleted: boolean;
  onboarding_completed: boolean;
  last_login_at: string | null;
  created_at: string;
  updated_at: string;
}
