import {
  Injectable,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

export interface CourseResource {
  id: string;
  course_id: string;
  section_id: string | null;
  section_title: string | null;
  title: string;
  file_url: string;
  file_size: string | null;
  file_type: string | null;
  created_at: string;
}

@Injectable()
export class ResourcesService {
  constructor(private readonly supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async getCourseResources(
    courseId: string,
    userId: string,
  ): Promise<CourseResource[]> {
    // Verify active enrollment
    const { data: enrollment } = await this.db
      .from('enrollments')
      .select('id')
      .eq('course_id', courseId)
      .eq('user_id', userId)
      .eq('status', 'active')
      .maybeSingle();

    if (!enrollment) {
      throw new ForbiddenException(
        'You must be enrolled in this course to access resources',
      );
    }

    const { data, error } = await this.db
      .from('course_resources')
      .select(
        'id, course_id, section_id, title, file_url, file_size, file_type, created_at, course_sections(title)',
      )
      .eq('course_id', courseId)
      .order('created_at', { ascending: true });

    if (error) throw new BadRequestException(error.message);

    return ((data as Record<string, unknown>[]) ?? []).map((row) => ({
      id: row.id as string,
      course_id: row.course_id as string,
      section_id: row.section_id as string | null,
      section_title:
        (row.course_sections as { title?: string } | null)?.title ?? null,
      title: row.title as string,
      file_url: row.file_url as string,
      file_size: row.file_size as string | null,
      file_type: row.file_type as string | null,
      created_at: row.created_at as string,
    }));
  }
}
