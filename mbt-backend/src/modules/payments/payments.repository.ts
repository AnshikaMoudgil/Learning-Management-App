import { Injectable, InternalServerErrorException, NotFoundException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import type { CourseRow, PaymentRow } from '../../common/types/payments.types';

@Injectable()
export class PaymentsRepository {
  constructor(private readonly supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async insertPayment(data: Record<string, unknown>) {
    const { data: payment, error } = await this.db
      .from('payments')
      .insert(data as never)
      .select('*')
      .single();

    if (error) return { error };
    return { data: payment as PaymentRow };
  }

  async insertPaymentItems(items: Record<string, unknown>[]) {
    const { error } = await this.db
      .from('payment_items')
      .insert(items as never);

    return { error };
  }

  async deletePayment(id: string) {
    await this.db.from('payments').delete().eq('id', id);
  }

  async updatePaymentStatusByOrderId(orderId: string, status: string) {
    await this.db
      .from('payments')
      .update({ status } as never)
      .eq('razorpay_order_id', orderId);
  }

  async findCourseById(courseId: string): Promise<CourseRow> {
    const { data, error } = await this.db
      .from('courses')
      .select('id, title, category, price, discount_price, is_published')
      .eq('id', courseId)
      .maybeSingle();

    if (error) {
      throw new InternalServerErrorException('Failed to look up course');
    }

    if (!data || !(data as CourseRow).is_published) {
      throw new NotFoundException('Course not found');
    }

    return data as CourseRow;
  }

  async findCoursesByIds(courseIds: string[]): Promise<CourseRow[]> {
    const { data, error } = await this.db
      .from('courses')
      .select('id, title, category, price, discount_price, is_published')
      .in('id', courseIds);

    if (error) {
      throw new InternalServerErrorException('Failed to look up courses');
    }

    const rows = (data ?? []) as CourseRow[];
    const missing = courseIds.filter(
      (id) =>
        !rows.find((r) => r.id === id) ||
        !rows.find((r) => r.id === id && r.is_published),
    );
    if (missing.length > 0) {
      throw new NotFoundException(`Courses not found: ${missing.join(', ')}`);
    }

    return rows;
  }

  async findActiveEnrollment(userId: string, courseId: string) {
    const { data, error } = await this.db
      .from('enrollments')
      .select('id')
      .eq('user_id', userId)
      .eq('course_id', courseId)
      .eq('status', 'active')
      .or(
        `validity_end_at.is.null,validity_end_at.gt.${new Date().toISOString()}`,
      )
      .maybeSingle();

    if (error) {
      throw new InternalServerErrorException(
        'Failed to check enrollment status',
      );
    }

    return data as { id: string } | null;
  }

  async findPaymentByOrderId(orderId: string): Promise<PaymentRow> {
    const { data, error } = await this.db
      .from('payments')
      .select('id, user_id, course_id, coupon_id, amount_subunits, currency, razorpay_order_id, razorpay_payment_id, status, expires_at')
      .eq('razorpay_order_id', orderId)
      .maybeSingle();

    if (error) {
      throw new InternalServerErrorException('Failed to look up payment');
    }

    if (!data) {
      throw new NotFoundException('Payment order not found');
    }

    return data as PaymentRow;
  }

  async findFirstPaymentItem(paymentId: string) {
    const { data: firstItem } = await this.db
      .from('payment_items')
      .select('course_id, courses(category)')
      .eq('payment_id', paymentId)
      .limit(1)
      .maybeSingle();

    return firstItem as {
      course_id: string;
      courses: { category: string | null } | null;
    } | null;
  }

  async insertWebhookLog(data: Record<string, unknown>) {
    const { error } = await this.db.from('webhook_logs').insert(data as never);
    return { error };
  }

  async updateWebhookProcessed(eventId: string) {
    await this.db
      .from('webhook_logs')
      .update({ processed_at: new Date().toISOString() } as never)
      .eq('razorpay_event_id', eventId);
  }
}
