import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { NotificationsService } from './notifications.service';
import { NotificationsController } from './notifications.controller';
import { SupabaseModule } from '../supabase/supabase.module';
import { ExpiryNotificationService } from './expiry-notification.service';
import { FirebaseService } from './firebase.service';
import { NotificationDeliveryService } from './notification-delivery.service';

@Module({
  imports: [SupabaseModule, ConfigModule],
  controllers: [NotificationsController],
  providers: [
    NotificationsService,
    ExpiryNotificationService,
    FirebaseService,
    NotificationDeliveryService,
  ],
  exports: [NotificationsService, FirebaseService, NotificationDeliveryService],
})
export class NotificationsModule {}
