import {
  BadGatewayException,
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createHmac, timingSafeEqual } from 'crypto';
import { SupabaseService } from '../supabase/supabase.service';
import { CouponsService } from '../coupons/coupons.service';
import { EnrollmentsService } from '../enrollments/enrollments.service';
import { RazorpayService } from './razorpay.service';

interface CourseRow {
  id: string;
  title: string;
  category: string | null;
  price: number | string;
  discount_price: number | string | null;
  is_published: boolean;
}

interface PaymentRow {
  id: string;
  user_id: string;
  course_id: string;
  coupon_id: string | null;
  amount_subunits: number;
  currency: string;
  razorpay_order_id: string;
  razorpay_payment_id: string | null;
  status: 'pending' | 'completed' | 'failed' | 'expired' | 'refunded';
  expires_at: string;
  courses?: Pick<CourseRow, 'category'> | null;
}

@Injectable()
export class PaymentsService {
  private readonly pendingMinutes = 20;
  private readonly currency = 'INR';

  constructor(
    private readonly supabaseService: SupabaseService,
    private readonly couponsService: CouponsService,
    private readonly enrollmentsService: EnrollmentsService,
    private readonly razorpayService: RazorpayService,
    private readonly configService: ConfigService,
  ) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async createOrder(
    userId: string,
    courseId: string,
    couponCode?: string,
    allowRenewal = false,
  ) {
    const course = await this.getCourse(courseId);
    if (!allowRenewal) {
      await this.assertNotEnrolled(userId, courseId);
    }

    const existing = await this.findReusablePendingPayment(userId, courseId);
    if (existing) {
      return this.toOrderResponse(existing, course);
    }

    const coupon = await this.couponsService.validateCouponForCheckout(
      couponCode,
      courseId,
    );
    const amountSubunits = this.toSubunits(coupon.finalPrice);

    if (amountSubunits <= 0) {
      throw new BadRequestException('Free checkout is not supported yet');
    }

    const gateway = this.razorpayService.getGatewayForCategory(course.category);
    const razorpayOrder = await this.razorpayService.createOrder({
      gateway,
      amountSubunits,
      currency: this.currency,
      receipt: `course_${courseId.slice(0, 8)}_${Date.now()}`,
      notes: {
        userId,
        courseId,
        couponCode: coupon.code ?? '',
      },
    });
    const expiresAt = new Date(Date.now() + this.pendingMinutes * 60_000);

    const { data, error } = await this.db
      .from('payments')
      .insert({
        user_id: userId,
        course_id: courseId,
        coupon_id: coupon.couponId ?? null,
        base_amount: coupon.baseAmount,
        discount_amount: coupon.discountAmount,
        amount_paid: coupon.finalPrice,
        amount_subunits: amountSubunits,
        currency: this.currency,
        razorpay_order_id: razorpayOrder.id,
        status: 'pending',
        expires_at: expiresAt.toISOString(),
      } as never)
      .select('*')
      .single();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return this.toOrderResponse(data, course);
  }

  async verifyPayment(input: {
    razorpayOrderId: string;
    razorpayPaymentId: string;
    razorpaySignature: string;
  }) {
    const payment = await this.getPaymentByOrderId(input.razorpayOrderId);
    const course = await this.getCourse(payment.course_id);
    const gateway = this.razorpayService.getGatewayForCategory(course.category);

    this.verifyCheckoutSignature(
      input.razorpayOrderId,
      input.razorpayPaymentId,
      input.razorpaySignature,
      gateway.keySecret,
    );

    const razorpayPayment = await this.razorpayService.fetchPayment(
      gateway,
      input.razorpayPaymentId,
    );

    this.assertRazorpayPaymentMatchesPendingPayment(payment, razorpayPayment);

    return this.completePayment(input);
  }

  async handleWebhook(
    rawBody: Buffer | undefined,
    signature: string | undefined,
  ) {
    if (!rawBody?.length || !signature) {
      throw new BadRequestException(
        'Missing Razorpay webhook body or signature',
      );
    }

    const payload = JSON.parse(rawBody.toString('utf8')) as Record<
      string,
      unknown
    >;
    const eventType = typeof payload.event === 'string' ? payload.event : 'unknown';
    const eventId = typeof payload.id === 'string' ? payload.id : null;
    const paymentEntity = this.getWebhookPaymentEntity(payload);
    const orderId = paymentEntity?.order_id;
    const paymentId = paymentEntity?.id;

    const signatureVerified = this.verifyWebhookSignature(rawBody, signature);

    await this.logWebhook({
      eventId,
      orderId,
      paymentId,
      eventType,
      payload,
      signatureVerified,
    });

    if (!signatureVerified) {
      throw new BadRequestException('Invalid Razorpay webhook signature');
    }

    if (eventType !== 'payment.captured' || !orderId || !paymentId) {
      return { received: true, processed: false };
    }

    const payment = await this.getPaymentByOrderId(orderId);
    if (payment.amount_subunits !== Number(paymentEntity.amount)) {
      throw new BadRequestException('Webhook payment amount mismatch');
    }

    const result = await this.completePayment({
      razorpayOrderId: orderId,
      razorpayPaymentId: paymentId,
      razorpaySignature: signature,
    });

    await this.markWebhookProcessed(eventId);
    return { received: true, processed: true, result };
  }

  private async completePayment(input: {
    razorpayOrderId: string;
    razorpayPaymentId: string;
    razorpaySignature: string;
  }) {
    return this.enrollmentsService.enrollFromPayment(
      input.razorpayOrderId,
      input.razorpayPaymentId,
      input.razorpaySignature,
    );
  }

