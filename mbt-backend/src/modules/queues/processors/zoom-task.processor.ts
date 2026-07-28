import { Processor, WorkerHost, InjectQueue } from '@nestjs/bullmq';
import { Logger } from '@nestjs/common';
import { Job, Queue } from 'bullmq';
import { ZoomMeetingService } from '../../zoom/zoom-meeting.service';
import { ZoomRecordingService } from '../../zoom/zoom-recording.service';
import { SupabaseService } from '../../supabase/supabase.service';
import { NotificationsService } from '../../notifications/notifications.service';
import { StorageService } from '../../../storage/storage.service';
import type {
  ZoomCreateJob,
  ZoomUpdateJob,
  ZoomDeleteJob,
  ZoomDownloadJob,
  ZoomUploadJob,
  ZoomReminderJob,
} from '../../../common/types/queues.types';

interface SessionRow {
  title: string;
  course_id: string;
  status: string;
}
interface EnrollmentRow {
  user_id: string;
}

const REMINDER_MESSAGES: Record<
  string,
  { title: string; body: (title: string) => string }
> = {
  reminder_24h: {
    title: 'Live Session Tomorrow',
    body: (title) => `"${title}" starts tomorrow. Make sure you are ready!`,
  },
  reminder_1h: {
    title: 'Session Starts in 1 Hour',
    body: (title) => `"${title}" starts in 1 hour.`,
  },
  reminder_10min: {
    title: 'Session Starting Soon',
    body: (title) => `"${title}" is starting in 10 minutes. Join now!`,
  },
};

@Processor('zoom-task')
export class ZoomTaskProcessor extends WorkerHost {
  private readonly logger = new Logger(ZoomTaskProcessor.name);

  constructor(
    private readonly zoomMeetingService: ZoomMeetingService,
    private readonly zoomRecordingService: ZoomRecordingService,
    private readonly supabaseService: SupabaseService,
    private readonly notificationsService: NotificationsService,
    private readonly storageService: StorageService,
    @InjectQueue('zoom-task') private readonly zoomTaskQueue: Queue,
  ) {
    super();
  }

  private get db() {
    return this.supabaseService.getClient();
  }

  async process(job: Job): Promise<void> {
    switch (job.name) {
      case 'create':
        return this.handleCreate(job);
      case 'update':
        return this.handleUpdate(job);
      case 'delete':
        return this.handleDelete(job);
      case 'download':
        return this.handleDownload(job);
      case 'upload':
        return this.handleUpload(job);
      case 'reminder_24h':
      case 'reminder_1h':
      case 'reminder_10min':
        return this.handleReminder(job);
      default:
        this.logger.warn(`Unknown job name: ${job.name}`);
    }
  }

  private async handleCreate(job: Job): Promise<void> {
    const { sessionId, instructorId, title, startTime, duration } =
      job.data as ZoomCreateJob;
    this.logger.log(`Creating Zoom meeting for session ${sessionId}`);
    const meeting = await this.zoomMeetingService.createMeeting(
      instructorId,
      title,
      startTime,
      duration,
    );
    const { error } = await this.db.from('live_session_meetings').insert({
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
    } satisfies Record<string, unknown>);
    if (error) {
      this.logger.error(
        `Failed to save meeting for session ${sessionId}: ${error.message}`,
      );
      throw new Error(error.message);
    }
    this.logger.log(
      `Zoom meeting ${meeting.id} created for session ${sessionId}`,
    );
  }

  private async handleUpdate(job: Job): Promise<void> {
    const { instructorId, meetingId, ...patch } = job.data as ZoomUpdateJob;
    this.logger.log(`Updating Zoom meeting ${meetingId}`);
    await this.zoomMeetingService.updateMeeting(instructorId, meetingId, patch);
    this.logger.log(`Zoom meeting ${meetingId} updated`);
  }

  private async handleDelete(job: Job): Promise<void> {
    const { instructorId, meetingId } = job.data as ZoomDeleteJob;
    this.logger.log(`Deleting Zoom meeting ${meetingId}`);
    await this.zoomMeetingService.deleteMeeting(instructorId, meetingId);
    this.logger.log(`Zoom meeting ${meetingId} deleted`);
  }

