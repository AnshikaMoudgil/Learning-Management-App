import { Injectable, NotFoundException } from '@nestjs/common';
import { CoursesRepository } from './courses.repository';
import { RedisService } from '../../common/redis/redis.service';
import type {
  Course,
  PaginatedResult,
  CourseLevel,
} from '../../common/types/course.type';

@Injectable()
export class CoursesService {
  constructor(
    private readonly coursesRepository: CoursesRepository,
    private readonly redisService: RedisService,
  ) {}

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

    const filters = {
      category: query.category,
      level: query.level,
      is_published: query.is_published,
      search: query.search,
    };

    const cacheKey = `courses:list:${JSON.stringify(filters)}:${page}:${limit}`;
    const redis = this.redisService.getClient();
    if (redis) {
      try {
        const cached = await redis.get(cacheKey);
        if (cached) {
          return JSON.parse(cached) as PaginatedResult<Course>;
        }
      } catch {
        // Fallback to database
      }
    }

    const { data, total } = await this.coursesRepository.findAll(
      filters,
      { page, limit },
    );

    const result = {
      data,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };

    if (redis) {
      try {
        await redis.set(cacheKey, JSON.stringify(result), 'EX', 60);
      } catch {
        // Ignore cache set failure
      }
    }

    return result;
  }

  async findByIdOrSlug(idOrSlug: string, userId?: string): Promise<Course> {
    const isUuid =
      /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(
        idOrSlug,
      );

    const cacheKey = isUuid ? `courses:id:${idOrSlug}` : `courses:slug:${idOrSlug}`;
    const redis = this.redisService.getClient();
    if (redis) {
      try {
        const cached = await redis.get(cacheKey);
        if (cached) {
          const course = JSON.parse(cached) as Course;
          if (!userId) {
            return course;
          }
          return this.coursesRepository.findDetailForUser(course, userId);
        }
      } catch {
        // Fallback to database
      }
    }

    const course = isUuid
      ? await this.coursesRepository.findById(idOrSlug)
      : await this.coursesRepository.findBySlug(idOrSlug);

    if (!course) {
      throw new NotFoundException('Course not found');
    }

    if (redis) {
      try {
        await redis.set(cacheKey, JSON.stringify(course), 'EX', 60);
      } catch {
        // Ignore cache set failure
      }
    }

    if (!userId) {
      return course;
    }

    return this.coursesRepository.findDetailForUser(course, userId);
  }
}

