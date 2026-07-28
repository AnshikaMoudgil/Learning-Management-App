import {
  BadRequestException,
  Injectable,
  InternalServerErrorException,
  Logger,
} from '@nestjs/common';
import { EnrollmentsRepository } from './enrollments.repository';
import type {
  LessonCountRow,
  EnrollmentRow,
} from '../../common/types/enrollments.types';

@Injectable()
export class EnrollmentsService {
  private readonly logger = new Logger(EnrollmentsService.name);

  constructor(private readonly enrollmentsRepository: EnrollmentsRepository) {}

  async enrollFromPayment(
    razorpayOrderId: string,
    razorpayPaymentId: string,
    razorpaySignature: string,
  ) {
    const result =
      await this.enrollmentsRepository.callCompletePaymentAndEnroll(
        razorpayOrderId,
        razorpayPaymentId,
        razorpaySignature,
      );

    if (result.error) {
      this.logger.error(
        `RPC complete_payment_and_enroll failed: ${result.error.message}`,
        {
          razorpayOrderId,
          razorpayPaymentId,
          details: result.error.details,
          hint: result.error.hint,
          code: result.error.code,
        },
      );
      if (result.error.message?.includes('already enrolled')) {
        throw new BadRequestException(result.error.message);
      }
      throw new InternalServerErrorException('Failed to complete enrollment');
    }

    return result.data;
  }

  async getMyEnrollments(userId: string) {
    const rows = (await this.enrollmentsRepository.findEnrollmentsByUserId(
      userId,
    )) as EnrollmentRow[];
    if (rows.length === 0) return [];

    const courseIds = rows.map((r) => r.course_id);

    const [lessonCountsResult, completedResult] = await Promise.all([
      this.enrollmentsRepository.findLessonCountsByCourseIds(courseIds),
      this.enrollmentsRepository.findCompletedProgressByUserAndCourses(
        userId,
        courseIds,
      ),
    ]);

    const lessonCountsData = lessonCountsResult as LessonCountRow[];
    const completedData = completedResult as { course_id: string }[];

    const totalMap = new Map<string, number>();
    for (const lesson of lessonCountsData ?? []) {
      totalMap.set(lesson.course_id, (totalMap.get(lesson.course_id) ?? 0) + 1);
    }

    const completedMap = new Map<string, number>();
    for (const lp of completedData ?? []) {
      completedMap.set(lp.course_id, (completedMap.get(lp.course_id) ?? 0) + 1);
    }

    return rows.map((row) => {
      const course = row.courses;
      const instructorName = course?.profiles?.full_name ?? null;
      const total = totalMap.get(row.course_id) ?? 0;
      const completed = completedMap.get(row.course_id) ?? 0;
      const liveProgress =
        total > 0 ? Math.round((completed / total) * 100) : 0;

      return {
        enrollment_id: row.id,
        course_id: row.course_id,
        title: course?.title ?? null,
        thumbnail_url: course?.thumbnail_url ?? null,
        instructor_name: instructorName,
        progress_percent: liveProgress,
        status: row.status,
        validity_end_at: row.validity_end_at,
        total_lessons: total,
        estimated_duration: course?.estimated_duration ?? null,
        category: course?.category ?? null,
        level: course?.level ?? null,
        enrolled_at: row.enrolled_at,
      };
    });
  }
}
