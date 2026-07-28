import {
  Injectable,
  ForbiddenException,
} from '@nestjs/common';
import { ResourcesRepository } from './resources.repository';
import type { CourseResource } from '../../common/types/resources.types';

@Injectable()
export class ResourcesService {
  constructor(private readonly resourcesRepository: ResourcesRepository) {}

  async getCourseResources(
    courseId: string,
    userId: string,
  ): Promise<CourseResource[]> {
    const enrollment = await this.resourcesRepository.findActiveEnrollment(courseId, userId);

    if (!enrollment) {
      throw new ForbiddenException(
        'You must be enrolled in this course to access resources',
      );
    }

    const data = await this.resourcesRepository.findCourseResources(courseId);

    return data.map((row) => ({
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
