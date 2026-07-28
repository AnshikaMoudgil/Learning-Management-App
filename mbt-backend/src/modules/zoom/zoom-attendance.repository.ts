import { Injectable, Logger } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class ZoomAttendanceRepository {
  private readonly logger = new Logger(ZoomAttendanceRepository.name);

  constructor(private readonly supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async upsertAttendance(data: {
    session_id: string;
    zoom_participant_id: string;
    display_name: string;
    join_time: string;
    attendance_status: string;
  }) {
    const { error } = await this.db.from('session_attendance').upsert(
      data,
      { onConflict: 'session_id,zoom_participant_id' },
    );

    if (error) {
      this.logger.error(
        `Failed to record join for participant ${data.zoom_participant_id} in session ${data.session_id}: ${error.message}`,
      );
    }
  }

  async findAttendance(sessionId: string, zoomParticipantId: string) {
    const { data, error: fetchError } = await this.db
      .from('session_attendance')
      .select('join_time')
      .eq('session_id', sessionId)
      .eq('zoom_participant_id', zoomParticipantId)
      .maybeSingle();

    if (fetchError || !data) {
      return null;
    }

    return data as { join_time: string };
  }

  async updateAttendance(
    sessionId: string,
    zoomParticipantId: string,
    data: {
      leave_time: string;
      duration: number;
      attendance_status: string;
    },
  ) {
    const { error } = await this.db
      .from('session_attendance')
      .update(data)
      .eq('session_id', sessionId)
      .eq('zoom_participant_id', zoomParticipantId);

    if (error) {
      this.logger.error(
        `Failed to record leave for participant ${zoomParticipantId}: ${error.message}`,
      );
    }
  }
}