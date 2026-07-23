import { Injectable, BadRequestException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { Profile } from '../../common/types/profile.type';

@Injectable()
export class UsersRepository {
  private readonly PROFILE_COLUMNS =
    'id, full_name, avatar_url, phone, email, role, status, about, is_active, last_login_at, created_at, allowed_sections, allowed_actions';

  constructor(private supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async findById(userId: string): Promise<Profile | null> {
    const { data, error } = await this.db
      .from('profiles')
      .select(this.PROFILE_COLUMNS)
      .eq('id', userId)
      .maybeSingle();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data as Profile | null;
  }

  async update(
    userId: string,
    updates: Record<string, unknown>,
  ): Promise<Profile> {
    const { data, error } = await this.db
      .from('profiles')
      .update(updates as never)
      .eq('id', userId)
      .select(this.PROFILE_COLUMNS)
      .single();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data as Profile;
  }

  async create(
    userId: string,
    profile: Record<string, unknown>,
  ): Promise<Profile> {
    const { data, error } = await this.db
      .from('profiles')
      .insert({ id: userId, ...profile } as never)
      .select(this.PROFILE_COLUMNS)
      .single();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data as Profile;
  }

  async upsert(
    userId: string,
    profile: Record<string, unknown>,
  ): Promise<Profile> {
    const { data, error } = await this.db
      .from('profiles')
      .upsert({ id: userId, ...profile } as never, { onConflict: 'id' })
      .select(this.PROFILE_COLUMNS)
      .single();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data as Profile;
  }

  async upsertAvatarUrl(userId: string, url: string): Promise<Profile> {
    const { data, error } = await this.db
      .from('profiles')
      .update({ avatar_url: url } as never)
      .eq('id', userId)
      .select(this.PROFILE_COLUMNS)
      .single();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data as Profile;
  }

  async clearAvatarUrl(userId: string): Promise<void> {
    const { error } = await this.db.rpc('clear_avatar_url', {
      p_user_id: userId,
    } as never);

    if (error) {
      throw new BadRequestException(error.message);
    }
  }

  async updateLastLogin(userId: string): Promise<Profile> {
    const updates: Record<string, unknown> = {
      last_login_at: new Date().toISOString(),
    };

    return this.update(userId, updates);
  }
}
