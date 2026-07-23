import { Injectable, Logger } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { FirebaseService } from './firebase.service';
import { NotificationType } from './notifications.service';

export interface DeliveryPayload {
  notificationId?: string;
  type: NotificationType;
  title: string;
  body: string;
  data?: Record<string, string>;
}

interface NotificationSettingsRow {
  user_id: string;
  push_notifications: boolean | null;
  live_class_reminders: boolean | null;
  course_expiry_alerts: boolean | null;
  payment_confirmations: boolean | null;
  device_transfer_status: boolean | null;
  promotional_marketing: boolean | null;
}

@Injectable()
export class NotificationDeliveryService {
  private readonly logger = new Logger(NotificationDeliveryService.name);

  constructor(
    private readonly supabaseService: SupabaseService,
    private readonly firebaseService: FirebaseService,
  ) {}

  async deliverNotification(
    userIds: string[],
    payload: DeliveryPayload,
  ): Promise<void> {
    if (!userIds || userIds.length === 0) return;

    try {
      const db = this.supabaseService.getClient();

      // Retrieve notification settings for the targeted users
      const { data: settingsRaw, error: settingsError } = await db
        .from('notification_settings')
        .select('*')
        .in('user_id', userIds);

      if (settingsError) {
        this.logger.error(`Failed to fetch notification settings: ${settingsError.message}`);
      }

      const settingsList = settingsRaw as NotificationSettingsRow[] | null;

      // Filter userIds based on their preferences
      const allowedUserIds = userIds.filter((userId) => {
        const userSettings: NotificationSettingsRow | undefined = settingsList?.find(
          (s) => s.user_id === userId,
        );
        if (!userSettings) return true; // Default to true if no settings row exists yet

        // 1. Check if push notifications are enabled globally
        if (userSettings.push_notifications === false) return false;

        // 2. Check specific category preference
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
        this.logger.log(`All targeted users have push notifications disabled for type: ${payload.type}`);
        return;
      }

      // Retrieve all active FCM tokens for the filtered targeted users
      const { data: devices, error } = await db
        .from('devices')
        .select('fcm_token')
        .in('user_id', allowedUserIds)
        .eq('is_active', true)
        .not('fcm_token', 'is', null);

      if (error) {
        this.logger.error(`Failed to fetch active device tokens: ${error.message}`);
        return;
      }

      if (!devices || devices.length === 0) {
        this.logger.log(`No active FCM tokens found for users: ${userIds.join(', ')}`);
        return;
      }

      const tokens = (devices as any[])
        .map((d: { fcm_token: string | null }) => d.fcm_token)
        .filter((t): t is string => !!t);

      if (tokens.length === 0) return;

      // Construct rich data payload for mobile navigation
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

      this.logger.log(`Delivering push notification to ${tokens.length} tokens.`);
      await this.firebaseService.sendPushNotification(
        tokens,
        payload.title,
        payload.body,
        pushData,
      );
    } catch (e) {
      this.logger.error(`Failed to deliver push notification: ${(e as Error).message}`);
    }
  }
}
