import { Injectable, BadRequestException, Logger } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { UpdateNotificationSettingsDto } from './dto/update-settings.dto';

interface NotificationRow {
  user_id: string;
  type: string;
  title: string;
  body: string;
  data: Record<string, string> | null;
}

interface NotificationSettingsRow {
  user_id: string;
  live_class_reminders: boolean;
  course_expiry_alerts: boolean;
  payment_confirmations: boolean;
  device_transfer_status: boolean;
  promotional_marketing: boolean;
  push_notifications: boolean;
  email: boolean;
  sms: boolean;
  updated_at?: string;
}

function mapRowToSettings(row: NotificationSettingsRow): Record<string, boolean> {
  return {
    liveClassReminders: row.live_class_reminders,
    courseExpiryAlerts: row.course_expiry_alerts,
    paymentConfirmations: row.payment_confirmations,
    deviceTransferStatus: row.device_transfer_status,
    promotionalMarketing: row.promotional_marketing,
    pushNotifications: row.push_notifications,
    email: row.email,
    sms: row.sms,
  };
}

function mapSettingsToRow(dto: UpdateNotificationSettingsDto): Partial<NotificationSettingsRow> {
  const row: Partial<NotificationSettingsRow> = {};
  if (dto.liveClassReminders !== undefined)
    row.live_class_reminders = dto.liveClassReminders;
  if (dto.courseExpiryAlerts !== undefined)
    row.course_expiry_alerts = dto.courseExpiryAlerts;
  if (dto.paymentConfirmations !== undefined)
    row.payment_confirmations = dto.paymentConfirmations;
  if (dto.deviceTransferStatus !== undefined)
    row.device_transfer_status = dto.deviceTransferStatus;
  if (dto.promotionalMarketing !== undefined)
    row.promotional_marketing = dto.promotionalMarketing;
  if (dto.pushNotifications !== undefined)
    row.push_notifications = dto.pushNotifications;
  if (dto.email !== undefined) row.email = dto.email;
  if (dto.sms !== undefined) row.sms = dto.sms;
  return row;
}

@Injectable()
export class NotificationsRepository {
  private readonly logger = new Logger(NotificationsRepository.name);

