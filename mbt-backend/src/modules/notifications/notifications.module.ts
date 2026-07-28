import { Module } from '@nestjs/common';
import { SupabaseModule } from '../supabase/supabase.module';
import { NotificationsController } from './notifications.controller';
import { NotificationsService } from './notifications.service';
import { NotificationsRepository } from './notifications.repository';
import { NotificationDeliveryService } from './notification-delivery.service';
import { FirebaseService } from './firebase.service';
import { ExpiryNotificationService } from './expiry-notification.service';

@Module({
  imports: [SupabaseModule],
  controllers: [NotificationsController],
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
