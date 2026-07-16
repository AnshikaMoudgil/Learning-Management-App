import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Logger } from '@nestjs/common';
import { Job } from 'bullmq';
import { ZoomMeetingService } from '../../zoom/zoom-meeting.service';

interface DeleteMeetingJob {
  instructorId: string;
  meetingId: string;
}

@Processor('zoom-delete-meeting')
export class ZoomDeleteMeetingProcessor extends WorkerHost {
  private readonly logger = new Logger(ZoomDeleteMeetingProcessor.name);

  constructor(private readonly zoomMeetingService: ZoomMeetingService) {
    super();
  }

  async process(job: Job<DeleteMeetingJob>): Promise<void> {
    const { instructorId, meetingId } = job.data;
    this.logger.log(`Deleting Zoom meeting ${meetingId}`);

    await this.zoomMeetingService.deleteMeeting(instructorId, meetingId);

    this.logger.log(`Zoom meeting ${meetingId} deleted`);
  }
}
