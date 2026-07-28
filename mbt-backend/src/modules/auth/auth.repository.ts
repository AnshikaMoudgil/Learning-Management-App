import { Injectable, BadRequestException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { Profile } from '../../common/types/profile.type';

@Injectable()
export class AuthRepository {
  constructor(private readonly supabaseService: SupabaseService) {}

  private get client() {
    return this.supabaseService.getClient();
  }

  async findProfileById(userId: string): Promise<Profile | null> {
    const { data, error } = await this.client
      .from('profiles')
      .select(
        'id, full_name, avatar_url, phone, email, role, status, about, is_active, is_deleted, onboarding_completed, last_login_at',
      )
      .eq('id', userId)
      .maybeSingle();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data as Profile | null;
  }
}
