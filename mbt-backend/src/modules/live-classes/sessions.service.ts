import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
} from '@nestjs/common';
import { SessionsRepository } from './sessions.repository';
import { ZoomSdkService } from '../zoom/zoom-sdk.service';
import { InjectQueue } from '@nestjs/bullmq';
import { Queue } from 'bullmq';
import { CreateSessionDto } from './dto/create-session.dto';
import { UpdateSessionDto } from './dto/update-session.dto';
import { JoinSessionResponseDto } from './dto/join-session-response.dto';
import { SupabaseService } from '../supabase/supabase.service';
import { ConfigService } from '@nestjs/config';
import {
  NotificationsService,
  type NotificationPayload,
} from '../notifications/notifications.service';

@Injectable()
export class SessionsService {
  constructor(
    private readonly sessionsRepository: SessionsRepository,
    private readonly zoomSdkService: ZoomSdkService,
    private readonly supabaseService: SupabaseService,
    private readonly configService: ConfigService,
    private readonly notificationsService: NotificationsService,
    @InjectQueue('zoom-task')
    private readonly zoomTaskQueue: Queue,
  ) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async createSession(userId: string, dto: CreateSessionDto) {
    // Look up the course to get its assigned instructor
    const { data: course, error: courseError } = (await this.db
      .from('courses')
      .select('instructor_id')
      .eq('id', dto.course_id)
      .single()) as unknown as {
      data: { instructor_id: string | null } | null;
      error: { message: string } | null;
    };

    if (courseError || !course) {
      throw new NotFoundException('Course not found');
    }

    const courseInstructorId = course.instructor_id;
    if (!courseInstructorId) {
      throw new BadRequestException('Course has no assigned instructor');
    }

    const session = await this.sessionsRepository.create({
      course_id: dto.course_id,
      instructor_id: courseInstructorId,
      created_by: userId,
      title: dto.title,
      description: dto.description,
      start_time: dto.start_time,
      duration: dto.duration,
      status: 'scheduled',
      section_id: dto.section_id,
    });

    await this.zoomTaskQueue.add('create', {
      sessionId: session.id,
      instructorId: courseInstructorId,
      title: dto.title,
      startTime: dto.start_time,
      duration: dto.duration,
    });

    // Queue reminder jobs via BullMQ
    await this.scheduleReminders(session.id, dto.start_time);

    await this.notifyEnrolledStudents(session.id, session.course_id, {
      type: 'session_created',
      title: 'New Live Session Scheduled',
      body: `"${dto.title}" has been scheduled. Check the schedule for details.`,
    });

    return session;
  }

