import { Module } from '@nestjs/common';
import { BullModule } from '@nestjs/bullmq';
import { ZoomModule } from '../zoom/zoom.module';
import { SupabaseModule } from '../supabase/supabase.module';
import { ZoomCreateMeetingProcessor } from './processors/zoom-create-meeting.processor';
import { ZoomUpdateMeetingProcessor } from './processors/zoom-update-meeting.processor';
import { ZoomDeleteMeetingProcessor } from './processors/zoom-delete-meeting.processor';
import { ZoomDownloadRecordingProcessor } from './processors/zoom-download-recording.processor';
import { ZoomUploadRecordingProcessor } from './processors/zoom-upload-recording.processor';
import { ZoomSendRemindersProcessor } from './processors/zoom-send-reminders.processor';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [
    SupabaseModule,
    ZoomModule,
    NotificationsModule,
    BullModule.registerQueue(
      { name: 'zoom-create-meeting' },
      { name: 'zoom-update-meeting' },
      { name: 'zoom-delete-meeting' },
      { name: 'zoom-download-recording' },
      { name: 'zoom-upload-recording' },
      { name: 'zoom-send-reminders' },
    ),
  ],
  providers: [
    ZoomCreateMeetingProcessor,
    ZoomUpdateMeetingProcessor,
    ZoomDeleteMeetingProcessor,
    ZoomDownloadRecordingProcessor,
    ZoomUploadRecordingProcessor,
    ZoomSendRemindersProcessor,
  ],
})
export class ZoomQueuesModule {}
