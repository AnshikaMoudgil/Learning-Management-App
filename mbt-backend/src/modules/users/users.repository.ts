import { Injectable, BadRequestException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class UsersRepository {
  constructor(private supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async findById(userId: string) {
    const { data, error } = await this.db
      .from('learner_profiles')
      .select('*')
      .eq('id', userId)
      .maybeSingle();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data;
  }

  async update(userId: string, updates: Record<string, any>) {
    const { data, error } = await this.db
      .from('learner_profiles')
      .update(updates)
      .eq('id', userId)
      .select()
      .single();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data;
  }

  async create(userId: string, profile: Record<string, any>) {
    const { data, error } = await this.db
      .from('learner_profiles')
      .insert({ id: userId, ...profile })
      .select()
      .single();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data;
  }

  async upsert(userId: string, profile: Record<string, any>) {
    const { data, error } = await this.db
      .from('learner_profiles')
      .upsert({ id: userId, ...profile }, { onConflict: 'id' })
      .select()
      .single();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data;
  }

  async upsertAvatarUrl(userId: string, url: string) {
    const { data, error } = await this.db
      .from('learner_profiles')
      .update({ avatar_url: url })
      .eq('id', userId)
      .select()
      .single();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data;
  }

  async updateLastLogin(userId: string, deviceId?: string) {
    const updates: Record<string, any> = {
      last_login_at: new Date().toISOString(),
    };

    if (deviceId) {
      updates.device_id = deviceId;
    }

    return this.update(userId, updates);
  }

  async getDeviceId(userId: string): Promise<string | null> {
    const profile = await this.findById(userId);
    return profile?.device_id ?? null;
  }
}
