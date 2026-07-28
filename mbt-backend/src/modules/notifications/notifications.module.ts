import { Module } from '@nestjs/common';
import { SupabaseModule } from '../supabase/supabase.module';
import { NotificationsService } from './notifications.service';
import { NotificationsRepository } from './notifications.repository';
import { NotificationDeliveryService } from './notification-delivery.service';
import { FirebaseService } from './firebase.service';
import { ExpiryNotificationService } from './expiry-notification.service';

@Module({
  imports: [SupabaseModule],
  providers: [
    NotificationsService,
    NotificationsRepository,
    NotificationDeliveryService,
    FirebaseService,
    ExpiryNotificationService,
  ],
  exports: [NotificationsService],
})
export class NotificationsModule {}
