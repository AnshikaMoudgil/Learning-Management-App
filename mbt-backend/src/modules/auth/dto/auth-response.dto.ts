import { UserRole, UserStatus } from '../../../common/types/profile.type';

export class AuthResponseDto {
  accessToken: string;
  refreshToken: string;
  expiresIn?: number;
  user: {
    id: string;
    email?: string;
    phone?: string;
    userMetadata?: Record<string, any>;
  };
  profile: {
    id: string;
    fullName?: string;
    avatarUrl?: string;
    phone?: string;
    email?: string;
    role: UserRole;
    status: UserStatus;
    about?: string;
    isActive: boolean;
    onboardingCompleted: boolean;
    lastLoginAt?: string;
  } | null;
}
