import { Injectable, BadRequestException, UnauthorizedException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { AuthResponseDto } from './dto/auth-response.dto';

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

    return { message: 'OTP sent successfully' };
  }

  async verifyOtp(phone: string, token: string, deviceId?: string): Promise<AuthResponseDto> {
    const { data, error } = await this.client.auth.verifyOtp({
      phone,
      token,
      type: 'sms',
    });

    if (error || !data.session) {
      throw new UnauthorizedException(error?.message || 'Invalid or expired OTP');
    }

    return this.buildAuthResponse(data.session, data.user, deviceId);
  }

  async authenticateWithGoogle(idToken: string, accessToken?: string, deviceId?: string): Promise<AuthResponseDto> {
    const { data, error } = await this.client.auth.signInWithIdToken({
      provider: 'google',
      token: idToken,
      access_token: accessToken,
    });

    if (error || !data.session) {
      throw new UnauthorizedException(error?.message || 'Google authentication failed');
    }

    return this.buildAuthResponse(data.session, data.user, deviceId);
  }

  async getSession(userId: string, deviceId?: string): Promise<AuthResponseDto> {
    const profile = await this.checkSession(userId, deviceId);

    // Bind device on session check if deviceId provided and not yet bound (covers web Google OAuth)
    if (deviceId && profile && !profile.deviceId) {
      await this.client
        .from('learner_profiles')
        .update({ device_id: deviceId })
        .eq('id', userId);

      profile.deviceId = deviceId;
    }

    const { data: userData, error: userError } = await this.client.auth.admin.getUserById(userId);

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

  private async checkSession(userId: string, deviceId?: string): Promise<AuthResponseDto['profile']> {
    const { data, error } = await this.client
      .from('learner_profiles')
      .select('*')
      .eq('id', userId)
      .maybeSingle();

    if (error) {
      throw new BadRequestException(error.message);
    }

    if (!data) {
      return null;
    }

    if (data.is_deleted) {
      throw new UnauthorizedException('Your account has been deleted. Please contact support.');
    }

    if (!data.is_active) {
      throw new UnauthorizedException('Your account is currently disabled or suspended.');
    }

    if (deviceId && data.device_id && data.device_id !== deviceId) {
      throw new UnauthorizedException('DEVICE_MISMATCH');
    }

    return this.mapProfile(data);
  }

  private async buildAuthResponse(session: any, user: any, deviceId?: string): Promise<AuthResponseDto> {
    const profile = await this.checkSession(user.id, deviceId);

    // Bind device on first login if deviceId provided
    if (deviceId && profile && !profile.deviceId) {
      await this.client
        .from('learner_profiles')
        .update({ device_id: deviceId })
        .eq('id', user.id);

      profile.deviceId = deviceId;
    }

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

  private mapProfile(data: any): AuthResponseDto['profile'] {
    return {
      id: data.id,
      fullName: data.full_name,
      avatarUrl: data.avatar_url,
      isActive: data.is_active,
      onboardingCompleted: data.onboarding_completed,
      deviceId: data.device_id,
      lastLoginAt: data.last_login_at,
    };
  }
}
