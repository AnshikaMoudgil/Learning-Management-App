import { Injectable, BadRequestException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class MyCoursesRepository {
  constructor(private readonly supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async findContinueWatching(userId: string) {
    const { data, error } = await this.db
      .from('user_lesson_progress')
      .select(
        `
        lesson_id,
        is_completed,
        watched_seconds,
        last_watched_at,
        course_lessons (
          id,
          title,
          video_duration,
          course_id,
          section_id,
          courses (
            id,
            title,
            thumbnail_url
          )
        )
      `,
      )
      .eq('user_id', userId)
      .eq('is_completed', false)
      .order('last_watched_at', { ascending: false })
      .limit(5);

    if (error) throw new BadRequestException(error.message);
    return (data ?? []) as Record<string, unknown>[];
  }

  async findActiveEnrollment(courseId: string, userId: string) {
    const { data, error } = await this.db
      .from('enrollments')
      .select('id, progress_percent, validity_end_at, status')
      .eq('course_id', courseId)
      .eq('user_id', userId)
      .eq('status', 'active')
      .maybeSingle();

    if (error) throw new BadRequestException(error.message);
    return data as {
      id: string;
      progress_percent: number;
      validity_end_at: string | null;
      status: string;
    } | null;
  }

  async findEnrollmentExists(courseId: string, userId: string) {
    const { data: enrollment } = await this.db
      .from('enrollments')
      .select('id')
      .eq('course_id', courseId)
      .eq('user_id', userId)
      .eq('status', 'active')
      .maybeSingle();

    return enrollment as { id: string } | null;
  }

  async upsertLessonProgress(data: Record<string, unknown>) {
    const { error } = await this.db.from('user_lesson_progress').upsert(
      data,
      { onConflict: 'user_id,lesson_id' },
    );

    if (error) throw new BadRequestException(error.message);
  }

  async findEnrollmentProgress(courseId: string, userId: string) {
    const { data: updatedEnrollment } = await this.db
      .from('enrollments')
      .select('progress_percent')
      .eq('course_id', courseId)
      .eq('user_id', userId)
      .maybeSingle();

    return updatedEnrollment as { progress_percent: number } | null;
  }

  async findCourse(courseId: string) {
    const { data, error } = await this.db
      .from('courses')
      .select('id, title, thumbnail_url')
      .eq('id', courseId)
      .maybeSingle();
    if (error) throw new BadRequestException(error.message);
    return data as {
      id: string;
      title: string;
      thumbnail_url: string | null;
    } | null;
  }

  async findSectionsWithLessons(courseId: string) {
    const { data, error } = await this.db
      .from('course_sections')
      .select(
        `id, title, description, sort_order,
         course_lessons(
           id, section_id, title, description,
           video_asset_id, video_url, video_duration,
           is_free_preview, sort_order,
           media_assets!video_asset_id(id, storage_url, duration, thumbnail_url, status)
         )`,
      )
      .eq('course_id', courseId)
      .order('sort_order', { ascending: true })
      .order('sort_order', { ascending: true, foreignTable: 'course_lessons' });
    if (error) throw new BadRequestException(error.message);
    return (data ?? []) as Record<string, unknown>[];
  }

  async findLessonProgress(courseId: string, userId: string) {
    const { data, error } = await this.db
      .from('user_lesson_progress')
      .select('lesson_id, is_completed, watched_seconds')
      .eq('course_id', courseId)
      .eq('user_id', userId);
    if (error) throw new BadRequestException(error.message);
    return (data ?? []) as {
      lesson_id: string;
      is_completed: boolean;
      watched_seconds: number;
    }[];
  }

  async findSessions(courseId: string) {
    const { data, error } = await this.db
      .from('sessions')
      .select(
        'id, title, description, start_time, duration, status, section_id, course_sections(title), profiles!instructor_id(full_name), live_session_meetings(join_url)',
      )
      .eq('course_id', courseId)
      .neq('status', 'draft')
      .order('start_time', { ascending: true });
    if (error) throw new BadRequestException(error.message);
    return (data ?? []) as Record<string, unknown>[];
  }

  async findRecordings(courseId: string) {
    const { data, error } = await this.db
      .from('session_recordings')
      .select(
        'id, title, thumbnail_url, storage_url, duration, status, created_at, sessions!inner(section_id, course_sections(title))',
      )
      .eq('sessions.course_id', courseId)
      .eq('status', 'ready')
      .order('created_at', { ascending: false });
    if (error) throw new BadRequestException(error.message);
    return (data ?? []) as Record<string, unknown>[];
  }

  async findResources(courseId: string) {
    const { data, error } = await this.db
      .from('course_resources')
      .select(
        'id, section_id, title, file_url, file_size, file_type, created_at',
      )
      .eq('course_id', courseId)
      .order('created_at', { ascending: true });
    if (error) throw new BadRequestException(error.message);
    return (data ?? []) as Record<string, unknown>[];
  }
}