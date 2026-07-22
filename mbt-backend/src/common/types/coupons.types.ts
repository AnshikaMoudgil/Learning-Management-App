export interface CouponRow {
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

export interface CoursePriceRow {
  id: string;
  price: number | string;
  discount_price: number | string | null;
  is_published: boolean;
}

export interface ActiveCouponResult {
  id: string;
  code: string;
  discount_type: 'percentage' | 'fixed';
  discount_value: number | string;
  expires_at: string | null;
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
