import { Injectable, NotFoundException } from '@nestjs/common';
import { CoursesRepository } from './courses.repository';
import type {
  Course,
  PaginatedResult,
  CourseLevel,
} from '../../common/types/course.type';

@Injectable()
export class CoursesService {
  constructor(private readonly coursesRepository: CoursesRepository) {}

  async findAll(query: {
    category?: string;
    level?: CourseLevel;
    is_published?: boolean;
    search?: string;
    page?: number;
    limit?: number;
  }): Promise<PaginatedResult<Course>> {
    const page = Math.max(1, query.page ?? 1);
    const limit = Math.min(100, Math.max(1, query.limit ?? 10));

    const { data, total } = await this.coursesRepository.findAll(
      {
        category: query.category,
        level: query.level,
        is_published: query.is_published,
        search: query.search,
      },
      { page, limit },
    );

    return {
      data,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async findByIdOrSlug(idOrSlug: string, userId?: string): Promise<Course> {
    const isUuid =
      /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(
        idOrSlug,
      );

    const course = isUuid
      ? await this.coursesRepository.findById(idOrSlug)
      : await this.coursesRepository.findBySlug(idOrSlug);

    if (!course) {
      throw new NotFoundException('Course not found');
    }

    if (!userId) {
      return course;
    }

    return this.coursesRepository.findDetailForUser(course, userId);
  }
}
