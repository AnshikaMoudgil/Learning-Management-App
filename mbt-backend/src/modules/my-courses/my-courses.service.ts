import {
  Injectable,
  ForbiddenException,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

// ─── Interfaces ───────────────────────────────────────────────────────────────

interface ContinueWatchingRow {
  lesson_id: string;
  is_completed: boolean;
  watched_seconds: number;
  last_watched_at: string;
  course_lessons: {
    id: string;
    title: string;
    video_duration: string | null;
    course_id: string;
    section_id: string;
    courses: {
      id: string;
      title: string;
      thumbnail_url: string | null;
    } | null;
  } | null;
}

export interface LessonProgress {
  lesson_id: string;
  is_completed: boolean;
  watched_seconds: number;
  last_watched_at: string;
}

export interface LessonWithProgress {
  id: string;
  section_id: string;
  title: string;
  description: string | null;
  video_asset_id?: string | null;
  video_url: string | null;
  video_duration: string | null;
  video_status?: string | null;
  thumbnail_url?: string | null;
  is_free_preview: boolean;
  sort_order: number;
  is_completed: boolean;
  watched_seconds: number;
}

export interface SectionWithContent {
  id: string;
  title: string;
  description: string | null;
  sort_order: number;
  total_lessons: number;
  completed_lessons: number;
  progress_percent: number;
  is_unlocked: boolean;
  lessons: LessonWithProgress[];
  live_classes: LiveClassItem[];
  resources: ResourceItem[];
}

export interface LiveClassItem {
  id: string;
  title: string;
  description: string | null;
  start_time: string;
  duration: number;
  status: string;
  section_id: string | null;
  section_title: string | null;
  instructor_name: string | null;
  join_url: string | null;
}

export interface RecordingItem {
  id: string;
  title: string | null;
  thumbnail_url: string | null;
  storage_url: string | null;
  duration: number | null;
  status: string;
  section_id: string | null;
  section_title: string | null;
  created_at: string;
}

export interface ResourceItem {
  id: string;
  title: string;
  file_url: string;
  file_size: string | null;
  file_type: string | null;
  section_id: string | null;
  created_at: string;
}

export interface CourseContent {
  course_id: string;
  title: string;
  thumbnail_url: string | null;
  enrollment: {
    enrollment_id: string;
    progress_percent: number;
    validity_end_at: string | null;
    status: string;
  };
  sections: SectionWithContent[];
  all_live_classes: LiveClassItem[];
  all_recordings: RecordingItem[];
  all_resources: ResourceItem[];
}

// ─── Service ──────────────────────────────────────────────────────────────────

@Injectable()
export class MyCoursesService {
  constructor(private readonly supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async getContinueWatching(userId: string) {
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

    return ((data ?? []) as ContinueWatchingRow[]).map((row) => {
      const lesson = row.course_lessons;
      const course = lesson?.courses;
      return {
        lesson_id: row.lesson_id,
        is_completed: row.is_completed,
        watched_seconds: row.watched_seconds,
        last_watched_at: row.last_watched_at,
        lesson_title: lesson?.title ?? '',
        video_duration: lesson?.video_duration ?? '00:00',
        section_id: lesson?.section_id,
        course_id: course?.id,
        course_title: course?.title ?? '',
        course_thumbnail_url: course?.thumbnail_url,
      };
    });
  }

  // ─── Get full course content (post-purchase) ───────────────────────────────

  async getCourseContent(
    courseId: string,
    userId: string,
  ): Promise<CourseContent> {
    // 1. Verify active enrollment (sequential — early rejection)
    const { data: enrollment, error: enrollError } = await this.db
      .from('enrollments')
      .select('id, progress_percent, validity_end_at, status')
      .eq('course_id', courseId)
      .eq('user_id', userId)
      .eq('status', 'active')
      .maybeSingle();

    if (enrollError) throw new BadRequestException(enrollError.message);
    if (!enrollment) {
      throw new ForbiddenException(
        'You must be enrolled in this course to access its content',
      );
    }

    // 2. Fetch all data in parallel (7 queries → 5 by combining sections+lessons)
    const [
      course,
      sectionsWithLessons,
      progressData,
      sessionsData,
      recordingsData,
      resourcesData,
    ] = await Promise.all([
      this.fetchCourse(courseId),
      this.fetchSectionsWithLessons(courseId),
      this.fetchLessonProgress(courseId, userId),
      this.fetchSessions(courseId),
      this.fetchRecordings(courseId),
      this.fetchResources(courseId),
    ]);

    if (!course) throw new NotFoundException('Course not found');

    // 3. Build progress lookup
    const progressMap = new Map<
      string,
      { is_completed: boolean; watched_seconds: number }
    >();
    for (const p of progressData) {
      progressMap.set(p.lesson_id, {
        is_completed: p.is_completed,
        watched_seconds: p.watched_seconds,
      });
    }

    // 4. Build session lookup by section
    const sessionsBySection = new Map<string, LiveClassItem[]>();
    for (const s of sessionsData) {
      const key = s.section_id ?? '__no_section__';
      sessionsBySection.set(key, [...(sessionsBySection.get(key) ?? []), s]);
    }

    // 5. Build resource lookup by section
    const resourcesBySection = new Map<string, ResourceItem[]>();
    for (const r of resourcesData) {
      const key = r.section_id ?? '__no_section__';
      resourcesBySection.set(key, [...(resourcesBySection.get(key) ?? []), r]);
    }

    // 6. Assemble sections with progress merged into lessons
    const sections: SectionWithContent[] = sectionsWithLessons.map(
      (section, index) => {
        const rawLessons =
          ((section as unknown as Record<string, unknown>)
            .course_lessons as Record<string, unknown>[]) ?? [];
        const lessons: LessonWithProgress[] = rawLessons.map((row) => {
          const asset = row.media_assets as {
            storage_url?: string | null;
            duration?: number | null;
            thumbnail_url?: string | null;
            status?: string | null;
          } | null;
          const lesson = row;
          const progress = progressMap.get(lesson.id as string);
          return {
            ...(lesson as unknown as LessonWithProgress),
            video_url:
              asset?.storage_url ?? (lesson.video_url as string | null),
            video_duration:
              asset?.duration != null
                ? String(asset.duration)
                : (lesson.video_duration as string | null),
            video_status: asset?.status ?? null,
            thumbnail_url: asset?.thumbnail_url ?? null,
            is_completed: progress?.is_completed ?? false,
            watched_seconds: progress?.watched_seconds ?? 0,
          };
        });

        const completed = lessons.filter((l) => l.is_completed).length;
        const total = lessons.length;
        const prevCompleted =
          index === 0
            ? true
            : sectionsWithLessons.slice(0, index).every((sec) => {
                const secLessons =
                  ((sec as unknown as Record<string, unknown>)
                    .course_lessons as Record<string, unknown>[]) ?? [];
                const secTotal = secLessons.length;
                const secDone = secLessons.filter((l) => {
                  const lp = progressMap.get(l.id as string);
                  return lp?.is_completed;
                }).length;
                return secTotal === 0 || secDone >= secTotal;
              });
        return {
          id: section.id,
          title: section.title,
          description: section.description,
          sort_order: section.sort_order,
          total_lessons: total,
          completed_lessons: completed,
          progress_percent:
            total > 0 ? Math.round((completed / total) * 100) : 0,
          is_unlocked: prevCompleted,
          lessons,
          live_classes: sessionsBySection.get(section.id) ?? [],
          resources: resourcesBySection.get(section.id) ?? [],
        };
      },
    );

    const totalLessons = sections.reduce((sum, s) => sum + s.total_lessons, 0);
    const completedLessons = sections.reduce(
      (sum, s) => sum + s.completed_lessons,
      0,
    );
    const computedProgress =
      totalLessons > 0
        ? Math.round((completedLessons / totalLessons) * 100)
        : 0;

    return {
      course_id: course.id,
      title: course.title,
      thumbnail_url: course.thumbnail_url,
      enrollment: {
        enrollment_id: enrollment.id as string,
        progress_percent: computedProgress,
        validity_end_at: enrollment.validity_end_at as string | null,
        status: enrollment.status as string,
      },
      sections,
      all_live_classes: sessionsData,
      all_recordings: recordingsData,
      all_resources: resourcesData,
    };
  }

  // ─── Update lesson progress (upsert) ──────────────────────────────────────

  async updateLessonProgress(
    courseId: string,
    lessonId: string,
    userId: string,
    isCompleted: boolean,
    watchedSeconds?: number,
  ): Promise<{
    lesson_id: string;
    is_completed: boolean;
    course_progress_percent: number;
  }> {
    // Verify active enrollment
    const { data: enrollment } = await this.db
      .from('enrollments')
      .select('id')
      .eq('course_id', courseId)
      .eq('user_id', userId)
      .eq('status', 'active')
      .maybeSingle();

    if (!enrollment) {
      throw new ForbiddenException('Not enrolled in this course');
    }

    // Upsert lesson progress
    const { error } = await this.db.from('user_lesson_progress').upsert(
      {
        user_id: userId,
        course_id: courseId,
        lesson_id: lessonId,
        is_completed: isCompleted,
        watched_seconds: watchedSeconds ?? 0,
        last_watched_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      },
      { onConflict: 'user_id,lesson_id' },
    );

    if (error) throw new BadRequestException(error.message);

    // Fetch updated enrollment progress (trigger may have updated it)
    const { data: updatedEnrollment } = await this.db
      .from('enrollments')
      .select('progress_percent')
      .eq('course_id', courseId)
      .eq('user_id', userId)
      .maybeSingle();

    return {
      lesson_id: lessonId,
      is_completed: isCompleted,
      course_progress_percent:
        (updatedEnrollment?.progress_percent as number) ?? 0,
    };
  }

  // ─── Private helpers ───────────────────────────────────────────────────────

  private async fetchCourse(courseId: string) {
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

  private async fetchSectionsWithLessons(courseId: string) {
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
    return (data ?? []) as {
      id: string;
      title: string;
      description: string | null;
      sort_order: number;
    }[];
  }

  private async fetchLessonProgress(courseId: string, userId: string) {
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

  private async fetchSessions(courseId: string): Promise<LiveClassItem[]> {
    const { data, error } = await this.db
      .from('sessions')
      .select(
        'id, title, description, start_time, duration, status, section_id, course_sections(title), profiles!instructor_id(full_name), live_session_meetings(join_url)',
      )
      .eq('course_id', courseId)
      .neq('status', 'draft')
      .order('start_time', { ascending: true });
    if (error) throw new BadRequestException(error.message);

    return ((data as Record<string, unknown>[]) ?? []).map((row) => {
      const meetings = row.live_session_meetings as
        { join_url?: string }[] | null;
      const profiles = row.profiles as { full_name?: string } | null;
      const section = row.course_sections as { title?: string } | null;
      return {
        id: row.id as string,
        title: row.title as string,
        description: row.description as string | null,
        start_time: row.start_time as string,
        duration: row.duration as number,
        status: row.status as string,
        section_id: row.section_id as string | null,
        section_title: section?.title ?? null,
        instructor_name: profiles?.full_name ?? null,
        join_url: Array.isArray(meetings)
          ? (meetings[0]?.join_url ?? null)
          : null,
      };
    });
  }

  private async fetchRecordings(courseId: string): Promise<RecordingItem[]> {
    const { data, error } = await this.db
      .from('session_recordings')
      .select(
        'id, title, thumbnail_url, storage_url, duration, status, created_at, sessions!inner(section_id, course_sections(title))',
      )
      .eq('sessions.course_id', courseId)
      .eq('status', 'ready')
      .order('created_at', { ascending: false });
    if (error) throw new BadRequestException(error.message);

    return ((data as Record<string, unknown>[]) ?? []).map((row) => {
      const session = row.sessions as {
        section_id?: string | null;
        course_sections?: { title?: string } | null;
      } | null;
      return {
        id: row.id as string,
        title: row.title as string | null,
        thumbnail_url: row.thumbnail_url as string | null,
        storage_url: row.storage_url as string | null,
        duration: row.duration as number | null,
        status: row.status as string,
        section_id: session?.section_id ?? null,
        section_title: session?.course_sections?.title ?? null,
        created_at: row.created_at as string,
      };
    });
  }

  private async fetchResources(courseId: string): Promise<ResourceItem[]> {
    const { data, error } = await this.db
      .from('course_resources')
      .select(
        'id, section_id, title, file_url, file_size, file_type, created_at',
      )
      .eq('course_id', courseId)
      .order('created_at', { ascending: true });
    if (error) throw new BadRequestException(error.message);

    return ((data as Record<string, unknown>[]) ?? []).map((row) => ({
      id: row.id as string,
      title: row.title as string,
      file_url: row.file_url as string,
      file_size: row.file_size as string | null,
      file_type: row.file_type as string | null,
      section_id: row.section_id as string | null,
      created_at: row.created_at as string,
    }));
  }
}
