import { Injectable, Logger } from '@nestjs/common';
import { NotificationsRepository } from './notifications.repository';
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

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);

  constructor(
    private readonly notificationsRepository: NotificationsRepository,
    private readonly deliveryService: NotificationDeliveryService,
  ) {}

  async wasNotifiedRecently(
    userId: string,
    type: string,
    withinHours = 24,
  ): Promise<boolean> {
    const since = new Date(
      Date.now() - withinHours * 60 * 60 * 1000,
    ).toISOString();

    const count = await this.notificationsRepository.countRecentNotifications(userId, type, since);
    return count > 0;
  }

  async notify(userId: string, payload: NotificationPayload): Promise<void> {
    const row = {
      user_id: userId,
      type: payload.type,
      title: payload.title,
      body: payload.body,
      data: payload.data ?? null,
    };

    const data = await this.notificationsRepository.insertNotification(row);

    if (data) {
      this.deliveryService
        .deliverNotification([userId], {
          notificationId: data.id,
          type: payload.type,
          title: payload.title,
          body: payload.body,
          data: payload.data,
        })
        .catch((err: Error) =>
          this.logger.error(`Push delivery error: ${err.message}`),
        );
    }
  }

  async notifyAll(payload: NotificationPayload): Promise<void> {
    const BATCH_SIZE = 1000;
    let page = 0;
    let total = 0;
    do {
      const from = page * BATCH_SIZE;
      const to = from + BATCH_SIZE - 1;
      const { profiles, count } = await this.notificationsRepository.findAllProfileIds(from, to);
      total = count;
      const userIds = profiles.map((p) => p.id);
      if (userIds.length > 0) {
        await this.notifyMany(userIds, payload);
      }
      page++;
    } while (page * BATCH_SIZE < total);
  }

  async notifyMany(
    userIds: string[],
    payload: NotificationPayload,
  ): Promise<void> {
    if (!userIds.length) return;

    const rows = userIds.map((userId) => ({
      user_id: userId,
      type: payload.type,
      title: payload.title,
      body: payload.body,
      data: payload.data ?? null,
    }));

    const data = await this.notificationsRepository.insertNotifications(rows);

    if (data && data.length > 0) {
      const allUserIds = data.map((n) => n.user_id);
      this.deliveryService
        .deliverNotification(allUserIds, {
          type: payload.type,
          title: payload.title,
          body: payload.body,
          data: payload.data,
        })
        .catch((err: Error) =>
          this.logger.error(`Push delivery error: ${err.message}`),
        );
    }
  }

  async getNotifications(
    userId: string,
    page = 1,
    limit = 20,
  ): Promise<{ data: Record<string, unknown>[]; total: number }> {
    const from = (page - 1) * limit;
    const to = from + limit - 1;

    return this.notificationsRepository.findNotificationsByUserId(userId, from, to);
  }

  async getUnreadCount(userId: string): Promise<number> {
    return this.notificationsRepository.countUnreadNotifications(userId);
  }

  async markRead(notificationId: string, userId: string): Promise<void> {
    await this.notificationsRepository.markNotificationRead(notificationId, userId);
  }

  async markAllRead(userId: string): Promise<void> {
    await this.notificationsRepository.markAllNotificationsRead(userId);
  }

  async getSettings(userId: string): Promise<Record<string, boolean>> {
    const data = await this.notificationsRepository.findSettingsByUserId(userId);

    if (data) {
      return {
        liveClassReminders: data.live_class_reminders,
        courseExpiryAlerts: data.course_expiry_alerts,
        paymentConfirmations: data.payment_confirmations,
        deviceTransferStatus: data.device_transfer_status,
        promotionalMarketing: data.promotional_marketing,
        pushNotifications: data.push_notifications,
        email: data.email,
        sms: data.sms,
      };
    }

    return this.notificationsRepository.createDefaultSettings(userId);
  }

  async updateSettings(
    userId: string,
    dto: UpdateNotificationSettingsDto,
  ): Promise<Record<string, boolean>> {
    return this.notificationsRepository.upsertSettings(userId, dto);
  }
}
