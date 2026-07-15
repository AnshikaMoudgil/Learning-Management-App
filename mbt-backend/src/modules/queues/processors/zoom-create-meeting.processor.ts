import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Logger } from '@nestjs/common';
import { Job } from 'bullmq';
import { ZoomMeetingService } from '../../zoom/zoom-meeting.service';
import { SupabaseService } from '../../supabase/supabase.service';

interface CreateMeetingJob {
  sessionId: string;
  instructorId: string;
  title: string;
  startTime: string;
  duration: number;
}

@Processor('zoom-create-meeting')
export class ZoomCreateMeetingProcessor extends WorkerHost {
  private readonly logger = new Logger(ZoomCreateMeetingProcessor.name);

  constructor(
    private readonly zoomMeetingService: ZoomMeetingService,
    private readonly supabaseService: SupabaseService,
  ) {
    super();
  }

  private get db() {
    return this.supabaseService.getClient();
  }

  async process(job: Job<CreateMeetingJob>): Promise<void> {
    const { sessionId, instructorId, title, startTime, duration } = job.data;
    this.logger.log(`Creating Zoom meeting for session ${sessionId}`);

    const meeting = await this.zoomMeetingService.createMeeting(
      instructorId,
      title,
      startTime,
      duration,
    );

    const { error } = await (
      this.db.from('live_session_meetings') as any
    ).insert({
      session_id: sessionId,
      provider: 'zoom',
      meeting_id: String(meeting.id),
      meeting_uuid: meeting.uuid,
      password: meeting.password,
      join_url: meeting.join_url,
      start_url: meeting.start_url,
      host_user_id: meeting.host_id,
      waiting_room: true,
      auto_recording: true,
      provider_metadata: meeting,
    });

    if (error) {
      this.logger.error(
        `Failed to save meeting for session ${sessionId}: ${error.message}`,
      );
      throw new Error(error.message);
    }

    this.logger.log(
      `Zoom meeting ${meeting.id} created and saved for session ${sessionId}`,
    );
  }
}
