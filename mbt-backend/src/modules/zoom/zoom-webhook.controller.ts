import {
  Controller,
  Post,
  Body,
  Headers,
  HttpCode,
  Logger,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectQueue } from '@nestjs/bullmq';
import { Queue } from 'bullmq';
import * as crypto from 'crypto';
import { SupabaseService } from '../supabase/supabase.service';
import { ZoomAttendanceService } from './zoom-attendance.service';
import type { ZoomWebhookEvent } from './interfaces/zoom.interfaces';

@Controller('zoom')
export class ZoomWebhookController {
  private readonly logger = new Logger(ZoomWebhookController.name);

  constructor(
    private readonly configService: ConfigService,
    private readonly supabaseService: SupabaseService,
    private readonly attendanceService: ZoomAttendanceService,
    @InjectQueue('zoom-download-recording')
    private readonly downloadQueue: Queue,
  ) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  @Post('webhook')
  @HttpCode(200)
  async handleWebhook(
    @Headers('x-zm-signature') signature: string,
    @Headers('x-zm-request-timestamp') timestamp: string,
    @Body() rawEvent: ZoomWebhookEvent,
  ) {
    // ── Zoom URL validation challenge ──────────────────────────
    if ((rawEvent as any).event === 'endpoint.url_validation') {
      const plainToken = (rawEvent as any).payload?.plainToken as string;
      const secret = this.configService.get<string>('zoom.webhookSecretToken')!;
      const hash = crypto
        .createHmac('sha256', secret)
        .update(plainToken)
        .digest('hex');
      return { plainToken, encryptedToken: hash };
    }

    // ── Verify Zoom webhook signature ──────────────────────────
    this.verifySignature(signature, timestamp, rawEvent);

    const { event, payload } = rawEvent;
    const obj = payload?.object;

    this.logger.log(`Zoom webhook received: ${event}`);

    switch (event) {
      case 'meeting.started':
        await this.onMeetingStarted(String(obj.id));
        break;

      case 'meeting.ended':
        await this.onMeetingEnded(String(obj.id));
        break;

      case 'meeting.participant_joined':
        if (obj.participant) {
          const sessionId = await this.getSessionIdByMeetingId(String(obj.id));
          if (sessionId) {
            await this.attendanceService.recordJoin(
              sessionId,
              obj.participant.id,
              obj.participant.user_name,
              obj.participant.join_time,
            );
          }
        }
        break;

      case 'meeting.participant_left':
        if (obj.participant) {
          const sessionId = await this.getSessionIdByMeetingId(String(obj.id));
          if (sessionId) {
            await this.attendanceService.recordLeave(
              sessionId,
              obj.participant.id,
              obj.participant.leave_time ?? new Date().toISOString(),
            );
          }
        }
        break;

      case 'recording.completed':
        await this.onRecordingCompleted(rawEvent);
        break;

      default:
        this.logger.debug(`Unhandled Zoom event: ${event}`);
    }

    return { received: true };
  }

  // ──────────────────────────────────────────────────────────
  // Private handlers
  // ──────────────────────────────────────────────────────────

  private async onMeetingStarted(meetingId: string): Promise<void> {
    const sessionId = await this.getSessionIdByMeetingId(meetingId);
    if (!sessionId) return;

    await (this.db.from('sessions') as any)
      .update({ status: 'live' })
      .eq('id', sessionId);

    this.logger.log(`Session ${sessionId} set to LIVE`);
  }

  private async onMeetingEnded(meetingId: string): Promise<void> {
    const sessionId = await this.getSessionIdByMeetingId(meetingId);
    if (!sessionId) return;

    await Promise.all([
      (this.db.from('sessions') as any)
        .update({ status: 'finished' })
        .eq('id', sessionId),
      (this.db.from('live_session_meetings') as any)
        .update({ recording_status: 'processing' })
        .eq('session_id', sessionId),
    ]);

    this.logger.log(`Session ${sessionId} set to FINISHED`);
  }

  private async onRecordingCompleted(event: ZoomWebhookEvent): Promise<void> {
    const obj = event.payload?.object as any;
    const meetingId = String(obj.id);
    const sessionId = await this.getSessionIdByMeetingId(meetingId);
    if (!sessionId) return;

    const { data: session } = await (this.db.from('sessions') as any)
      .select('instructor_id')
      .eq('id', sessionId)
      .single();
    const instructorId = (session as any)?.instructor_id as string | undefined;
    if (!instructorId) {
      this.logger.warn(`No instructor found for session ${sessionId}`);
      return;
    }

    const recordingFiles: any[] = obj.recording_files ?? [];
    const mp4Files = recordingFiles.filter(
      (f: any) => f.file_type === 'MP4' && f.status === 'completed',
    );

    for (const file of mp4Files) {
      await (this.db.from('session_recordings') as any).insert({
        session_id: sessionId,
        provider_recording_id: file.id,
        download_url: file.download_url,
        duration: file.recording_end
          ? Math.round(
              (new Date(file.recording_end).getTime() -
                new Date(file.recording_start).getTime()) /
                1000,
            )
          : null,
        size: file.file_size ?? null,
        status: 'processing',
      });

      await this.downloadQueue.add(
        'download',
        {
          sessionId,
          instructorId,
          meetingId,
          recordingId: file.id,
          downloadUrl: file.download_url,
          fileSize: file.file_size,
        },
        { attempts: 3, backoff: { type: 'exponential', delay: 5000 } },
      );
    }

    this.logger.log(
      `Recording completed for session ${sessionId}. Queued ${mp4Files.length} download job(s).`,
    );
  }

  // ──────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────

  private async getSessionIdByMeetingId(
    meetingId: string,
  ): Promise<string | null> {
    const { data } = await (this.db.from('live_session_meetings') as any)
      .select('session_id')
      .eq('meeting_id', meetingId)
      .maybeSingle();

    if (!data) {
      this.logger.warn(`No session found for Zoom meeting_id: ${meetingId}`);
      return null;
    }

    return data.session_id as string;
  }

  private verifySignature(
    signature: string,
    timestamp: string,
    body: unknown,
  ): void {
    const secret = this.configService.get<string>('zoom.webhookSecretToken');
    if (!secret) return;

    const message = `v0:${timestamp}:${JSON.stringify(body)}`;
    const expected =
      'v0=' + crypto.createHmac('sha256', secret).update(message).digest('hex');

    if (expected !== signature) {
      this.logger.error('Zoom webhook signature verification failed');
      throw new UnauthorizedException('Invalid webhook signature');
    }
  }
}
