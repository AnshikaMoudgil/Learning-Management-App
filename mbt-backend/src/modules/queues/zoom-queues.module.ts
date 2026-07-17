import { Module } from '@nestjs/common';
import { BullModule } from '@nestjs/bullmq';
import { ZoomModule } from '../zoom/zoom.module';
import { SupabaseModule } from '../supabase/supabase.module';
import { NotificationsModule } from '../notifications/notifications.module';
import { ZoomTaskProcessor } from './processors/zoom-task.processor';

@Module({
  imports: [
    SupabaseModule,
    ZoomModule,
    NotificationsModule,
    BullModule.registerQueue({ name: 'zoom-task' }),
  ],
  providers: [ZoomTaskProcessor],
  exports: [BullModule],
})
export class ZoomQueuesModule {}
