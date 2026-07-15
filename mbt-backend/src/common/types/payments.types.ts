export interface CourseRow {
  id: string;
  title: string;
  category: string | null;
  price: number | string;
  discount_price: number | string | null;
  is_published: boolean;
}

export interface PaymentRow {
  id: string;
  user_id: string;
  course_id: string | null;
  coupon_id: string | null;
  amount_subunits: number;
  currency: string;
  razorpay_order_id: string;
  razorpay_payment_id: string | null;
  status: 'pending' | 'completed' | 'failed' | 'expired' | 'refunded';
  expires_at: string;
  courses?: Pick<CourseRow, 'category'> | null;
}
