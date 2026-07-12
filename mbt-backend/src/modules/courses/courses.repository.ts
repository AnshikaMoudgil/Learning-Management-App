import { Injectable, BadRequestException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import type { Course, CourseLevel } from '../../common/types/course.type';

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

  async findAll(
    filters: CourseFilters,
    pagination: PaginationParams,
  ): Promise<{ data: Course[]; total: number }> {
    let query = this.db.from('courses').select('*', { count: 'exact' });

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

    return { data: (data as Course[]) ?? [], total: count ?? 0 };
  }

  async findById(id: string): Promise<Course | null> {
    const { data, error } = await this.db
      .from('courses')
      .select('*')
      .eq('id', id)
      .maybeSingle();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data as Course | null;
  }

  async findBySlug(slug: string): Promise<Course | null> {
    const { data, error } = await this.db
      .from('courses')
      .select('*')
      .eq('slug', slug)
      .maybeSingle();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data as Course | null;
  }
}
