import { Injectable, BadRequestException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class ResourcesRepository {
  constructor(private readonly supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async findActiveEnrollment(courseId: string, userId: string) {
    const { data: enrollment } = await this.db
      .from('enrollments')
      .select('id')
      .eq('course_id', courseId)
      .eq('user_id', userId)
      .eq('status', 'active')
      .maybeSingle();

    return enrollment as { id: string } | null;
  }

  async findCourseResources(courseId: string) {
    const { data, error } = await this.db
      .from('course_resources')
      .select(
        'id, course_id, section_id, title, file_url, file_size, file_type, created_at, course_sections(title)',
      )
      .eq('course_id', courseId)
      .order('created_at', { ascending: true });

    if (error) throw new BadRequestException(error.message);

    return (data ?? []) as Record<string, unknown>[];
  }
}
