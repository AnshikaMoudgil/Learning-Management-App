import { Injectable, BadRequestException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class EnrollmentsRepository {
  constructor(private readonly supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async callCompletePaymentAndEnroll(
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
      return { error };
    }

    return { data };
  }

  async findEnrollmentsByUserId(userId: string) {
    const { data, error } = await this.db
      .from('enrollments')
      .select(
        `
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
      `,
      )
      .eq('user_id', userId);

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data as unknown[];
  }

  async findLessonCountsByCourseIds(courseIds: string[]) {
    const { data, error } = await this.db
      .from('course_lessons')
      .select('course_id')
      .in('course_id', courseIds);

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data as unknown[];
  }

  async findCompletedProgressByUserAndCourses(userId: string, courseIds: string[]) {
    const { data, error } = await this.db
      .from('user_lesson_progress')
      .select('course_id')
      .eq('user_id', userId)
      .eq('is_completed', true)
      .in('course_id', courseIds);

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data as { course_id: string }[];
  }
}
