import { Injectable, Logger } from '@nestjs/common';
import { ZoomAttendanceRepository } from './zoom-attendance.repository';

@Injectable()
export class ZoomAttendanceService {
  private readonly logger = new Logger(ZoomAttendanceService.name);

  constructor(private readonly zoomAttendanceRepository: ZoomAttendanceRepository) {}

  async recordJoin(
    sessionId: string,
    zoomParticipantId: string,
    displayName: string,
    joinTime: string,
  ): Promise<void> {
    await this.zoomAttendanceRepository.upsertAttendance({
      session_id: sessionId,
      zoom_participant_id: zoomParticipantId,
      display_name: displayName,
      join_time: joinTime,
      attendance_status: 'attended',
    });
  }

  async recordLeave(
    sessionId: string,
    zoomParticipantId: string,
    leaveTime: string,
  ): Promise<void> {
    const data = await this.zoomAttendanceRepository.findAttendance(sessionId, zoomParticipantId);

    if (!data) {
      this.logger.warn(
        `No join record found for participant ${zoomParticipantId} in session ${sessionId}`,
      );
      return;
    }

    const joinMs = new Date(data.join_time).getTime();
    const leaveMs = new Date(leaveTime).getTime();
    const durationMinutes = Math.round((leaveMs - joinMs) / 60000);

    await this.zoomAttendanceRepository.updateAttendance(
      sessionId,
      zoomParticipantId,
      {
        leave_time: leaveTime,
        duration: durationMinutes,
        attendance_status: durationMinutes >= 10 ? 'attended' : 'partial',
      },
    );
  }
}