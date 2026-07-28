import {
  BadRequestException,
  Injectable,
} from '@nestjs/common';
import { CouponsRepository } from './coupons.repository';
import type {
  ActiveCouponResult,
  CouponRow,
  CoursePriceRow,
  CouponValidationResult,
} from '../../common/types/coupons.types';

@Injectable()
export class CouponsService {
  constructor(private readonly couponsRepository: CouponsRepository) {}

  async getActiveCoupons(): Promise<ActiveCouponResult[]> {
    const now = new Date();
    const nowISO = now.toISOString();
    const rows = await this.couponsRepository.findActiveCoupons(nowISO);

    return rows
      .filter((c) => {
        if (c.max_uses !== null && c.uses_count >= c.max_uses) return false;
        return true;
      })
      .map((c) => ({
        id: c.id,
        code: c.code,
        discount_type: c.discount_type,
        discount_value: c.discount_value,
        expires_at: c.expires_at,
      }));
  }

  async assertUserCouponNotUsed(
    userId: string,
    couponId: string,
  ): Promise<void> {
    const data = await this.couponsRepository.findCompletedPaymentByUserAndCoupon(userId, couponId);

    if (data) {
      throw new BadRequestException('You have already used this coupon');
    }
  }

  async validateCoupon(
    code: string,
    courseId: string,
    preloadedCourse?: CoursePriceRow,
    totalBaseAmount?: number,
  ): Promise<CouponValidationResult> {
    const course = preloadedCourse ?? (await this.couponsRepository.findCoursePrice(courseId));
    const baseAmount = totalBaseAmount ?? this.getBaseAmount(course);
    const normalizedCode = code.trim().toUpperCase();

    if (!normalizedCode) {
      throw new BadRequestException('Coupon code is required');
    }

    const coupon = await this.couponsRepository.findByCode(normalizedCode);

    if (!coupon) {
      return this.invalid(baseAmount, 'Coupon not found');
    }

    return this.evaluateCoupon(coupon, baseAmount);
  }

  async validateCouponForCheckout(
    code: string | undefined,
    courseId: string,
    userId?: string,
    preloadedCourse?: CoursePriceRow,
  ): Promise<CouponValidationResult> {
    const course = preloadedCourse ?? (await this.couponsRepository.findCoursePrice(courseId));
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

    if (userId && result.couponId) {
      await this.assertUserCouponNotUsed(userId, result.couponId);
    }

    return result;
  }

  async validateCouponForCheckoutMulti(
    code: string | undefined,
    courses: {
      id: string;
      price: number | string;
      discount_price: number | string | null;
      is_published: boolean;
    }[],
    userId?: string,
  ): Promise<CouponValidationResult> {
    const baseAmount = courses.reduce((sum, c) => {
      return sum + this.getBaseAmount(c);
    }, 0);

    if (!code?.trim()) {
      return {
        valid: true,
        discountAmount: 0,
        finalPrice: this.roundMoney(baseAmount),
        baseAmount: this.roundMoney(baseAmount),
      };
    }

    const result = await this.validateCoupon(code, courses[0].id, courses[0], baseAmount);
    if (!result.valid) {
      throw new BadRequestException(result.reason || 'Invalid coupon');
    }

    if (userId && result.couponId) {
      await this.assertUserCouponNotUsed(userId, result.couponId);
    }

    return {
      ...result,
      baseAmount: this.roundMoney(baseAmount),
      finalPrice: this.roundMoney(
        Math.max(0, baseAmount - result.discountAmount),
      ),
    };
  }

  async validateCouponForCart(
    code: string,
    courseIds: string[],
    userId: string,
  ): Promise<CouponValidationResult> {
    const courses = await this.couponsRepository.findCoursesPrices(courseIds);
    const result = await this.validateCouponForCheckoutMulti(
      code,
      courses,
      userId,
    );
    return result;
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
