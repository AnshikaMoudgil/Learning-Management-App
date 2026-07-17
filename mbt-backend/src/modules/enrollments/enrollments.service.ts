import {
  BadRequestException,
  Injectable,
  InternalServerErrorException,
  Logger,
} from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class EnrollmentsService {
  private readonly logger = new Logger(EnrollmentsService.name);

  constructor(private readonly supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async enrollFromPayment(
    razorpayOrderId: string,
    razorpayPaymentId: string,
    razorpaySignature: string,
  ) {
    const { data, error } = await this.db.rpc('complete_payment_and_enroll', {
      p_order_id: razorpayOrderId,
      p_payment_id: razorpayPaymentId,
      p_signature: razorpaySignature,
    } as never);

    if (error) {
      this.logger.error(
        `RPC complete_payment_and_enroll failed: ${error.message}`,
        {
          razorpayOrderId,
          razorpayPaymentId,
          details: error.details,
          hint: error.hint,
          code: error.code,
        },
      );
      if (error.message?.includes('already enrolled')) {
        throw new BadRequestException(error.message);
      }
      throw new InternalServerErrorException('Failed to complete enrollment');
    }

    return data;
  }

  async getMyEnrollments(userId: string) {
    const { data, error } = await this.db
      .from('enrollments')
      .select(`
        id,
        course_id,
        status,
        progress_percent,
        validity_end_at,
        enrolled_at,
        courses (
          title,
          thumbnail_url,
          estimated_duration,
          profiles!instructor_id (
            full_name
          )
        )
      `)
      .eq('user_id', userId);

    if (error) {
      throw new BadRequestException(error.message);
    }

    const rows = (data as Record<string, any>[]) ?? [];
    if (rows.length === 0) return [];

    const courseIds = rows.map((r) => r.course_id as string);

    const { data: lessonCounts, error: countError } = await this.db
      .from('course_lessons')
      .select('course_id')
      .in('course_id', courseIds);

    if (countError) {
      throw new BadRequestException(countError.message);
    }

    const countMap = new Map<string, number>();
    for (const lesson of (lessonCounts as { course_id: string }[] ?? [])) {
      countMap.set(lesson.course_id, (countMap.get(lesson.course_id) ?? 0) + 1);
    }

    return rows.map((row) => {
      const course = row.courses;
      const instructorName = course?.profiles?.full_name ?? null;

      return {
        enrollment_id: row.id,
        course_id: row.course_id,
        title: course?.title ?? null,
        thumbnail_url: course?.thumbnail_url ?? null,
        instructor_name: instructorName,
        progress_percent: row.progress_percent,
        status: row.status,
        validity_end_at: row.validity_end_at,
        total_lessons: countMap.get(row.course_id as string) ?? 0,
        estimated_duration: course?.estimated_duration ?? null,
        enrolled_at: row.enrolled_at,
      };
    });
  }
}
