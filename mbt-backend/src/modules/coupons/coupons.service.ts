import {
  BadRequestException,
  Injectable,
  InternalServerErrorException,
  NotFoundException,
} from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

interface CouponRow {
  id: string;
  code: string;
  discount_type: 'percentage' | 'fixed';
  discount_value: number | string;
  max_uses: number | null;
  uses_count: number;
  min_purchase_amount: number | string;
  starts_at: string | null;
  expires_at: string | null;
  is_active: boolean;
}

interface CoursePriceRow {
  id: string;
  price: number | string;
  discount_price: number | string | null;
  is_published: boolean;
}

export interface CouponValidationResult {
  valid: boolean;
  couponId?: string;
  code?: string;
  discountAmount: number;
  finalPrice: number;
  baseAmount: number;
  reason?: string;
}

@Injectable()
export class CouponsService {
  constructor(private readonly supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async validateCoupon(
    code: string,
    courseId: string,
  ): Promise<CouponValidationResult> {
    const course = await this.getCoursePrice(courseId);
    const baseAmount = this.getBaseAmount(course);
    const normalizedCode = code.trim().toUpperCase();

    if (!normalizedCode) {
      throw new BadRequestException('Coupon code is required');
    }

    const { data: coupon, error } = await this.db
      .from('coupons')
      .select('*')
      .ilike('code', normalizedCode)
      .maybeSingle();

    if (error) {
      throw new InternalServerErrorException('Failed to validate coupon');
    }

    if (!coupon) {
      return this.invalid(baseAmount, 'Coupon not found');
    }

    return this.evaluateCoupon(coupon, baseAmount);
  }

  async validateCouponForCheckout(
    code: string | undefined,
    courseId: string,
  ): Promise<CouponValidationResult> {
    const course = await this.getCoursePrice(courseId);
    const baseAmount = this.getBaseAmount(course);

    if (!code?.trim()) {
      return {
        valid: true,
        discountAmount: 0,
        finalPrice: baseAmount,
        baseAmount,
      };
    }

    const result = await this.validateCoupon(code, courseId);
    if (!result.valid) {
      throw new BadRequestException(result.reason || 'Invalid coupon');
    }

    return result;
  }

  private async getCoursePrice(courseId: string): Promise<CoursePriceRow> {
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

    return data;
  }

  private getBaseAmount(course: CoursePriceRow): number {
    return Number(course.discount_price ?? course.price);
  }

  private evaluateCoupon(
    coupon: CouponRow,
    baseAmount: number,
  ): CouponValidationResult {
    const now = Date.now();

    if (!coupon.is_active) {
      return this.invalid(baseAmount, 'Coupon is inactive');
    }

    if (coupon.starts_at && new Date(coupon.starts_at).getTime() > now) {
      return this.invalid(baseAmount, 'Coupon is not active yet');
    }

    if (coupon.expires_at && new Date(coupon.expires_at).getTime() <= now) {
      return this.invalid(baseAmount, 'Coupon has expired');
    }

    if (coupon.max_uses !== null && coupon.uses_count >= coupon.max_uses) {
      return this.invalid(baseAmount, 'Coupon exhausted');
    }

    if (baseAmount < Number(coupon.min_purchase_amount)) {
      return this.invalid(baseAmount, 'Minimum purchase amount not met');
    }

    const rawDiscount =
      coupon.discount_type === 'percentage'
        ? (baseAmount * Number(coupon.discount_value)) / 100
        : Number(coupon.discount_value);
    const discountAmount = this.roundMoney(Math.min(rawDiscount, baseAmount));
    const finalPrice = this.roundMoney(
      Math.max(0, baseAmount - discountAmount),
    );

    return {
      valid: true,
      couponId: coupon.id,
      code: coupon.code,
      discountAmount,
      finalPrice,
      baseAmount: this.roundMoney(baseAmount),
    };
  }

  private invalid(baseAmount: number, reason: string): CouponValidationResult {
    return {
      valid: false,
      discountAmount: 0,
      finalPrice: this.roundMoney(baseAmount),
      baseAmount: this.roundMoney(baseAmount),
      reason,
    };
  }

  private roundMoney(value: number): number {
    return Math.round(value * 100) / 100;
  }
}
