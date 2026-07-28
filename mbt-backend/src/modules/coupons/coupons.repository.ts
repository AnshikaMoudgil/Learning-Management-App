import { Injectable, InternalServerErrorException, NotFoundException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import type { CoursePriceRow, CouponRow } from '../../common/types/coupons.types';

@Injectable()
export class CouponsRepository {
  constructor(private readonly supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async findActiveCoupons(nowISO: string) {
    const { data, error } = await this.db
      .from('coupons')
      .select(
        'id, code, discount_type, discount_value, expires_at, max_uses, uses_count',
      )
      .eq('is_active', true)
      .or(`starts_at.is.null,starts_at.lte.${nowISO}`)
      .or(`expires_at.is.null,expires_at.gt.${nowISO}`);

    if (error)
      throw new InternalServerErrorException('Failed to fetch active coupons');

    return (data ?? []) as {
      id: string;
      code: string;
      discount_type: 'percentage' | 'fixed';
      discount_value: number;
      expires_at: string | null;
      max_uses: number | null;
      uses_count: number;
    }[];
  }

  async findCompletedPaymentByUserAndCoupon(userId: string, couponId: string) {
    const { data } = await this.db
      .from('payments')
      .select('id')
      .eq('user_id', userId)
      .eq('coupon_id', couponId)
      .eq('status', 'completed')
      .limit(1)
      .maybeSingle();

    return data as { id: string } | null;
  }

  async findByCode(normalizedCode: string) {
    const { data: coupon, error } = await this.db
      .from('coupons')
      .select('*')
      .ilike('code', normalizedCode)
      .maybeSingle();

    if (error) {
      throw new InternalServerErrorException('Failed to validate coupon');
    }

    return coupon as CouponRow | null;
  }

  async findCoursePrice(courseId: string): Promise<CoursePriceRow> {
    const { data, error } = await this.db
      .from('courses')
      .select('id, price, discount_price, is_published')
      .eq('id', courseId)
      .maybeSingle();

    if (error) {
      throw new InternalServerErrorException('Failed to look up course');
    }

    if (!data || !(data as CoursePriceRow).is_published) {
      throw new NotFoundException('Course not found');
    }

    return data as CoursePriceRow;
  }

  async findCoursesPrices(courseIds: string[]): Promise<CoursePriceRow[]> {
    const { data, error } = await this.db
      .from('courses')
      .select('id, price, discount_price, is_published')
      .in('id', courseIds);

    if (error) {
      throw new InternalServerErrorException('Failed to look up courses');
    }

    const rows = (data ?? []) as CoursePriceRow[];
    const missing = courseIds.filter((id) => !rows.find((r) => r.id === id));
    if (missing.length > 0) {
      throw new NotFoundException(`Courses not found: ${missing.join(', ')}`);
    }

    return rows;
  }
}
