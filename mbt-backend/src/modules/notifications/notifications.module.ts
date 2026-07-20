import { Module } from '@nestjs/common';
import { NotificationsService } from './notifications.service';
import { NotificationsController } from './notifications.controller';
import { SupabaseModule } from '../supabase/supabase.module';
import { ExpiryNotificationService } from './expiry-notification.service';

@Module({
  imports: [SupabaseModule],
  controllers: [NotificationsController],
  providers: [NotificationsService, ExpiryNotificationService],
  exports: [NotificationsService],
})
export class NotificationsModule {}
