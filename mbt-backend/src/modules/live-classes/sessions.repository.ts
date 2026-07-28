import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { PostgrestError } from '@supabase/supabase-js';
import { SupabaseService } from '../supabase/supabase.service';

export interface Session {
  id: string;
  course_id: string;
  instructor_id: string;
  created_by: string;
  title: string;
  description: string | null;
  start_time: string;
  duration: number;
  status: string;
  created_at: string;
  updated_at: string;
}

export interface LiveSessionMeeting {
  id: string;
  session_id: string;
  provider: string;
  meeting_id: string;
  meeting_uuid: string | null;
  password: string | null;
  join_url: string | null;
  start_url: string | null;
  host_user_id: string | null;
  waiting_room: boolean;
  auto_recording: boolean;
  recording_status: string;
  recording_url: string | null;
  provider_metadata: Record<string, unknown> | null;
  created_at: string;
  updated_at: string;
}

@Injectable()
export class SessionsRepository {
  constructor(private readonly supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async create(data: {
    course_id: string;
    instructor_id: string;
    created_by: string;
    title: string;
    description?: string;
    start_time: string;
    duration: number;
    status: string;
    section_id?: string;
  }): Promise<Session> {
    const { data: session, error } = (await this.db
      .from('sessions')
      .insert(data)
      .select()
      .single()) as unknown as { data: Session; error: PostgrestError | null };

    if (error) throw new BadRequestException(error.message);
    return session;
  }

  async update(
    id: string,
    data: Partial<{
      title: string;
      description: string;
      start_time: string;
      duration: number;
      status: string;
      section_id: string | null;
    }>,
  ): Promise<Session> {
    const { data: session, error } = (await this.db
      .from('sessions')
      .update(data)
      .eq('id', id)
      .select()
      .single()) as unknown as { data: Session; error: PostgrestError | null };

    if (error) throw new BadRequestException(error.message);
    return session;
  }

  async findById(id: string): Promise<Session | null> {
    const { data, error } = (await this.db
      .from('sessions')
      .select(
        '*, courses(*), profiles!instructor_id(*), live_session_meetings(*), session_recordings(*)',
      )
      .eq('id', id)
      .maybeSingle()) as unknown as {
      data: Session | null;
      error: PostgrestError | null;
    };

    if (error) throw new BadRequestException(error.message);
    return data;
  }

  async findAll(): Promise<Session[]> {
    const { data, error } = (await this.db
      .from('sessions')
      .select(
        '*, courses(title, thumbnail_url), profiles!instructor_id(full_name, avatar_url), live_session_meetings(provider, meeting_id, recording_status, recording_url), session_recordings(*)',
      )
      .order('start_time', { ascending: true })) as unknown as {
      data: Session[] | null;
      error: PostgrestError | null;
    };

    if (error) throw new BadRequestException(error.message);
    return data ?? [];
  }

  async findUpcoming(): Promise<Session[]> {
    const { data, error } = (await this.db
      .from('sessions')
      .select(
        '*, courses(title, thumbnail_url), profiles!instructor_id(full_name, avatar_url), live_session_meetings(provider, meeting_id, recording_status, recording_url), session_recordings(*)',
      )
      .in('status', ['scheduled', 'live'])
      .order('start_time', { ascending: true })) as unknown as {
      data: Session[] | null;
      error: PostgrestError | null;
    };

    if (error) throw new BadRequestException(error.message);
    return data ?? [];
  }

  async findUpcomingByCourseIds(courseIds: string[]): Promise<Session[]> {
    const { data, error } = (await this.db
      .from('sessions')
      .select(
        '*, courses(title, thumbnail_url), profiles!instructor_id(full_name, avatar_url), live_session_meetings(provider, meeting_id, recording_status, recording_url), session_recordings(*)',
      )
      .in('course_id', courseIds)
      .in('status', ['scheduled', 'live'])
      .order('start_time', { ascending: true })) as unknown as {
      data: Session[] | null;
      error: PostgrestError | null;
    };

    if (error) throw new BadRequestException(error.message);
    return data ?? [];
  }

  async findByCourseId(courseId: string): Promise<Session[]> {
    const { data, error } = (await this.db
      .from('sessions')
      .select(
        '*, courses(title, thumbnail_url), profiles!instructor_id(full_name, avatar_url), live_session_meetings(provider, meeting_id, recording_status, recording_url), session_recordings(*)',
      )
      .eq('course_id', courseId)
      .order('start_time', { ascending: true })) as unknown as {
      data: Session[] | null;
      error: PostgrestError | null;
    };

    if (error) throw new BadRequestException(error.message);
    return data ?? [];
  }

  async createMeetingRelation(meetingData: {
    session_id: string;
    provider: string;
    meeting_id: string;
    meeting_uuid: string;
    password?: string;
    join_url?: string;
    start_url?: string;
    host_user_id?: string;
    provider_metadata?: Record<string, unknown>;
  }): Promise<LiveSessionMeeting> {
    const { data, error } = (await this.db
      .from('live_session_meetings')
      .insert(meetingData)
      .select()
      .single()) as unknown as {
      data: LiveSessionMeeting;
      error: PostgrestError | null;
    };

    if (error) throw new BadRequestException(error.message);
    return data;
  }

  async findMeetingBySessionId(
    sessionId: string,
  ): Promise<LiveSessionMeeting | null> {
    const { data, error } = (await this.db
      .from('live_session_meetings')
      .select('meeting_id, password, start_url, join_url')
      .eq('session_id', sessionId)
      .maybeSingle()) as unknown as {
      data: LiveSessionMeeting | null;
      error: PostgrestError | null;
    };

    if (error) throw new BadRequestException(error.message);
    return data;
  }

  async findCourseInstructorId(courseId: string) {
    const { data: course, error: courseError } = (await this.db
      .from('courses')
      .select('instructor_id')
      .eq('id', courseId)
      .single()) as unknown as {
      data: { instructor_id: string | null } | null;
      error: { message: string } | null;
    };

    if (courseError || !course) {
      throw new NotFoundException('Course not found');
    }

    return course.instructor_id;
  }

  async findEnrolledCourseIds(userId: string) {
    const { data: enrollments } = await this.db
      .from('enrollments')
      .select('course_id')
      .eq('user_id', userId)
      .eq('status', 'active')
      .or(
        `validity_end_at.is.null,validity_end_at.gt.${new Date().toISOString()}`,
      );

    return ((enrollments || []) as { course_id: string }[]).map((e) => e.course_id);
  }

  async findUserRole(userId: string) {
    const { data: profile } = (await this.db
      .from('profiles')
      .select('role')
      .eq('id', userId)
      .single()) as unknown as { data: { role: string } | null };
    return profile?.role ?? null;
  }

  async findUserProfile(userId: string) {
    const { data: userProfile, error: profileError } = await this.db
      .from('profiles')
      .select('full_name, role')
      .eq('id', userId)
      .single();

    if (profileError || !userProfile) {
      throw new NotFoundException('User profile not found');
    }

    return userProfile as { full_name: string | null; role: string };
  }

  async findActiveEnrollment(courseId: string, userId: string) {
    const { data: enrollment, error: enrollError } = await this.db
      .from('enrollments')
      .select('id')
      .eq('course_id', courseId)
      .eq('user_id', userId)
      .eq('status', 'active')
      .or(
        `validity_end_at.is.null,validity_end_at.gt.${new Date().toISOString()}`,
      )
      .maybeSingle();

    if (enrollError || !enrollment) {
      return null;
    }

    return enrollment as { id: string };
  }

  async findEnrolledUserIds(courseId: string) {
    const { data: enrollments } = await this.db
      .from('enrollments')
      .select('user_id')
      .eq('course_id', courseId)
      .eq('status', 'active')
      .or(
        `validity_end_at.is.null,validity_end_at.gt.${new Date().toISOString()}`,
      );

    return ((enrollments ?? []) as { user_id: string }[]).map((e) => e.user_id);
  }
}
