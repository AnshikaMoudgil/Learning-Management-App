import { Module } from '@nestjs/common';
import { BullModule } from '@nestjs/bullmq';
import { ZoomAuthService } from './zoom-auth.service';
import { ZoomOAuthService } from './zoom-oauth.service';
import { ZoomMeetingService } from './zoom-meeting.service';
import { ZoomSdkService } from './zoom-sdk.service';
import { ZoomRecordingService } from './zoom-recording.service';
import { ZoomAttendanceService } from './zoom-attendance.service';
import { ZoomWebhookController } from './zoom-webhook.controller';
import { ZoomOAuthController } from './zoom-oauth.controller';
import { ZoomController } from './zoom.controller';
import { SupabaseModule } from '../supabase/supabase.module';

@Module({
  imports: [
    SupabaseModule,
    BullModule.registerQueue({ name: 'zoom-task' }),
  ],
  controllers: [ZoomWebhookController, ZoomOAuthController, ZoomController],
  providers: [
    ZoomAuthService,
    ZoomOAuthService,
    ZoomMeetingService,
    ZoomSdkService,
    ZoomRecordingService,
    ZoomAttendanceService,
  ],
  exports: [
    ZoomAuthService,
    ZoomOAuthService,
    ZoomMeetingService,
    ZoomSdkService,
    ZoomRecordingService,
    ZoomAttendanceService,
  ],
})
export class ZoomModule {}
