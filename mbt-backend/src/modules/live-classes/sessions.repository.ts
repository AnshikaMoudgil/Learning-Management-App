import { Injectable, BadRequestException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

export interface Session {
  id: string;
  course_id: string;
  instructor_id: string;
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
    title: string;
    description?: string;
    start_time: string;
    duration: number;
    status: string;
  }): Promise<Session> {
    const { data: session, error } = await (this.db.from('sessions') as any)
      .insert(data)
      .select()
      .single();

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
    }>,
  ): Promise<Session> {
    const { data: session, error } = await (this.db.from('sessions') as any)
      .update(data)
      .eq('id', id)
      .select()
      .single();

    if (error) throw new BadRequestException(error.message);
    return session;
  }

  async findById(id: string): Promise<Session | null> {
    const { data, error } = await this.db
      .from('sessions')
      .select('*, courses(*), profiles!instructor_id(*), live_session_meetings(*), session_recordings(*)')
      .eq('id', id)
      .maybeSingle();

    if (error) throw new BadRequestException(error.message);
    return data;
  }

  async findAll(): Promise<Session[]> {
    const { data, error } = await this.db
      .from('sessions')
      .select(
        '*, courses(title, thumbnail_url), profiles!instructor_id(full_name, avatar_url), live_session_meetings(provider, meeting_id, recording_status, recording_url), session_recordings(*)',
      )
      .order('start_time', { ascending: true });

    if (error) throw new BadRequestException(error.message);
    return data ?? [];
  }

  async findUpcoming(): Promise<Session[]> {
    const { data, error } = await this.db
      .from('sessions')
      .select(
        '*, courses(title, thumbnail_url), profiles!instructor_id(full_name, avatar_url), live_session_meetings(provider, meeting_id, recording_status, recording_url), session_recordings(*)',
      )
      .in('status', ['scheduled', 'live'])
      .order('start_time', { ascending: true });

    if (error) throw new BadRequestException(error.message);
    return data ?? [];
  }

  async findByCourseId(courseId: string): Promise<Session[]> {
    const { data, error } = await this.db
      .from('sessions')
      .select(
        '*, courses(title, thumbnail_url), profiles!instructor_id(full_name, avatar_url), live_session_meetings(provider, meeting_id, recording_status, recording_url), session_recordings(*)',
      )
      .eq('course_id', courseId)
      .order('start_time', { ascending: true });

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
    const { data, error } = await (this.db.from('live_session_meetings') as any)
      .insert(meetingData)
      .select()
      .single();

    if (error) throw new BadRequestException(error.message);
    return data;
  }

  async findMeetingBySessionId(
    sessionId: string,
  ): Promise<LiveSessionMeeting | null> {
    const { data, error } = await this.db
      .from('live_session_meetings')
      .select('*')
      .eq('session_id', sessionId)
      .maybeSingle();

    if (error) throw new BadRequestException(error.message);
    return data;
  }
}
