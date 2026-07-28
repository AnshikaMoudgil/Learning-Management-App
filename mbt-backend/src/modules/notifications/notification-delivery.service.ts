import { Injectable, Logger } from '@nestjs/common';
import { NotificationsRepository } from './notifications.repository';
import { FirebaseService } from './firebase.service';
import { NotificationType } from './notifications.service';

export interface DeliveryPayload {
  notificationId?: string;
  type: NotificationType;
  title: string;
  body: string;
  data?: Record<string, string>;
}

@Injectable()
export class NotificationDeliveryService {
  private readonly logger = new Logger(NotificationDeliveryService.name);

  constructor(
    private readonly notificationsRepository: NotificationsRepository,
    private readonly firebaseService: FirebaseService,
  ) {}

  async deliverNotification(
    userIds: string[],
    payload: DeliveryPayload,
  ): Promise<void> {
    if (!userIds || userIds.length === 0) return;

    try {
      const settingsList = await this.notificationsRepository.findSettingsByUserIds(userIds);

      const allowedUserIds = userIds.filter((userId) => {
        const userSettings = settingsList?.find((s) => s.user_id === userId);
        if (!userSettings) return true;

        if (userSettings.push_notifications === false) return false;

        const type = payload.type;
        if (
          type === 'session_live' ||
          type === 'session_created' ||
          type === 'session_updated' ||
          type === 'reminder_24h' ||
          type === 'reminder_1h' ||
          type === 'reminder_10min'
        ) {
          return userSettings.live_class_reminders !== false;
        }
        if (type === 'expiry_alert' || type === 'expiry_expired') {
          return userSettings.course_expiry_alerts !== false;
        }
        if (type === 'payment_confirmation') {
          return userSettings.payment_confirmations !== false;
        }
        if (type === 'device_login') {
          return userSettings.device_transfer_status !== false;
        }
        if (type === 'announcement') {
          return userSettings.promotional_marketing !== false;
        }

        return true;
      });

      if (allowedUserIds.length === 0) {
        this.logger.log(
          `All targeted users have push notifications disabled for type: ${payload.type}`,
        );
        return;
      }

      const devices = await this.notificationsRepository.findActiveDeviceTokens(allowedUserIds);

      if (!devices || devices.length === 0) {
        this.logger.log(
          `No active FCM tokens found for users: ${userIds.join(', ')}`,
        );
        return;
      }

      const tokens = (devices as any[])
        .map((d: { fcm_token: string | null }) => d.fcm_token)
        .filter((t): t is string => !!t);

      if (tokens.length === 0) return;

      const pushData: Record<string, string> = {};

      if (payload.notificationId) {
        pushData.notificationId = payload.notificationId;
      }
      pushData.type = payload.type;

      if (payload.data) {
        Object.entries(payload.data).forEach(([key, value]) => {
          if (value !== undefined && value !== null) {
            pushData[key] = String(value);
          }
        });
      }

      this.logger.log(
        `Delivering push notification to ${tokens.length} tokens.`,
      );
      await this.firebaseService.sendPushNotification(
        tokens,
        payload.title,
        payload.body,
        pushData,
      );
    } catch (e) {
      this.logger.error(
        `Failed to deliver push notification: ${(e as Error).message}`,
      );
    }
  }
}
