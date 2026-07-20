import { Injectable, Logger } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

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

  constructor(private readonly supabaseService: SupabaseService) {}

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

    const { error } = await this.db.from('notifications').insert(row as never);

    if (error) {
      this.logger.error(
        `Failed to insert notification for user ${userId}: ${error.message}`,
      );
    }
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

    const { error } = await this.db.from('notifications').insert(rows as never);

    if (error) {
      this.logger.error(
        `Failed to batch insert notifications (${userIds.length} users): ${error.message}`,
      );
    } else {
      this.logger.log(
        `Sent "${payload.type}" notification to ${userIds.length} users`,
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
}
