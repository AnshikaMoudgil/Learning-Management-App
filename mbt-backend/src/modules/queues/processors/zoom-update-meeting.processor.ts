import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Logger } from '@nestjs/common';
import { Job } from 'bullmq';
import { ZoomMeetingService } from '../../zoom/zoom-meeting.service';

interface UpdateMeetingJob {
  instructorId: string;
  meetingId: string;
  topic?: string;
  start_time?: string;
  duration?: number;
}

@Processor('zoom-update-meeting')
export class ZoomUpdateMeetingProcessor extends WorkerHost {
  private readonly logger = new Logger(ZoomUpdateMeetingProcessor.name);

  constructor(private readonly zoomMeetingService: ZoomMeetingService) {
    super();
  }

  async process(job: Job<UpdateMeetingJob>): Promise<void> {
    const { instructorId, meetingId, ...patch } = job.data;
    this.logger.log(`Updating Zoom meeting ${meetingId}`);

    await this.zoomMeetingService.updateMeeting(instructorId, meetingId, patch);

    this.logger.log(`Zoom meeting ${meetingId} updated`);
  }
}
