import {
  Injectable,
  Logger,
  InternalServerErrorException,
} from '@nestjs/common';
import { ZoomAuthService } from './zoom-auth.service';
import type {
  ZoomMeetingData,
  ZoomUpdateMeetingPayload,
  ZoomRecordingData,
} from './interfaces/zoom.interfaces';

@Injectable()
export class ZoomMeetingService {
  private readonly logger = new Logger(ZoomMeetingService.name);
  private readonly BASE_URL = 'https://api.zoom.us/v2';

  constructor(private readonly zoomAuth: ZoomAuthService) {}

  private async request<T>(
    method: string,
    path: string,
    instructorId: string,
    body?: unknown,
  ): Promise<T> {
    const token = await this.zoomAuth.getAccessToken();

    const response = await fetch(`${this.BASE_URL}${path}`, {
      method,
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: body ? JSON.stringify(body) : undefined,
    });

    if (!response.ok) {
      const text = await response.text();
      this.logger.error(
        `Zoom API ${method} ${path} failed: ${response.status} ${text}`,
      );
      throw new InternalServerErrorException(
        `Zoom API error: ${response.status}`,
      );
    }

    if (response.status === 204) {
      return undefined as T;
    }

    return response.json() as Promise<T>;
  }

  async createMeeting(
    instructorId: string,
    title: string,
    startTime: string,
    durationMinutes: number,
  ): Promise<ZoomMeetingData> {
    this.logger.log(`Creating Zoom meeting: ${title} at ${startTime}`);

    return this.request<ZoomMeetingData>(
      'POST',
      '/users/me/meetings',
      instructorId,
      {
        topic: title,
        type: 2,
        start_time: startTime,
        duration: durationMinutes,
        timezone: 'UTC',
        settings: {
          waiting_room: true,
          join_before_host: false,
          mute_upon_entry: true,
          auto_recording: 'local',
          approval_type: 0,
        },
      },
    );
  }

  async updateMeeting(
    instructorId: string,
    meetingId: string,
    patch: ZoomUpdateMeetingPayload,
  ): Promise<void> {
    this.logger.log(`Updating Zoom meeting: ${meetingId}`);
    await this.request<void>(
      'PATCH',
      `/meetings/${meetingId}`,
      instructorId,
      patch,
    );
  }

  async deleteMeeting(instructorId: string, meetingId: string): Promise<void> {
    this.logger.log(`Deleting Zoom meeting: ${meetingId}`);
    await this.request<void>('DELETE', `/meetings/${meetingId}`, instructorId);
  }

  async getRecordings(
    instructorId: string,
    meetingId: string,
  ): Promise<ZoomRecordingData> {
    this.logger.log(`Fetching recordings for meeting: ${meetingId}`);
    return this.request<ZoomRecordingData>(
      'GET',
      `/meetings/${meetingId}/recordings`,
      instructorId,
    );
  }

  async getZoomStatus(
    instructorId: string,
  ): Promise<{ connected: boolean; email: string | null }> {
    try {
      const me = await this.request<{ email: string }>(
        'GET',
        '/users/me',
        instructorId,
      );
      return { connected: true, email: me.email };
    } catch {
      return { connected: false, email: null };
    }
  }
}
