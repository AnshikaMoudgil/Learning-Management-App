/* eslint-disable @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-call */
import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Logger } from '@nestjs/common';
import { Job } from 'bullmq';
import { SupabaseService } from '../../supabase/supabase.service';
import { NotificationsService } from '../../notifications/notifications.service';
import { StorageService } from '../../../storage/storage.service';

interface UploadRecordingJob {
  sessionId: string;
  recordingId: string;
  fileBase64: string;
  fileSize: number;
}

@Processor('zoom-upload-recording')
export class ZoomUploadRecordingProcessor extends WorkerHost {
  private readonly logger = new Logger(ZoomUploadRecordingProcessor.name);

  constructor(
    private readonly supabaseService: SupabaseService,
    private readonly notificationsService: NotificationsService,
    private readonly storageService: StorageService,
  ) {
    super();
  }

  private get db() {
    return this.supabaseService.getClient();
  }

  async process(job: Job<UploadRecordingJob>): Promise<void> {
    const { sessionId, recordingId, fileBase64, fileSize } = job.data;
    this.logger.log(
      `Uploading recording ${recordingId} for session ${sessionId} using StorageService`,
    );

    const key = `recordings/${sessionId}/${recordingId}.mp4`;
    const buffer = Buffer.from(fileBase64, 'base64');
    const mimeType = 'video/mp4';

    const uploadResult = await this.storageService.upload(
      buffer,
      key,
      mimeType,
    );
    this.logger.log(`Recording uploaded successfully: ${uploadResult.url}`);

    // Update session_recordings
    await (this.db.from('session_recordings') as any)
      .update({
        provider: uploadResult.provider,
        storage_key: uploadResult.key,
        storage_url: uploadResult.url,
        file_name: `${recordingId}.mp4`,
        mime_type: uploadResult.mimeType,
        size: fileSize ?? uploadResult.size,
        status: 'ready',
        uploaded_at: new Date().toISOString(),
      })
      .eq('session_id', sessionId)
      .eq('provider_recording_id', recordingId);

    // Update live_session_meetings
    await (this.db.from('live_session_meetings') as any)
      .update({ recording_status: 'ready', recording_url: uploadResult.url })
      .eq('session_id', sessionId);

    // Update session status
    await (this.db.from('sessions') as any)
      .update({ status: 'recording_ready' })
      .eq('id', sessionId);

    // Notify enrolled students
    await this.notifyEnrolledStudents(sessionId);

    this.logger.log(`Session ${sessionId} marked as recording_ready`);
  }

  private async notifyEnrolledStudents(sessionId: string): Promise<void> {
    const { data: session } = await (this.db.from('sessions') as any)
      .select('title, course_id')
      .eq('id', sessionId)
      .single();

    if (!session) return;

    const { data: enrollments } = await (this.db.from('enrollments') as any)
      .select('user_id')
      .eq('course_id', session.course_id)
      .eq('status', 'active');

    if (!enrollments?.length) return;

    const userIds = (enrollments as any[]).map((e: any) => e.user_id as string);

    await this.notificationsService.notifyMany(userIds, {
      type: 'recording_ready',
      title: 'Recording Available',
      body: `The recording for "${session.title}" is now available.`,
      data: { session_id: sessionId, course_id: session.course_id },
    });
  }
}
