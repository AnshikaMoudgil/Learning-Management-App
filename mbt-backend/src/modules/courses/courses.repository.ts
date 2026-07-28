import { Injectable, BadRequestException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import type {
  Course,
  CourseEnrollmentState,
  CourseLesson,
  CourseSection,
  CourseFilters,
  PaginationParams,
} from '../../common/types/course.type';

@Injectable()
export class CoursesRepository {
  constructor(private supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  private readonly courseDetailSelect =
    '*, profiles!instructor_id ( full_name, avatar_url, instructor_profiles ( specialization ) )';

  private readonly courseListSelect =
    'id, title, slug, short_description, thumbnail_url, category, level, price, discount_price, estimated_duration, average_rating, reviews_count, is_bestseller, total_lessons, instructor_id, created_at, profiles!instructor_id ( full_name, avatar_url )';

  private mapCourse(row: Record<string, unknown>): Course {
    const profiles = row.profiles as {
      full_name?: string;
      avatar_url?: string;
      instructor_profiles?:
        { specialization?: string } | { specialization?: string }[];
    } | null;
    const instructorProfile = Array.isArray(profiles?.instructor_profiles)
      ? profiles?.instructor_profiles[0]
      : profiles?.instructor_profiles;
    return {
      ...(row as unknown as Course),
      instructor_name: profiles?.full_name ?? null,
      instructor_avatar_url: profiles?.avatar_url ?? null,
      instructor_specialization: instructorProfile?.specialization ?? null,
    };
  }

  async findAll(
    filters: CourseFilters,
    pagination: PaginationParams,
  ): Promise<{ data: Course[]; total: number }> {
    let query = this.db
      .from('courses')
      .select(this.courseListSelect, { count: 'exact' });

    if (filters.category) {
      query = query.eq('category', filters.category);
    }

    if (filters.level) {
      query = query.eq('level', filters.level);
    }

    if (filters.is_published !== undefined) {
      query = query.eq('is_published', filters.is_published);
    }

    if (filters.search) {
      query = query.textSearch('search_document', filters.search.trim(), {
        config: 'english',
      });
    }

    const from = (pagination.page - 1) * pagination.limit;
    const to = from + pagination.limit - 1;

    const { data, error, count } = await query
      .order('created_at', { ascending: false })
      .range(from, to);

    if (error) {
      throw new BadRequestException(error.message);
    }

    const courses = ((data as Record<string, unknown>[]) ?? []).map((row) =>
      this.mapCourse(row),
    );

    return { data: courses, total: count ?? 0 };
  }

  async findById(id: string): Promise<Course | null> {
    const { data, error } = await this.db
      .from('courses')
      .select(this.courseDetailSelect)
      .eq('id', id)
      .maybeSingle();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data ? this.mapCourse(data) : null;
  }

  async findBySlug(slug: string): Promise<Course | null> {
    const { data, error } = await this.db
      .from('courses')
      .select(this.courseDetailSelect)
      .eq('slug', slug)
      .maybeSingle();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data ? this.mapCourse(data) : null;
  }

  async findDetailForUser(course: Course, userId: string): Promise<Course> {
    const enrollment = await this.findActiveEnrollment(course.id, userId);
    const isEnrolled = Boolean(enrollment);
    const [sections, lessons] = await Promise.all([
      this.findSections(course.id),
      this.findLessons(course.id),
    ]);
    const lessonsBySection = lessons.reduce<Record<string, CourseLesson[]>>(
      (acc, lesson) => {
        const sanitizedLesson =
          isEnrolled || lesson.is_free_preview
            ? lesson
            : { ...lesson, video_url: null };
        acc[lesson.section_id] = [
          ...(acc[lesson.section_id] ?? []),
          sanitizedLesson,
        ];
        return acc;
      },
      {},
    );

    const detailSections = sections.map((section) => ({
      ...section,
      lessons: lessonsBySection[section.id] ?? [],
    }));

    const totalLessons = detailSections.reduce(
      (sum, section) => sum + section.lessons.length,
      0,
    );

    return {
      ...course,
      sections: detailSections,
      total_lessons: totalLessons,
      enrollment: this.toEnrollmentState(enrollment),
    };
  }

  private async findSections(courseId: string): Promise<CourseSection[]> {
    const { data, error } = await this.db
      .from('course_sections')
      .select('id, course_id, title, description, sort_order')
      .eq('course_id', courseId)
      .order('sort_order', { ascending: true });

    if (error) {
      throw new BadRequestException(error.message);
    }

    return (data ?? []) as CourseSection[];
  }

  private async findLessons(courseId: string): Promise<CourseLesson[]> {
    const { data, error } = await this.db
      .from('course_lessons')
      .select(
        'id, section_id, course_id, title, description, video_asset_id, video_url, video_duration, is_free_preview, sort_order, media_assets!video_asset_id(id, storage_url, duration, thumbnail_url, status)',
      )
      .eq('course_id', courseId)
      .order('sort_order', { ascending: true });

    if (error) {
      throw new BadRequestException(error.message);
    }

    return ((data as Record<string, unknown>[]) ?? []).map((row) => {
      const asset = row.media_assets as {
        storage_url?: string | null;
        duration?: number | null;
        thumbnail_url?: string | null;
        status?: string | null;
      } | null;
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
      const { media_assets, ...lesson } = row;
      return {
        ...(lesson as unknown as CourseLesson),
        video_url: asset?.storage_url ?? (row.video_url as string | null),
        video_duration:
          asset?.duration != null
            ? String(asset.duration)
            : (row.video_duration as string | null),
        video_status: asset?.status ?? null,
        thumbnail_url: asset?.thumbnail_url ?? null,
      };
    });
  }

  private async findActiveEnrollment(courseId: string, userId: string) {
    const { data, error } = await this.db
      .from('enrollments')
      .select('id, status, progress_percent, validity_end_at')
      .eq('course_id', courseId)
      .eq('user_id', userId)
      .eq('status', 'active')
      .or(
        `validity_end_at.is.null,validity_end_at.gt.${new Date().toISOString()}`,
      )
      .maybeSingle();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data as {
      id: string;
      status: string;
      progress_percent: number;
      validity_end_at: string | null;
    } | null;
  }

  private toEnrollmentState(
    enrollment: {
      id: string;
      status: string;
      progress_percent: number;
      validity_end_at: string | null;
    } | null,
  ): CourseEnrollmentState {
    return {
      isEnrolled: Boolean(enrollment),
      enrollmentId: enrollment?.id ?? null,
      status: enrollment?.status ?? null,
      progressPercent: enrollment?.progress_percent ?? 0,
      validityEndAt: enrollment?.validity_end_at ?? null,
    };
  }
}
