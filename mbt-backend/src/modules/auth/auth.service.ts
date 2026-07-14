import {
  Injectable,
  BadRequestException,
  UnauthorizedException,
} from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { AuthResponseDto } from './dto/auth-response.dto';
import type { Session, User } from '@supabase/supabase-js';
import { Profile } from '../../common/types/profile.type';

@Injectable()
export class AuthService {
  constructor(private supabaseService: SupabaseService) {}

  private get client() {
    return this.supabaseService.getClient();
  }

  async sendOtp(phone: string): Promise<{ message: string }> {
    const { error } = await this.client.auth.signInWithOtp({ phone });

    if (error) {
      throw new BadRequestException(`Failed to send OTP: ${error.message}`);
    }

    await this.supabaseService.clearAuthSession();

    return { message: 'OTP sent successfully' };
  }

  async verifyOtp(phone: string, token: string): Promise<AuthResponseDto> {
    const { data, error } = await this.client.auth.verifyOtp({
      phone,
      token,
      type: 'sms',
    });

    if (error || !data.session) {
      throw new UnauthorizedException(
        error?.message || 'Invalid or expired OTP',
      );
    }

    const response = await this.buildAuthResponse(data.session, data.user!);

    await this.supabaseService.clearAuthSession();

    return response;
  }

  async authenticateWithGoogle(
    idToken: string,
    accessToken?: string,
  ): Promise<AuthResponseDto> {
    const { data, error } = await this.client.auth.signInWithIdToken({
      provider: 'google',
      token: idToken,
      access_token: accessToken,
    });

    if (error || !data.session) {
      throw new UnauthorizedException(
        error?.message || 'Google authentication failed',
      );
    }

    const response = await this.buildAuthResponse(data.session, data.user);

    await this.supabaseService.clearAuthSession();

    return response;
  }

  async getSession(userId: string): Promise<AuthResponseDto> {
    const profile = await this.checkSession(userId);

    const { data: userData, error: userError } =
      await this.client.auth.admin.getUserById(userId);

    if (userError || !userData?.user) {
      throw new UnauthorizedException('User not found');
    }

    return {
      accessToken: '',
      refreshToken: '',
      user: {
        id: userData.user.id,
        email: userData.user.email,
        phone: userData.user.phone,
        userMetadata: userData.user.user_metadata,
      },
      profile,
    };
  }

  private async checkSession(
    userId: string,
  ): Promise<AuthResponseDto['profile']> {
    const { data, error } = await this.client
      .from('profiles')
      .select('*')
      .eq('id', userId)
      .maybeSingle();

    if (error) {
      throw new BadRequestException(error.message);
    }

    if (!data) {
      return null;
    }

    const profile = data as Profile;

    if (profile.is_deleted) {
      throw new UnauthorizedException(
        'Your account has been deleted. Please contact support.',
      );
    }

    if (!profile.is_active) {
      throw new UnauthorizedException(
        'Your account is currently disabled or suspended.',
      );
    }

    return this.mapProfile(profile);
  }

  private async buildAuthResponse(
    session: Session,
    user: User,
  ): Promise<AuthResponseDto> {
    const profile = await this.checkSession(user.id);

    return {
      accessToken: session.access_token,
      refreshToken: session.refresh_token,
      expiresIn: session.expires_in,
      user: {
        id: user.id,
        email: user.email,
        phone: user.phone,
        userMetadata: user.user_metadata,
      },
      profile,
    };
  }

  private mapProfile(data: Profile): AuthResponseDto['profile'] {
    return {
      id: data.id,
      fullName: data.full_name ?? undefined,
      avatarUrl: data.avatar_url ?? undefined,
      role: data.role,
      status: data.status,
      about: data.about ?? undefined,
      isActive: data.is_active,
      onboardingCompleted: data.onboarding_completed,
      lastLoginAt: data.last_login_at ?? undefined,
    };
  }
}
