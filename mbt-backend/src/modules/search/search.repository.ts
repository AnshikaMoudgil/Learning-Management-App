import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class SearchRepository {
  constructor(private readonly supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async globalSearch(searchTerm: string) {
    const [coursesResult, recordingsResult, teachersResult] = await Promise.all(
      [
        // 1. Search Courses
        this.db
          .from('courses')
          .select('*, profiles!courses_instructor_id_fkey(full_name)')
          .or(
            `title.ilike.${searchTerm},description.ilike.${searchTerm},category.ilike.${searchTerm}`,
          )
          .eq('is_published', true)
          .limit(20),

        // 2. Search Recordings (Lessons)
        this.db
          .from('course_lessons')
          .select(
            '*, courses!inner(id, title, category, profiles!courses_instructor_id_fkey(full_name))',
          )
          .ilike('title', searchTerm)
          .limit(20),

        // 3. Search Teachers
        this.db
          .from('profiles')
          .select('*')
          .eq('role', 'instructor')
          .ilike('full_name', searchTerm)
          .limit(20),
      ],
    );

    let courses: any[] = coursesResult.data || [];
    let recordings: any[] = recordingsResult.data || [];
    let teachers: any[] = teachersResult.data || [];

    // If foreign key relations fail, fallback to simple select (similar to frontend fallback)
    if (coursesResult.error) {
      console.error('Courses search error:', coursesResult.error);
      const fallback = await this.db
        .from('courses')
        .select('*')
        .or(
          `title.ilike.${searchTerm},description.ilike.${searchTerm},category.ilike.${searchTerm}`,
        )
        .eq('is_published', true)
        .limit(20);
      courses = fallback.data || [];
    }

    if (recordingsResult.error) {
      console.error('Recordings search error:', recordingsResult.error);
      const fallback = await this.db
        .from('course_lessons')
        .select('*')
        .ilike('title', searchTerm)
        .limit(20);
      recordings = fallback.data || [];
    }

    if (teachersResult.error) {
      console.error('Teachers search error:', teachersResult.error);
      const fallback = await this.db
        .from('profiles')
        .select('*')
        .eq('role', 'instructor')
        .ilike('full_name', searchTerm)
        .limit(20);
      teachers = fallback.data || [];
    }

    return { courses, recordings, teachers };
  }
}