  async updateSession(id: string, instructorId: string, dto: UpdateSessionDto) {
    const session = await this.sessionsRepository.findById(id);
    if (!session) {
      throw new NotFoundException('Session not found');
    }
    const isAdmin = await this.isAdminOrSuperadmin(instructorId);
    if (session.instructor_id !== instructorId && !isAdmin) {
      throw new ForbiddenException('Not authorized to update this session');
    }

    // Handle status transition side effects
    if (dto.status === 'cancelled' && session.status !== 'cancelled') {
      const meeting = await this.sessionsRepository.findMeetingBySessionId(id);
      if (meeting) {
        await this.zoomTaskQueue.add('delete', {
          instructorId,
          meetingId: meeting.meeting_id,
        });
      }
      await this.cancelReminders(id);
    }

    const updated = await this.sessionsRepository.update(id, {
      title: dto.title,
      description: dto.description,
      start_time: dto.start_time,
      duration: dto.duration,
      status: dto.status,
      section_id: dto.section_id !== undefined ? dto.section_id : undefined,
    });

    // If start_time or duration changed, sync with Zoom and reschedule reminders
    if (dto.start_time || dto.duration) {
      const meeting = await this.sessionsRepository.findMeetingBySessionId(id);
      if (meeting) {
        await this.zoomTaskQueue.add('update', {
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
    const isAdmin = await this.isAdminOrSuperadmin(instructorId);
    if (session.instructor_id !== instructorId && !isAdmin) {
      throw new ForbiddenException('Not authorized to cancel this session');
    }

    const updated = await this.sessionsRepository.update(id, {
      status: 'cancelled',
    });

    const meeting = await this.sessionsRepository.findMeetingBySessionId(id);
    if (meeting) {
      await this.zoomTaskQueue.add('delete', {
        instructorId,
        meetingId: meeting.meeting_id,
      });
    }

    await this.cancelReminders(id);

    await this.notifyEnrolledStudents(id, session.course_id, {
      type: 'session_cancelled',
      title: 'Live Session Cancelled',
      body: `"${session.title}" has been cancelled.`,
    });

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

  async getUpcomingSessions(userId: string) {
    const { data: enrollments } = await this.db
      .from('enrollments')
      .select('course_id')
      .eq('user_id', userId)
      .eq('status', 'active')
      .or(
        `validity_end_at.is.null,validity_end_at.gt.${new Date().toISOString()}`,
      );

    const rows = (enrollments || []) as { course_id: string }[];
    const courseIds = rows.map((e) => e.course_id);
    if (courseIds.length === 0) return [];

    return this.sessionsRepository.findUpcomingByCourseIds(courseIds);
  }

  async getCourseSessions(courseId: string) {
    return this.sessionsRepository.findByCourseId(courseId);
  }

  private async isAdminOrSuperadmin(userId: string): Promise<boolean> {
    const { data: profile } = (await this.db
      .from('profiles')
      .select('role')
      .eq('id', userId)
      .single()) as unknown as { data: { role: string } | null };
    return profile?.role
      ? ['admin', 'superadmin'].includes(profile.role)
      : false;
  }

  async startSession(id: string, userId: string) {
    const session = await this.sessionsRepository.findById(id);
    if (!session) {
      throw new NotFoundException('Session not found');
    }
    const isAdmin = await this.isAdminOrSuperadmin(userId);
    if (!isAdmin && session.instructor_id !== userId) {
      throw new ForbiddenException(
        'Only the instructor or an admin can start the session',
      );
    }
    const updated = await this.sessionsRepository.update(id, {
      status: 'live',
    });

    await this.notifyEnrolledStudents(id, session.course_id, {
      type: 'session_live',
      title: 'Live Session Started',
      body: `"${session.title}" is live now! Join the class.`,
    });

    return updated;
  }

  async endSession(id: string, userId: string) {
    const session = await this.sessionsRepository.findById(id);
    if (!session) {
      throw new NotFoundException('Session not found');
    }
    const isAdmin = await this.isAdminOrSuperadmin(userId);
    if (!isAdmin && session.instructor_id !== userId) {
      throw new ForbiddenException(
        'Only the instructor or an admin can end the session',
      );
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
    const { data: userProfile, error: profileError } = await this.db
      .from('profiles')
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
      const { data: enrollment, error: enrollError } = await this.db
        .from('enrollments')
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

    // Students can only join when the session is live
    if (!isInstructor && !isAdmin && session.status !== 'live') {
      throw new BadRequestException(
        'This session has not started yet. Please wait for the instructor to start it.',
      );
    }

    // Instructors/admins can join 15 minutes early to set up
    if ((isInstructor || isAdmin) && session.status !== 'live') {
      const now = new Date();
      const startTime = new Date(session.start_time);
      const allowedJoinTime = new Date(startTime.getTime() - 15 * 60000);
      if (now < allowedJoinTime) {
        throw new BadRequestException(
          'You can only join this session starting 15 minutes before it begins.',
        );
      }
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
      join_url:
        (role === 1
          ? (meeting.start_url ?? meeting.join_url)
          : meeting.join_url) ?? undefined,
      signature,
      display_name: profile.full_name ?? 'User',
      role,
      zoom_app_key: sdkKey,
    };
  }

  // ──────────────────────────────────────────────────────────
  // Notification helpers
  // ──────────────────────────────────────────────────────────

  private async notifyEnrolledStudents(
    sessionId: string,
    courseId: string,
    payload: NotificationPayload,
  ) {
    const { data: enrollments } = await this.db
      .from('enrollments')
      .select('user_id')
      .eq('course_id', courseId)
      .eq('status', 'active')
      .or(
        `validity_end_at.is.null,validity_end_at.gt.${new Date().toISOString()}`,
      );

    const userIds = ((enrollments ?? []) as { user_id: string }[]).map(
      (e) => e.user_id,
    );

    if (userIds.length > 0) {
      await this.notificationsService.notifyMany(userIds, payload);
    }
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
        await this.zoomTaskQueue.add(
          job.name,
          { sessionId, type: job.name },
          { delay, jobId: `${sessionId}-${job.name}` },
        );
      }
    }
  }

  private async cancelReminders(sessionId: string) {
    const jobTypes = ['reminder_24h', 'reminder_1h', 'reminder_10min'];
    for (const type of jobTypes) {
      try {
        const job = await this.zoomTaskQueue.getJob(`${sessionId}-${type}`);
        if (job) {
          await job.remove();
        }
      } catch {
        // ignore errors if jobs don't exist
      }
    }
  }
}
