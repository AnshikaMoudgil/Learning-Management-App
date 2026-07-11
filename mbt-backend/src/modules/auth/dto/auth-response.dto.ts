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
    isActive: boolean;
    onboardingCompleted: boolean;
    deviceId?: string;
    lastLoginAt?: string;
  } | null;
}