  constructor(private readonly supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  // --- notifications table ---

  async countRecentNotifications(userId: string, type: string, since: string) {
    const { count, error } = await this.db
      .from('notifications')
      .select('*', { count: 'exact', head: true })
      .eq('user_id', userId)
      .eq('type', type)
      .gte('created_at', since);

    if (error) return 0;
    return count ?? 0;
  }

  async insertNotification(row: NotificationRow) {
    const { data, error } = await this.db
      .from('notifications')
      .insert(row as never)
      .select()
      .single();

    if (error) {
      this.logger.error(
        `Failed to insert notification for user ${row.user_id}: ${error.message}`,
      );
      return null;
    }

    return data as { id: string; user_id: string } | null;
  }

  async insertNotifications(rows: NotificationRow[]) {
    const { data, error } = await this.db
      .from('notifications')
      .insert(rows as never)
      .select();

    if (error) {
      this.logger.error(
        `Failed to batch insert notifications (${rows.length} users): ${error.message}`,
      );
      return null;
    }

    return data as { id: string; user_id: string }[];
  }

  async findNotificationsByUserId(userId: string, from: number, to: number) {
    const { data, error, count } = await this.db
      .from('notifications')
      .select('*', { count: 'exact' })
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
      .range(from, to);

    if (error) {
      this.logger.error(`Failed to fetch notifications: ${error.message}`);
      return { data: [], total: 0 };
    }
    return { data: data ?? [], total: count ?? 0 };
  }

  async countUnreadNotifications(userId: string) {
    const { count, error } = await this.db
      .from('notifications')
      .select('*', { count: 'exact', head: true })
      .eq('user_id', userId)
      .eq('is_read', false);

    if (error) return 0;
    return count ?? 0;
  }

  async markNotificationRead(notificationId: string, userId: string) {
    await this.db
      .from('notifications')
      .update({ is_read: true })
      .eq('id', notificationId)
      .eq('user_id', userId);
  }

  async markAllNotificationsRead(userId: string) {
    await this.db
      .from('notifications')
      .update({ is_read: true })
      .eq('user_id', userId)
      .eq('is_read', false);
  }

  // --- profiles table ---

  async findAllProfileIds(from: number, to: number) {
    const { data: profiles, count } = await this.db
      .from('profiles')
      .select('id', { count: 'exact' })
      .range(from, to);

    return { profiles: ((profiles ?? []) as { id: string }[]), count: count ?? 0 };
  }

  // --- notification_settings table ---

  async findSettingsByUserId(userId: string) {
    const { data, error } = await this.db
      .from('notification_settings')
      .select('*')
      .eq('user_id', userId)
      .maybeSingle();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data as NotificationSettingsRow | null;
  }

  async createDefaultSettings(userId: string) {
    const defaultRow = {
      user_id: userId,
      live_class_reminders: true,
      course_expiry_alerts: true,
      payment_confirmations: true,
      device_transfer_status: true,
      promotional_marketing: true,
      push_notifications: true,
      email: true,
      sms: true,
    };

    const { data: newRow, error: insertError } = await this.db
      .from('notification_settings')
      .insert(defaultRow as never)
      .select()
      .single();

    if (insertError) {
      throw new BadRequestException(insertError.message);
    }

    return mapRowToSettings(newRow as NotificationSettingsRow);
  }

  async upsertSettings(userId: string, dto: UpdateNotificationSettingsDto) {
    const row = mapSettingsToRow(dto);
    (row as Record<string, unknown>).updated_at = new Date().toISOString();

    const { data, error } = await this.db
      .from('notification_settings')
      .upsert({ user_id: userId, ...row } as never, { onConflict: 'user_id' })
      .select()
      .single();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return mapRowToSettings(data as NotificationSettingsRow);
  }

  // --- For notification-delivery service ---

  async findSettingsByUserIds(userIds: string[]) {
    const { data: settingsRaw, error: settingsError } = await this.db
      .from('notification_settings')
      .select('*')
      .in('user_id', userIds);

    if (settingsError) {
      this.logger.error(
        `Failed to fetch notification settings: ${settingsError.message}`,
      );
    }

    return settingsRaw as NotificationSettingsRow[] | null;
  }

  async findActiveDeviceTokens(userIds: string[]) {
    const { data: devices, error } = await this.db
      .from('devices')
      .select('fcm_token')
      .in('user_id', userIds)
      .eq('is_active', true)
      .not('fcm_token', 'is', null);

    if (error) {
      this.logger.error(
        `Failed to fetch active device tokens: ${error.message}`,
      );
      return null;
    }

    return devices as { fcm_token: string | null }[];
  }

  // --- For expiry-notification service ---

  async findExpiringEnrollments(nowISO: string, in30Days: string) {
    const { data, error } = await this.db
      .from('enrollments')
      .select('user_id, course_id, validity_end_at, courses(title)')
      .eq('status', 'active')
      .gt('validity_end_at', nowISO)
      .lte('validity_end_at', in30Days);

    if (error) {
      this.logger.error(
        `Failed to fetch expiring enrollments: ${error.message}`,
      );
      return null;
    }

    return data as unknown[] | null;
  }

  async findExpiredEnrollments(nowISO: string) {
    const { data, error } = await this.db
      .from('enrollments')
      .select('user_id, course_id, validity_end_at, courses(title)')
      .eq('status', 'active')
      .lt('validity_end_at', nowISO);

    if (error) {
      this.logger.error(
        `Failed to fetch expired enrollments: ${error.message}`,
      );
      return null;
    }

    return data as unknown[] | null;
  }

  // --- For firebase service ---

  async nullifyFcmTokens(tokens: string[]) {
    const db = this.supabaseService.getClient();
    const { error } = await db
      .from('devices')
      .update({ fcm_token: null } as never)
      .in('fcm_token', tokens);

    if (error) {
      this.logger.error(
        `Failed to nullify invalid FCM tokens: ${error.message}`,
      );
    }
  }
}
