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
