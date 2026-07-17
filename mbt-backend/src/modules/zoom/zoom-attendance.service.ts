import { Injectable, Logger } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class ZoomAttendanceService {
  private readonly logger = new Logger(ZoomAttendanceService.name);

  constructor(private readonly supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  /**
   * Called on participant_joined webhook.
   * Upserts attendance row by zoom_participant_id to handle re-joins.
   */
  async recordJoin(
    sessionId: string,
    zoomParticipantId: string,
    displayName: string,
    joinTime: string,
  ): Promise<void> {
    const { error } = await this.db.from('session_attendance').upsert(
      {
        session_id: sessionId,
        zoom_participant_id: zoomParticipantId,
        display_name: displayName,
        join_time: joinTime,
        attendance_status: 'attended',
      },
      { onConflict: 'session_id,zoom_participant_id' },
    );

    if (error) {
      this.logger.error(
        `Failed to record join for participant ${zoomParticipantId} in session ${sessionId}: ${error.message}`,
      );
    }
  }

  /**
   * Called on participant_left webhook.
   * Records leave time and calculates duration in minutes.
   */
  async recordLeave(
    sessionId: string,
    zoomParticipantId: string,
    leaveTime: string,
  ): Promise<void> {
    const { data, error: fetchError } = await this.db
      .from('session_attendance')
      .select('join_time')
      .eq('session_id', sessionId)
      .eq('zoom_participant_id', zoomParticipantId)
      .maybeSingle();

    if (fetchError || !data) {
      this.logger.warn(
        `No join record found for participant ${zoomParticipantId} in session ${sessionId}`,
      );
      return;
    }

    const joinMs = new Date(
      (data as Record<string, unknown>).join_time as string,
    ).getTime();
    const leaveMs = new Date(leaveTime).getTime();
    const durationMinutes = Math.round((leaveMs - joinMs) / 60000);

    const { error } = await this.db
      .from('session_attendance')
      .update({
        leave_time: leaveTime,
        duration: durationMinutes,
        attendance_status: durationMinutes >= 10 ? 'attended' : 'partial',
      })
      .eq('session_id', sessionId)
      .eq('zoom_participant_id', zoomParticipantId);

    if (error) {
      this.logger.error(
        `Failed to record leave for participant ${zoomParticipantId}: ${error.message}`,
      );
    }
  }
}
