import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class SearchRepository {
  constructor(private readonly supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async globalSearch(searchTerm: string) {
    const query = searchTerm.replace(/%/g, '').trim();
    if (!query) {
      return { courses: [], recordings: [], teachers: [] };
    }

    // Split words by space and join with '&' for a valid tsquery.
    // Example: "Mobile ic" -> "Mobile & ic:*"
    const words = query.split(/\s+/).filter(Boolean);
    const ftsQuery = words.length > 0 
      ? words.map((w, index) => index === words.length - 1 ? `${w}:*` : w).join(' & ')
      : '';

    const [coursesResult, recordingsResult, teachersResult] = await Promise.all(
      [
        // 1. Search Courses via FTS (with ILIKE fallback)
        this.db
          .from('courses')
          .select('*, profiles!courses_instructor_id_fkey(full_name)')
          .textSearch('search_document', ftsQuery, { config: 'english' })
          .eq('is_published', true)
          .limit(20),

        // 2. Search Recordings (Lessons) via FTS
        this.db
          .from('course_lessons')
          .select(
            '*, courses!inner(id, title, category, profiles!courses_instructor_id_fkey(full_name))',
          )
          .textSearch('search_document', ftsQuery, { config: 'english' })
          .limit(20),

        // 3. Search Teachers via FTS
        this.db
          .from('profiles')
          .select('*')
          .eq('role', 'instructor')
          .textSearch('search_document', ftsQuery, { config: 'english' })
          .limit(20),
      ],
    );

    let courses: any[] = (coursesResult.data as any[]) || [];
    let recordings: any[] = (recordingsResult.data as any[]) || [];
    let teachers: any[] = (teachersResult.data as any[]) || [];

    // Fallback to ILIKE if FTS fails (e.g. migration not yet applied)
    if (coursesResult.error) {
      console.error('Courses FTS error, falling back to ILIKE:', coursesResult.error);
      const fallback = await this.db
        .from('courses')
        .select('*')
        .or(
          `title.ilike.${searchTerm},description.ilike.${searchTerm},category.ilike.${searchTerm}`,
        )
        .eq('is_published', true)
        .limit(20);
      courses = (fallback.data as any[]) || [];
    }

    if (recordingsResult.error) {
      console.error('Recordings FTS error, falling back to ILIKE:', recordingsResult.error);
      const fallback = await this.db
        .from('course_lessons')
        .select('*')
        .ilike('title', searchTerm)
        .limit(20);
      recordings = (fallback.data as any[]) || [];
    }

    if (teachersResult.error) {
      console.error('Teachers FTS error, falling back to ILIKE:', teachersResult.error);
      const fallback = await this.db
        .from('profiles')
        .select('*')
        .eq('role', 'instructor')
        .ilike('full_name', searchTerm)
        .limit(20);
      teachers = (fallback.data as any[]) || [];
    }

    return { courses, recordings, teachers };
  }
}
