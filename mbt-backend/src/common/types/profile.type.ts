export type UserRole = 'learner' | 'admin' | 'superadmin' | 'instructor';
export type UserStatus = 'ACTIVE' | 'SUSPENDED' | 'BLOCKED';

export interface Profile {
  id: string;
  full_name: string | null;
  avatar_url: string | null;
  phone: string | null;
  email: string | null;
  role: UserRole;
  status: UserStatus;
  about: string | null;
  is_active: boolean;
  is_deleted: boolean;
  onboarding_completed: boolean;
  last_login_at: string | null;
  created_at: string;
  updated_at: string;
}
