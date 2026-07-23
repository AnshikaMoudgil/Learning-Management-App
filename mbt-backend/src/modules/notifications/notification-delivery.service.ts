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

      // Retrieve all active FCM tokens for the targeted users
      const { data: devices, error } = await db
        .from('devices')
        .select('fcm_token')
        .in('user_id', userIds)
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
