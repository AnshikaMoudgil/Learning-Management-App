import { Processor, WorkerHost, InjectQueue } from '@nestjs/bullmq';
import { Logger } from '@nestjs/common';
import { Job, Queue } from 'bullmq';
import { ZoomRecordingService } from '../../zoom/zoom-recording.service';
import { SupabaseService } from '../../supabase/supabase.service';

interface DownloadRecordingJob {
  sessionId: string;
  instructorId: string;
  meetingId: string;
  recordingId: string;
  downloadUrl: string;
  fileSize: number;
}

@Processor('zoom-download-recording')
export class ZoomDownloadRecordingProcessor extends WorkerHost {
  private readonly logger = new Logger(ZoomDownloadRecordingProcessor.name);

  constructor(
    private readonly zoomRecordingService: ZoomRecordingService,
    private readonly supabaseService: SupabaseService,
    @InjectQueue('zoom-upload-recording') private readonly uploadQueue: Queue,
  ) {
    super();
  }

  private get db() {
    return this.supabaseService.getClient();
  }

  async process(job: Job<DownloadRecordingJob>): Promise<void> {
    const { sessionId, instructorId, recordingId, downloadUrl, fileSize } = job.data;
    this.logger.log(
      `Downloading recording ${recordingId} for session ${sessionId}`,
    );

    const buffer = await this.zoomRecordingService.downloadRecording(
      instructorId,
      downloadUrl,
    );

    this.logger.log(
      `Recording ${recordingId} downloaded (${buffer.length} bytes). Queuing upload...`,
    );

    await this.uploadQueue.add(
      'upload',
      {
        sessionId,
        recordingId,
        fileBase64: buffer.toString('base64'),
        fileSize: fileSize ?? buffer.length,
      },
      { attempts: 3, backoff: { type: 'exponential', delay: 10000 } },
    );
  }
}
