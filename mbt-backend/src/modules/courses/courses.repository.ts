import { Injectable, BadRequestException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import type {
  Course,
  CourseEnrollmentState,
  CourseLesson,
  CourseLevel,
  CourseSection,
} from '../../common/types/course.type';

export interface CourseFilters {
  category?: string;
  level?: CourseLevel;
  is_published?: boolean;
  search?: string;
}

export interface PaginationParams {
  page: number;
  limit: number;
}

@Injectable()
export class CoursesRepository {
  constructor(private supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  private readonly courseSelect = '*, profiles!instructor_id ( full_name )';

  private mapCourse(row: Record<string, unknown>): Course {
    const profiles = row.profiles as { full_name?: string } | null;
    return {
      ...(row as unknown as Course),
      instructor_name: profiles?.full_name ?? null,
    };
  }

  async findAll(
    filters: CourseFilters,
    pagination: PaginationParams,
  ): Promise<{ data: Course[]; total: number }> {
    let query = this.db
      .from('courses')
      .select(this.courseSelect, { count: 'exact' });

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
      query = query.ilike('title', `%${filters.search}%`);
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
      .select(this.courseSelect)
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
      .select(this.courseSelect)
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

    return {
      ...course,
      sections: detailSections,
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

    return data ?? [];
  }

  private async findLessons(courseId: string): Promise<CourseLesson[]> {
    const { data, error } = await this.db
      .from('course_lessons')
      .select(
        'id, section_id, course_id, title, description, video_url, video_duration, is_free_preview, sort_order',
      )
      .eq('course_id', courseId)
      .order('sort_order', { ascending: true });

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data ?? [];
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
