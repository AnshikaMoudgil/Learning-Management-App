import { Injectable, BadRequestException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { Profile } from '../../common/types/profile.type';

@Injectable()
export class UsersRepository {
  constructor(private supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async findById(userId: string): Promise<Profile | null> {
    const { data, error } = await this.db
      .from('profiles')
      .select('*')
      .eq('id', userId)
      .maybeSingle();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data;
  }

  async update(
    userId: string,
    updates: Record<string, unknown>,
  ): Promise<Profile> {
    const { data, error } = await this.db
      .from('profiles')
      .update(updates as never)
      .eq('id', userId)
      .select()
      .single();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data;
  }

  async create(
    userId: string,
    profile: Record<string, unknown>,
  ): Promise<Profile> {
    const { data, error } = await this.db
      .from('profiles')
      .insert({ id: userId, ...profile } as never)
      .select()
      .single();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data;
  }

  async upsert(
    userId: string,
    profile: Record<string, unknown>,
  ): Promise<Profile> {
    const { data, error } = await this.db
      .from('profiles')
      .upsert({ id: userId, ...profile } as never, { onConflict: 'id' })
      .select()
      .single();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data;
  }

  async upsertAvatarUrl(userId: string, url: string): Promise<Profile> {
    const { data, error } = await this.db
      .from('profiles')
      .update({ avatar_url: url } as never)
      .eq('id', userId)
      .select()
      .single();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data;
  }

  async clearAvatarUrl(userId: string): Promise<void> {
    const { error } = await this.db.rpc('clear_avatar_url', {
      p_user_id: userId,
    } as never);

    if (error) {
      throw new BadRequestException(error.message);
    }
  }

  async updateLastLogin(
    userId: string,
  ): Promise<Profile> {
    const updates: Record<string, unknown> = {
      last_login_at: new Date().toISOString(),
    };

    return this.update(userId, updates);
  }
}
