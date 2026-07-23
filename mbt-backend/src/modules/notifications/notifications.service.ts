import { Injectable, Logger, BadRequestException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

import { NotificationDeliveryService } from './notification-delivery.service';
import { UpdateNotificationSettingsDto } from './dto/update-settings.dto';

export type NotificationType =
  | 'session_created'
  | 'session_updated'
  | 'session_cancelled'
  | 'reminder_24h'
  | 'reminder_1h'
  | 'reminder_10min'
  | 'recording_ready'
  | 'session_live'
  | 'payment_confirmation'
  | 'expiry_alert'
  | 'expiry_expired'
  | 'device_login'
  | 'announcement';

export interface NotificationPayload {
  type: NotificationType;
  title: string;
  body: string;
  data?: Record<string, string>;
}

interface NotificationRow {
  user_id: string;
  type: string;
  title: string;
  body: string;
  data: Record<string, string> | null;
}

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);

  constructor(
    private readonly supabaseService: SupabaseService,
    private readonly deliveryService: NotificationDeliveryService,
  ) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async wasNotifiedRecently(
    userId: string,
    type: string,
    withinHours = 24,
  ): Promise<boolean> {
    const since = new Date(
      Date.now() - withinHours * 60 * 60 * 1000,
    ).toISOString();

    const { count, error } = await this.db
      .from('notifications')
      .select('*', { count: 'exact', head: true })
      .eq('user_id', userId)
      .eq('type', type)
      .gte('created_at', since);

    if (error) return false;
    return (count ?? 0) > 0;
  }

  async notify(userId: string, payload: NotificationPayload): Promise<void> {
    const row: NotificationRow = {
      user_id: userId,
      type: payload.type,
      title: payload.title,
      body: payload.body,
      data: payload.data ?? null,
    };

    const { data, error } = await this.db
      .from('notifications')
      .insert(row as never)
      .select()
      .single();

    if (error) {
      this.logger.error(
        `Failed to insert notification for user ${userId}: ${error.message}`,
      );
      return;
    }

    // Trigger push notification delivery asynchronously
    this.deliveryService.deliverNotification([userId], {
      notificationId: (data as any)?.id,
      type: payload.type,
      title: payload.title,
      body: payload.body,
      data: payload.data,
    }).catch(err => this.logger.error(`Push delivery error: ${err.message}`));
  }

  async notifyAll(payload: NotificationPayload): Promise<void> {
    const { data: profiles } = await this.db.from('profiles').select('id');
    const userIds = (profiles ?? []).map((p: { id: string }) => p.id);
    await this.notifyMany(userIds, payload);
  }

  async notifyMany(
    userIds: string[],
    payload: NotificationPayload,
  ): Promise<void> {
    if (!userIds.length) return;

    const rows: NotificationRow[] = userIds.map((userId) => ({
      user_id: userId,
      type: payload.type,
      title: payload.title,
      body: payload.body,
      data: payload.data ?? null,
    }));

    const { data, error } = await this.db
      .from('notifications')
      .insert(rows as never)
      .select();

    if (error) {
      this.logger.error(
        `Failed to batch insert notifications (${userIds.length} users): ${error.message}`,
      );
    } else {
      this.logger.log(
        `Sent "${payload.type}" notification to ${userIds.length} users`,
      );
      
      // Deliver push notifications asynchronously
      if (data && data.length > 0) {
        data.forEach((notification: any) => {
          this.deliveryService.deliverNotification([notification.user_id], {
            notificationId: notification.id,
            type: payload.type,
            title: payload.title,
            body: payload.body,
            data: payload.data,
          }).catch(err => this.logger.error(`Push delivery error for ${notification.user_id}: ${err.message}`));
        });
      }
    }
  }

  async getNotifications(
    userId: string,
    page = 1,
    limit = 20,
  ): Promise<{ data: Record<string, unknown>[]; total: number }> {
    const from = (page - 1) * limit;
    const to = from + limit - 1;

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

  async getUnreadCount(userId: string): Promise<number> {
    const { count, error } = await this.db
      .from('notifications')
      .select('*', { count: 'exact', head: true })
      .eq('user_id', userId)
      .eq('is_read', false);

    if (error) return 0;
    return count ?? 0;
  }

  async markRead(notificationId: string, userId: string): Promise<void> {
    await this.db
      .from('notifications')
      .update({ is_read: true })
      .eq('id', notificationId)
      .eq('user_id', userId);
  }

  async markAllRead(userId: string): Promise<void> {
    await this.db
      .from('notifications')
      .update({ is_read: true })
      .eq('user_id', userId)
      .eq('is_read', false);
  }

  async getSettings(userId: string): Promise<Record<string, boolean>> {
    const { data, error } = await this.db
      .from('notification_settings')
      .select('*')
      .eq('user_id', userId)
      .maybeSingle();

    if (error) {
      this.logger.error(`Failed to fetch settings: ${error.message}`);
      throw new BadRequestException(error.message);
    }

    if (data) {
      return mapRowToSettings(data);
    }

    // Lazy create default settings row
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
      this.logger.error(`Failed to create default settings: ${insertError.message}`);
      throw new BadRequestException(insertError.message);
    }

    return mapRowToSettings(newRow);
  }

  async updateSettings(
    userId: string,
    dto: UpdateNotificationSettingsDto,
  ): Promise<Record<string, boolean>> {
    const row = mapSettingsToRow(dto);
    row.updated_at = new Date().toISOString();

    const { data, error } = await this.db
      .from('notification_settings')
      .upsert({ user_id: userId, ...row } as never, { onConflict: 'user_id' })
      .select()
      .single();

    if (error) {
      this.logger.error(`Failed to update settings: ${error.message}`);
      throw new BadRequestException(error.message);
    }

    return mapRowToSettings(data);
  }
}

function mapRowToSettings(row: any) {
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

function mapSettingsToRow(dto: any) {
  const row: any = {};
  if (dto.liveClassReminders !== undefined) row.live_class_reminders = dto.liveClassReminders;
  if (dto.courseExpiryAlerts !== undefined) row.course_expiry_alerts = dto.courseExpiryAlerts;
  if (dto.paymentConfirmations !== undefined) row.payment_confirmations = dto.paymentConfirmations;
  if (dto.deviceTransferStatus !== undefined) row.device_transfer_status = dto.deviceTransferStatus;
  if (dto.promotionalMarketing !== undefined) row.promotional_marketing = dto.promotionalMarketing;
  if (dto.pushNotifications !== undefined) row.push_notifications = dto.pushNotifications;
  if (dto.email !== undefined) row.email = dto.email;
  if (dto.sms !== undefined) row.sms = dto.sms;
  return row;
}
