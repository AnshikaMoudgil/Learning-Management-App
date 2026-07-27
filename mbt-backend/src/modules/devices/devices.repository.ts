import { Injectable, BadRequestException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { Device } from '../../common/types/device.type';
import { DeviceChangeRequest } from '../../common/types/device-change-request.type';

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

    return (data ?? []) as Device[];
  }

  async findActiveByUserId(userId: string): Promise<Device | null> {
    const { data, error } = await this.db
      .from('devices')
      .select('id, fingerprint, platform, is_active, bound_at, last_seen_at, created_at, updated_at')
      .eq('user_id', userId)
      .eq('is_active', true)
      .maybeSingle();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data as Device | null;
  }

  async findByUserAndFingerprint(
    userId: string,
    fingerprint: string,
  ): Promise<Device | null> {
    const { data, error } = await this.db
      .from('devices')
      .select('id')
      .eq('user_id', userId)
      .eq('fingerprint', fingerprint)
      .maybeSingle();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data as Device | null;
  }

  async create(
    userId: string,
    fingerprint: string,
    platform?: string,
    fcmToken?: string,
  ): Promise<Device> {
    const { data, error } = await this.db
      .from('devices')
      .insert({
        user_id: userId,
        fingerprint,
        platform: platform ?? null,
        fcm_token: fcmToken ?? null,
      } as never)
      .select()
      .single();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data as Device;
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

    return data as Device;
  }

  async upsertDevice(
    userId: string,
    fingerprint: string,
    platform?: string,
    fcmToken?: string,
  ): Promise<Device> {
    const updateObj: Record<string, any> = {
      user_id: userId,
      fingerprint,
      platform: platform ?? null,
      is_active: true,
      last_seen_at: new Date().toISOString(),
    };
    if (fcmToken !== undefined) {
      updateObj.fcm_token = fcmToken;
    }
    const { data, error } = await this.db
      .from('devices')
      .upsert(updateObj as never, { onConflict: 'user_id, fingerprint' })
      .select()
      .single();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data as Device;
  }

  async deactivateDevice(deviceId: string): Promise<void> {
    const { error } = await this.db
      .from('devices')
      .update({ is_active: false } as never)
      .eq('id', deviceId);

    if (error) {
      throw new BadRequestException(error.message);
    }
  }

  // --- Device Change Requests ---

  async createChangeRequest(
    userId: string,
    newFingerprint: string,
    reason?: string,
    oldFingerprint?: string,
  ): Promise<DeviceChangeRequest> {
    const { data, error } = await this.db
      .from('device_change_requests')
      .insert({
        user_id: userId,
        old_fingerprint: oldFingerprint ?? null,
        new_fingerprint: newFingerprint,
        reason: reason ?? null,
      } as never)
      .select()
      .single();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data as DeviceChangeRequest;
  }

  async findPendingByUserAndFingerprint(
    userId: string,
    fingerprint: string,
  ): Promise<DeviceChangeRequest | null> {
    const { data, error } = await this.db
      .from('device_change_requests')
      .select('*')
      .eq('user_id', userId)
      .eq('new_fingerprint', fingerprint)
      .eq('status', 'pending')
      .maybeSingle();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data as DeviceChangeRequest | null;
  }

  async findApprovedByUserAndFingerprint(
    userId: string,
    fingerprint: string,
  ): Promise<DeviceChangeRequest | null> {
    const { data, error } = await this.db
      .from('device_change_requests')
      .select('id')
      .eq('user_id', userId)
      .eq('new_fingerprint', fingerprint)
      .eq('status', 'approved')
      .maybeSingle();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data as DeviceChangeRequest | null;
  }

  async findUserChangeRequests(userId: string): Promise<DeviceChangeRequest[]> {
    const { data, error } = await this.db
      .from('device_change_requests')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false });

    if (error) {
      throw new BadRequestException(error.message);
    }

    return (data ?? []) as DeviceChangeRequest[];
  }

  async findLastApprovedRequest(
    userId: string,
  ): Promise<DeviceChangeRequest | null> {
    const { data, error } = await this.db
      .from('device_change_requests')
      .select('reviewed_at')
      .eq('user_id', userId)
      .eq('status', 'approved')
      .order('reviewed_at', { ascending: false })
      .limit(1)
      .maybeSingle();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data as DeviceChangeRequest | null;
  }

  async findChangeRequestById(id: string): Promise<DeviceChangeRequest | null> {
    const { data, error } = await this.db
      .from('device_change_requests')
      .select('id, user_id, new_fingerprint')
      .eq('id', id)
      .maybeSingle();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data as DeviceChangeRequest | null;
  }

  async findAllPendingRequests(): Promise<DeviceChangeRequest[]> {
    const { data, error } = await this.db
      .from('device_change_requests')
      .select('*')
      .eq('status', 'pending')
      .order('created_at', { ascending: false });

    if (error) {
      throw new BadRequestException(error.message);
    }

    return (data ?? []) as DeviceChangeRequest[];
  }

  async updateChangeRequestStatus(
    requestId: string,
    status: 'approved' | 'rejected',
    reviewerId: string,
  ): Promise<DeviceChangeRequest> {
    const { data, error } = await this.db
      .from('device_change_requests')
      .update({
        status,
        reviewed_by: reviewerId,
        reviewed_at: new Date().toISOString(),
      } as never)
      .eq('id', requestId)
      .select()
      .single();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data as DeviceChangeRequest;
  }

  async unbindFcmToken(userId: string, fingerprint: string): Promise<void> {
    const { error } = await this.db
      .from('devices')
      .update({ fcm_token: null } as never)
      .eq('user_id', userId)
      .eq('fingerprint', fingerprint);

    if (error) {
      throw new BadRequestException(error.message);
    }
  }

  async nullifyFcmToken(token: string): Promise<void> {
    const { error } = await this.db
      .from('devices')
      .update({ fcm_token: null } as never)
      .eq('fcm_token', token);

    if (error) {
      throw new BadRequestException(error.message);
    }
  }
}