  private async getCourse(courseId: string): Promise<CourseRow> {
    const { data, error } = await this.db
      .from('courses')
      .select('id, title, category, price, discount_price, is_published')
      .eq('id', courseId)
      .maybeSingle();

    if (error) {
      throw new BadRequestException(error.message);
    }

    if (!data || !(data as CourseRow).is_published) {
      throw new NotFoundException('Course not found');
    }

    return data;
  }

  private async assertNotEnrolled(userId: string, courseId: string) {
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
      throw new BadRequestException(error.message);
    }

    if (data) {
      throw new BadRequestException('User is already enrolled in this course');
    }
  }

  private async findReusablePendingPayment(
    userId: string,
    courseId: string,
  ): Promise<PaymentRow | null> {
    const { data, error } = await this.db
      .from('payments')
      .select('*')
      .eq('user_id', userId)
      .eq('course_id', courseId)
      .eq('status', 'pending')
      .gt('expires_at', new Date().toISOString())
      .order('created_at', { ascending: false })
      .limit(1)
      .maybeSingle();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data ?? null;
  }

  private async getPaymentByOrderId(orderId: string): Promise<PaymentRow> {
    const { data, error } = await this.db
      .from('payments')
      .select('*')
      .eq('razorpay_order_id', orderId)
      .maybeSingle();

    if (error) {
      throw new BadRequestException(error.message);
    }

    if (!data) {
      throw new NotFoundException('Payment order not found');
    }

    return data;
  }

  private toOrderResponse(payment: PaymentRow, course: CourseRow) {
    const gateway = this.razorpayService.getGatewayForCategory(course.category);
    return {
      orderId: payment.razorpay_order_id,
      amount: payment.amount_subunits,
      currency: payment.currency,
      keyId: gateway.keyId,
      courseId: payment.course_id,
      expiresAt: payment.expires_at,
      reused: payment.status === 'pending',
    };
  }

  private verifyCheckoutSignature(
    orderId: string,
    paymentId: string,
    signature: string,
    keySecret: string,
  ) {
    const expected = createHmac('sha256', keySecret)
      .update(`${orderId}|${paymentId}`)
      .digest('hex');

    if (!this.safeCompare(expected, signature)) {
      throw new BadRequestException('Invalid Razorpay payment signature');
    }
  }

  private verifyWebhookSignature(rawBody: Buffer, signature: string): boolean {
    const secrets = [
      this.configService.get<string>('razorpay.hardware.webhookSecret'),
      this.configService.get<string>('razorpay.software.webhookSecret'),
    ].filter((secret): secret is string => Boolean(secret));

    if (secrets.length === 0) {
      throw new BadGatewayException(
        'Razorpay webhook secret is not configured',
      );
    }

    return secrets.some((secret) => {
      const expected = createHmac('sha256', secret)
        .update(rawBody)
        .digest('hex');
      return this.safeCompare(expected, signature);
    });
  }

  private safeCompare(expected: string, actual: string): boolean {
    const expectedBuffer = Buffer.from(expected);
    const actualBuffer = Buffer.from(actual);

    return (
      expectedBuffer.length === actualBuffer.length &&
      timingSafeEqual(expectedBuffer, actualBuffer)
    );
  }

  private assertRazorpayPaymentMatchesPendingPayment(
    payment: PaymentRow,
    razorpayPayment: {
      id: string;
      order_id: string;
      amount: number;
      currency: string;
      status: string;
      captured: boolean;
    },
  ) {
    if (razorpayPayment.order_id !== payment.razorpay_order_id) {
      throw new BadRequestException('Razorpay order mismatch');
    }

    if (razorpayPayment.amount !== payment.amount_subunits) {
      throw new BadRequestException('Razorpay amount mismatch');
    }

    if (razorpayPayment.currency !== payment.currency) {
      throw new BadRequestException('Razorpay currency mismatch');
    }

    if (!razorpayPayment.captured && razorpayPayment.status !== 'authorized') {
      throw new BadRequestException(
        'Razorpay payment is not captured or authorized',
      );
    }
  }

  private getWebhookPaymentEntity(payload: Record<string, unknown>) {
    const payloadBody = payload.payload as Record<string, unknown> | undefined;
    const payment = payloadBody?.payment as Record<string, unknown> | undefined;
    const entity = payment?.entity as Record<string, unknown> | undefined;

    if (!entity) {
      return null;
    }

    return {
      id: typeof entity.id === 'string' ? entity.id : '',
      order_id: typeof entity.order_id === 'string' ? entity.order_id : '',
      amount: Number(entity.amount ?? 0),
    };
  }

  private async logWebhook(input: {
    eventId: string | null;
    orderId?: string;
    paymentId?: string;
    eventType: string;
    payload: Record<string, unknown>;
    signatureVerified: boolean;
  }) {
    if (input.eventId) {
      const { data: existing, error: lookupError } = await this.db
        .from('webhook_logs')
        .select('id')
        .eq('razorpay_event_id', input.eventId)
        .maybeSingle();

      if (lookupError) {
        throw new BadRequestException(lookupError.message);
      }

      if (existing) {
        return;
      }
    }

    const { error } = await this.db.from('webhook_logs').insert({
      razorpay_event_id: input.eventId,
      razorpay_order_id: input.orderId || null,
      razorpay_payment_id: input.paymentId || null,
      event_type: input.eventType,
      payload: input.payload,
      signature_verified: input.signatureVerified,
    } as never);

    if (error) {
      throw new BadRequestException(error.message);
    }
  }

  private async markWebhookProcessed(eventId: string | null) {
    if (!eventId) return;

    await this.db
      .from('webhook_logs')
      .update({ processed_at: new Date().toISOString() } as never)
      .eq('razorpay_event_id', eventId);
  }

  private toSubunits(amount: number): number {
    return Math.round(amount * 100);
  }
}