  private async handleDownload(job: Job): Promise<void> {
    const { sessionId, instructorId, recordingId, downloadUrl, fileSize } =
      job.data as ZoomDownloadJob;
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
    await this.zoomTaskQueue.add(
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

  private async handleUpload(job: Job): Promise<void> {
    const { sessionId, recordingId, fileBase64, fileSize } =
      job.data as ZoomUploadJob;
    this.logger.log(
      `Uploading recording ${recordingId} for session ${sessionId}`,
    );
    const key = `recordings/${sessionId}/${recordingId}.mp4`;
    const buffer = Buffer.from(fileBase64, 'base64');
    const uploadResult = await this.storageService.upload(
      buffer,
      key,
      'video/mp4',
    );
    this.logger.log(`Recording uploaded: ${uploadResult.url}`);

    await this.db
      .from('session_recordings')
      .update({
        provider: uploadResult.provider,
        storage_key: uploadResult.key,
        storage_url: uploadResult.url,
        file_name: `${recordingId}.mp4`,
        mime_type: uploadResult.mimeType,
        size: fileSize ?? uploadResult.size,
        status: 'ready',
        uploaded_at: new Date().toISOString(),
      } satisfies Record<string, unknown>)
      .eq('session_id', sessionId)
      .eq('provider_recording_id', recordingId);

    await this.db
      .from('live_session_meetings')
      .update({
        recording_status: 'ready',
        recording_url: uploadResult.url,
      } satisfies Record<string, unknown>)
      .eq('session_id', sessionId);
    await this.db
      .from('sessions')
      .update({ status: 'recording_ready' } satisfies Record<string, unknown>)
      .eq('id', sessionId);

    await this.notifyEnrolledStudents(sessionId);
    this.logger.log(`Session ${sessionId} marked as recording_ready`);
  }

  private async notifyEnrolledStudents(sessionId: string): Promise<void> {
    const { data: sessionRaw } = await this.db
      .from('sessions')
      .select('title, course_id')
      .eq('id', sessionId)
      .single();
    const session = sessionRaw as SessionRow | null;
    if (!session) return;
    const { data: enrollmentsRaw } = await this.db
      .from('enrollments')
      .select('user_id')
      .eq('course_id', session.course_id)
      .eq('status', 'active');
    const enrollments = enrollmentsRaw as EnrollmentRow[] | null;
    if (!enrollments?.length) return;
    const userIds = enrollments.map((e) => e.user_id);
    await this.notificationsService.notifyMany(userIds, {
      type: 'recording_ready',
      title: 'Recording Available',
      body: `The recording for "${session.title}" is now available.`,
      data: { session_id: sessionId, course_id: session.course_id },
    });
  }

  private async handleReminder(job: Job): Promise<void> {
    const { sessionId, type } = job.data as ZoomReminderJob;
    const { data: sessionRaw } = await this.db
      .from('sessions')
      .select('title, course_id, status')
      .eq('id', sessionId)
      .single();
    const session = sessionRaw as SessionRow | null;
    if (!session) {
      this.logger.warn(`Session ${sessionId} not found`);
      return;
    }
    if (session.status === 'cancelled') {
      this.logger.log(`Session ${sessionId} cancelled — skipping reminder`);
      return;
    }
    const { data: enrollmentsRaw } = await this.db
      .from('enrollments')
      .select('user_id')
      .eq('course_id', session.course_id)
      .eq('status', 'active');
    const enrollments = enrollmentsRaw as EnrollmentRow[] | null;
    if (!enrollments?.length) return;
    const userIds = enrollments.map((e) => e.user_id);
    const template = REMINDER_MESSAGES[type];
    await this.notificationsService.notifyMany(userIds, {
      type,
      title: template.title,
      body: template.body(session.title),
      data: {
        session_id: sessionId,
        course_id: session.course_id,
      },
    });
    this.logger.log(
      `Reminder "${type}" sent to ${userIds.length} users for session ${sessionId}`,
    );
  }
}
