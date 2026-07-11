import { Injectable, BadRequestException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { Device } from '../../common/types/device.type';

@Injectable()
export class DevicesRepository {
  constructor(private supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async findByUserId(userId: string): Promise<Device[]> {
    const { data, error } = await this.db
      .from('devices')
      .select('*')
      .eq('user_id', userId)
      .order('last_seen_at', { ascending: false });

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data ?? [];
  }

  async findActiveByUserId(userId: string): Promise<Device | null> {
    const { data, error } = await this.db
      .from('devices')
      .select('*')
      .eq('user_id', userId)
      .eq('is_active', true)
      .maybeSingle();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data;
  }

  async findAnyByUserId(userId: string): Promise<Device | null> {
    const { data, error } = await this.db
      .from('devices')
      .select('*')
      .eq('user_id', userId)
      .maybeSingle();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data;
  }

  async findByUserAndFingerprint(
    userId: string,
    fingerprint: string,
  ): Promise<Device | null> {
    const { data, error } = await this.db
      .from('devices')
      .select('*')
      .eq('user_id', userId)
      .eq('fingerprint', fingerprint)
      .maybeSingle();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data;
  }

  async create(
    userId: string,
    fingerprint: string,
    platform?: string,
  ): Promise<Device> {
    const { data, error } = await this.db
      .from('devices')
      .insert({
        user_id: userId,
        fingerprint,
        platform: platform ?? null,
      } as never)
      .select()
      .single();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data;
  }

  async updateLastSeen(deviceId: string): Promise<Device> {
    const { data, error } = await this.db
      .from('devices')
      .update({ last_seen_at: new Date().toISOString() } as never)
      .eq('id', deviceId)
      .select()
      .single();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data;
  }
}
