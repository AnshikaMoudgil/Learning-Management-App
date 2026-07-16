import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
} from '@nestjs/common';
import { SessionsRepository, Session } from './sessions.repository';
import { ZoomSdkService } from '../zoom/zoom-sdk.service';
import { InjectQueue } from '@nestjs/bullmq';
import { Queue } from 'bullmq';
import { CreateSessionDto } from './dto/create-session.dto';
import { UpdateSessionDto } from './dto/update-session.dto';
import { JoinSessionResponseDto } from './dto/join-session-response.dto';
import { SupabaseService } from '../supabase/supabase.service';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class SessionsService {
  constructor(
    private readonly sessionsRepository: SessionsRepository,
    private readonly zoomSdkService: ZoomSdkService,
    private readonly supabaseService: SupabaseService,
    private readonly configService: ConfigService,
    @InjectQueue('zoom-create-meeting')
    private readonly createMeetingQueue: Queue,
    @InjectQueue('zoom-update-meeting')
    private readonly updateMeetingQueue: Queue,
    @InjectQueue('zoom-delete-meeting')
    private readonly deleteMeetingQueue: Queue,
    @InjectQueue('zoom-send-reminders')
    private readonly sendRemindersQueue: Queue,
  ) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async createSession(instructorId: string, dto: CreateSessionDto) {
    const session = await this.sessionsRepository.create({
      course_id: dto.course_id,
      instructor_id: instructorId,
      title: dto.title,
      description: dto.description,
      start_time: dto.start_time,
      duration: dto.duration,
      status: 'scheduled',
    });

    // Queue Zoom meeting creation
    await this.createMeetingQueue.add('create', {
      sessionId: session.id,
      instructorId,
      title: dto.title,
      startTime: dto.start_time,
      duration: dto.duration,
    });

    // Queue reminder jobs via BullMQ
    await this.scheduleReminders(session.id, dto.start_time);

    return session;
  }

  async updateSession(id: string, instructorId: string, dto: UpdateSessionDto) {
    const session = await this.sessionsRepository.findById(id);
    if (!session) {
      throw new NotFoundException('Session not found');
    }
    if (session.instructor_id !== instructorId) {
      throw new ForbiddenException('Not authorized to update this session');
    }

    // Handle status transition side effects
    if (dto.status === 'cancelled' && session.status !== 'cancelled') {
      const meeting = await this.sessionsRepository.findMeetingBySessionId(id);
      if (meeting) {
        await this.deleteMeetingQueue.add('delete', {
          instructorId,
          meetingId: meeting.meeting_id,
        });
      }
      await this.cancelReminders(id);
    }

    const updated = await this.sessionsRepository.update(id, dto);

    // If start_time or duration changed, sync with Zoom and reschedule reminders
    if (dto.start_time || dto.duration) {
      const meeting = await this.sessionsRepository.findMeetingBySessionId(id);
      if (meeting) {
        await this.updateMeetingQueue.add('update', {
          instructorId,
          meetingId: meeting.meeting_id,
          topic: dto.title ?? session.title,
          start_time: dto.start_time ?? session.start_time,
          duration: dto.duration ?? session.duration,
        });
      }

      if (dto.start_time) {
        await this.cancelReminders(id);
        await this.scheduleReminders(id, dto.start_time);
      }
    }

    return updated;
  }

  async cancelSession(id: string, instructorId: string) {
    const session = await this.sessionsRepository.findById(id);
    if (!session) {
      throw new NotFoundException('Session not found');
    }
    if (session.instructor_id !== instructorId) {
      throw new ForbiddenException('Not authorized to cancel this session');
    }

    const updated = await this.sessionsRepository.update(id, {
      status: 'cancelled',
    });

    const meeting = await this.sessionsRepository.findMeetingBySessionId(id);
    if (meeting) {
      await this.deleteMeetingQueue.add('delete', {
        instructorId,
        meetingId: meeting.meeting_id,
      });
    }

    await this.cancelReminders(id);

    return updated;
  }

  async getSessionDetail(id: string) {
    const session = await this.sessionsRepository.findById(id);
    if (!session) {
      throw new NotFoundException('Session not found');
    }
    return session;
  }

  async getAllSessions() {
    return this.sessionsRepository.findAll();
  }

  async getUpcomingSessions() {
    return this.sessionsRepository.findUpcoming();
  }

  async getCourseSessions(courseId: string) {
    return this.sessionsRepository.findByCourseId(courseId);
  }

  async startSession(id: string, instructorId: string) {
    const session = await this.sessionsRepository.findById(id);
    if (!session) {
      throw new NotFoundException('Session not found');
    }
    if (session.instructor_id !== instructorId) {
      throw new ForbiddenException('Only the instructor can start the session');
    }
    return this.sessionsRepository.update(id, { status: 'live' });
  }

  async endSession(id: string, instructorId: string) {
    const session = await this.sessionsRepository.findById(id);
    if (!session) {
      throw new NotFoundException('Session not found');
    }
    if (session.instructor_id !== instructorId) {
      throw new ForbiddenException('Only the instructor can end the session');
    }
    return this.sessionsRepository.update(id, { status: 'finished' });
  }

  async joinSession(
    id: string,
    userId: string,
  ): Promise<JoinSessionResponseDto> {
    const session = await this.sessionsRepository.findById(id);
    if (!session) {
      throw new NotFoundException('Session not found');
    }

    if (session.status === 'cancelled') {
      throw new BadRequestException('This session has been cancelled');
    }

    // Fetch user profile
    const { data: userProfile, error: profileError } = await (
      this.db.from('profiles') as any
    )
      .select('full_name, role')
      .eq('id', userId)
      .single();

    if (profileError || !userProfile) {
      throw new NotFoundException('User profile not found');
    }

    const profile = userProfile as { full_name: string | null; role: string };

    const isInstructor =
      profile.role === 'instructor' && session.instructor_id === userId;
    const isAdmin = ['admin', 'superadmin'].includes(profile.role);

    // If student, verify enrollment
    if (!isInstructor && !isAdmin) {
      const { data: enrollment, error: enrollError } = await (
        this.db.from('enrollments') as any
      )
        .select('id')
        .eq('course_id', session.course_id)
        .eq('user_id', userId)
        .eq('status', 'active')
        .or(
          `validity_end_at.is.null,validity_end_at.gt.${new Date().toISOString()}`,
        )
        .maybeSingle();

      if (enrollError || !enrollment) {
        throw new ForbiddenException('You are not enrolled in this course');
      }
    }

    // Validate join window
    const now = new Date();
    const startTime = new Date(session.start_time);
    const earlyJoinMinutes = isInstructor || isAdmin ? 15 : 10;
    const allowedJoinTime = new Date(
      startTime.getTime() - earlyJoinMinutes * 60000,
    );

    if (now < allowedJoinTime && session.status !== 'live') {
      throw new BadRequestException(
        `You can only join this session starting ${earlyJoinMinutes} minutes before it begins.`,
      );
    }

    const meeting = await this.sessionsRepository.findMeetingBySessionId(id);
    if (!meeting) {
      throw new BadRequestException(
        'Zoom meeting details are not available yet. Please try again in a moment.',
      );
    }

    const role: 0 | 1 = isInstructor || isAdmin ? 1 : 0;
    const sdkKey = this.configService.get<string>('zoom.sdkKey')!;
    const signature = this.zoomSdkService.generateSignature(
      meeting.meeting_id,
      role,
      session.duration * 60 + 1800, // Duration plus 30 mins buffer
    );

    return {
      meeting_number: meeting.meeting_id,
      password: meeting.password ?? undefined,
      join_url: meeting.join_url ?? undefined,
      signature,
      display_name: profile.full_name ?? 'User',
      role,
      zoom_app_key: sdkKey,
    };
  }

  // ──────────────────────────────────────────────────────────
  // Reminder scheduling helpers
  // ──────────────────────────────────────────────────────────

  private async scheduleReminders(sessionId: string, startTimeStr: string) {
    const startTime = new Date(startTimeStr).getTime();
    const now = Date.now();

    const jobs = [
      { name: 'reminder_24h', offset: 24 * 60 * 60 * 1000 },
      { name: 'reminder_1h', offset: 60 * 60 * 1000 },
      { name: 'reminder_10min', offset: 10 * 60 * 1000 },
    ];

    for (const job of jobs) {
      const triggerTime = startTime - job.offset;
      const delay = triggerTime - now;
      if (delay > 0) {
        await this.sendRemindersQueue.add(
          job.name,
          { sessionId, type: job.name },
          { delay, jobId: `${sessionId}:${job.name}` },
        );
      }
    }
  }

  private async cancelReminders(sessionId: string) {
    const jobTypes = ['reminder_24h', 'reminder_1h', 'reminder_10min'];
    for (const type of jobTypes) {
      try {
        const job = await this.sendRemindersQueue.getJob(
          `${sessionId}:${type}`,
        );
        if (job) {
          await job.remove();
        }
      } catch {
        // ignore errors if jobs don't exist
      }
    }
  }
}
