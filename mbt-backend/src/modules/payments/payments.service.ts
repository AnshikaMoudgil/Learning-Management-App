import {
  BadGatewayException,
  BadRequestException,
  ConflictException,
  Injectable,
  InternalServerErrorException,
  Logger,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createHmac, timingSafeEqual } from 'crypto';
import { InjectQueue } from '@nestjs/bullmq';
import { Queue } from 'bullmq';
import { CouponsService } from '../coupons/coupons.service';
import { EnrollmentsService } from '../enrollments/enrollments.service';
import { NotificationsService } from '../notifications/notifications.service';
import { RazorpayService } from './razorpay.service';
import { PaymentsRepository } from './payments.repository';
import { RenewalPlansService } from '../renewal-plans/renewal-plans.service';
import type { CourseRow, PaymentRow } from '../../common/types/payments.types';

@Injectable()
export class PaymentsService {
  private readonly logger = new Logger(PaymentsService.name);
  private readonly pendingMinutes = 20;

  constructor(
    private readonly paymentsRepository: PaymentsRepository,
    private readonly couponsService: CouponsService,
    private readonly enrollmentsService: EnrollmentsService,
    private readonly notificationsService: NotificationsService,
    private readonly razorpayService: RazorpayService,
    private readonly configService: ConfigService,
    private readonly renewalPlansService: RenewalPlansService,
    @InjectQueue('invoices-queue') private readonly invoicesQueue: Queue,
  ) {}

  private get currency(): string {
    return this.configService.get<string>('razorpay.currency') ?? 'INR';
  }

  async createOrder(
    userId: string,
    courseIds: string[],
    couponCode?: string,
    allowRenewal = false,
    renewalPlanId?: string,
  ) {
    if (!courseIds.length) {
      throw new BadRequestException('At least one course is required');
    }

    // --- Renewal order path ---
    if (renewalPlanId) {
      return this.createRenewalOrder(userId, courseIds, renewalPlanId, couponCode);
    }

    const courses = await this.paymentsRepository.findCoursesByIds(courseIds);

    if (!allowRenewal) {
      for (const course of courses) {
        await this.assertNotEnrolled(userId, course.id);
      }
    }

    const totalBaseAmount = courses.reduce(
      (sum, c) => sum + this.effectivePrice(c),
      0,
    );

    const coupon = await this.couponsService.validateCouponForCheckoutMulti(
      couponCode,
      courses.map((c) => ({
        id: c.id,
        price: c.price,
        discount_price: c.discount_price,
        is_published: c.is_published,
      })),
      userId,
    );
    const amountSubunits = this.toSubunits(coupon.finalPrice);

    if (amountSubunits <= 0) {
      return this.handleFreeEnrollmentMulti(userId, courses, coupon);
    }

    const category = this.inferCategory(courses);
    const gateway = this.razorpayService.getGatewayForCategory(category);
    const receipt = `courses_${courseIds.length}_${Date.now()}`;
    const razorpayOrder = await this.razorpayService.createOrder({
      gateway,
      amountSubunits,
      currency: this.currency,
      receipt,
      notes: {
        userId,
        couponCode: coupon.code ?? '',
      },
    });
    const expiresAt = new Date(Date.now() + this.pendingMinutes * 60_000);

    const result = await this.paymentsRepository.insertPayment({
      user_id: userId,
      course_id: null,
      coupon_id: coupon.couponId ?? null,
      base_amount: coupon.baseAmount,
      discount_amount: coupon.discountAmount,
      amount_paid: coupon.finalPrice,
      amount_subunits: amountSubunits,
      currency: this.currency,
      razorpay_order_id: razorpayOrder.id,
      status: 'pending',
      expires_at: expiresAt.toISOString(),
    });

    if (result.error) {
      this.logger.error(`Failed to insert payment: ${result.error.message}`, {
        userId,
      });
      throw new InternalServerErrorException('Failed to create payment order');
    }

    const paymentId = result.data.id;

    const paymentItems = courses.map((course) => {
      const itemBase = this.effectivePrice(course);
      const itemRatio =
        totalBaseAmount > 0 ? itemBase / totalBaseAmount : 1 / courses.length;
      const itemDiscount = this.roundMoney(coupon.discountAmount * itemRatio);
      const itemPaid = this.roundMoney(Math.max(0, itemBase - itemDiscount));

      return {
        payment_id: paymentId,
        course_id: course.id,
        coupon_id: coupon.couponId ?? null,
        base_amount: itemBase,
        discount_amount: itemDiscount,
        amount_paid: itemPaid,
      };
    });

    const { error: itemsError } =
      await this.paymentsRepository.insertPaymentItems(paymentItems);

    if (itemsError) {
      this.logger.error(
        `Failed to insert payment items: ${itemsError.message}`,
        { paymentId },
      );
      await this.paymentsRepository.deletePayment(paymentId);
      throw new InternalServerErrorException('Failed to create payment order');
    }

    const storeName =
      category === 'hardware' ? 'MBT LMS - Hardware' : 'MBT LMS - Software';

    return {
      orderId: razorpayOrder.id,
      amount: amountSubunits,
      currency: this.currency,
      keyId: gateway.keyId,
      courseIds,
      expiresAt: expiresAt.toISOString(),
      reused: false,
      storeName,
    };
  }

  // ─── Renewal order helpers ──────────────────────────────────────────────────

  private async createRenewalOrder(
    userId: string,
    courseIds: string[],
    renewalPlanId: string,
    couponCode?: string,
  ) {
    if (courseIds.length !== 1) {
      throw new BadRequestException('Renewal is only supported for one course at a time');
    }
    const courseId = courseIds[0];

    const plan = await this.renewalPlansService.getPlanById(renewalPlanId);
    if (plan.course_id !== courseId) {
      throw new BadRequestException('Renewal plan does not belong to this course');
    }

    // Fetch course to determine hardware/software gateway
    const course = await this.paymentsRepository.findCourseById(courseId);
    const gateway = this.razorpayService.getGatewayForCategory(course.category);

    // Build a minimal CourseRow-like object for coupon validation
    const renewalCourseProxy = {
      id: course.id,
      price: Number(plan.price),
      discount_price: null,
      is_published: true,
    };

    const coupon = await this.couponsService.validateCouponForCheckoutMulti(
      couponCode,
      [renewalCourseProxy],
      userId,
    );
    const amountSubunits = this.toSubunits(coupon.finalPrice);
    const storeName =
      course.category?.toLowerCase().includes('hardware')
        ? 'MBT LMS - Hardware'
        : 'MBT LMS - Software';

    if (amountSubunits <= 0) {
      // Free renewal after coupon
      this.logger.log(`Free renewal for user ${userId}, plan ${renewalPlanId}`);
      const result = await this.paymentsRepository.insertPayment({
        user_id: userId,
        course_id: courseId,
        coupon_id: coupon.couponId ?? null,
        renewal_plan_id: renewalPlanId,
        base_amount: coupon.baseAmount,
        discount_amount: coupon.discountAmount,
        amount_paid: 0,
        amount_subunits: 0,
        currency: this.currency,
        razorpay_order_id: `free_${Date.now()}_${userId.slice(0, 8)}`,
        status: 'completed',
        razorpay_payment_id: `free_${Date.now()}`,
        razorpay_signature: 'free',
        expires_at: new Date(Date.now() + 3600_000).toISOString(),
      });
      if (result.error) {
        throw new InternalServerErrorException('Failed to create free renewal');
      }
      const payment = result.data;
      await this.paymentsRepository.insertPaymentItems([{
        payment_id: payment.id,
        course_id: courseId,
        coupon_id: coupon.couponId ?? null,
        base_amount: coupon.baseAmount,
        discount_amount: coupon.discountAmount,
        amount_paid: 0,
      }]);
      const enrollmentResult = await this.enrollmentsService.enrollFromPayment(
        payment.razorpay_order_id,
        `free_${Date.now()}`,
        'free',
      );
      const resultData = enrollmentResult as { paymentId?: string } | null;
      const resultPaymentId = resultData?.paymentId || payment.id;
      await this.queueInvoiceGeneration(resultPaymentId);
      return enrollmentResult;
    }

    const receipt = `renewal_${courseId.slice(0, 8)}_${Date.now()}`;
    const razorpayOrder = await this.razorpayService.createOrder({
      gateway,
      amountSubunits,
      currency: this.currency,
      receipt,
      notes: { userId, renewalPlanId, couponCode: coupon.code ?? '' },
    });
    const expiresAt = new Date(Date.now() + this.pendingMinutes * 60_000);

    const result = await this.paymentsRepository.insertPayment({
      user_id: userId,
      course_id: courseId,
      coupon_id: coupon.couponId ?? null,
      renewal_plan_id: renewalPlanId,
      base_amount: coupon.baseAmount,
      discount_amount: coupon.discountAmount,
      amount_paid: coupon.finalPrice,
      amount_subunits: amountSubunits,
      currency: this.currency,
      razorpay_order_id: razorpayOrder.id,
      status: 'pending',
      expires_at: expiresAt.toISOString(),
    });

    if (result.error) {
      throw new InternalServerErrorException('Failed to create renewal payment order');
    }

    const paymentId = result.data.id;
    await this.paymentsRepository.insertPaymentItems([{
      payment_id: paymentId,
      course_id: courseId,
      coupon_id: coupon.couponId ?? null,
      base_amount: coupon.baseAmount,
      discount_amount: coupon.discountAmount,
      amount_paid: coupon.finalPrice,
    }]);

    return {
      orderId: razorpayOrder.id,
      amount: amountSubunits,
      currency: this.currency,
      keyId: gateway.keyId,
      courseIds,
      expiresAt: expiresAt.toISOString(),
      reused: false,
      storeName,
    };
  }

  // ─── Free enrollment (multi course) ──────────────────────────────────────────

  private async handleFreeEnrollmentMulti(
    userId: string,
    courses: CourseRow[],
    coupon: {
      baseAmount: number;
      discountAmount: number;
      finalPrice: number;
      couponId?: string;
      code?: string;
    },
  ) {
    this.logger.log(
      `Free enrollment for user ${userId} for ${courses.length} courses`,
    );
    const result = await this.paymentsRepository.insertPayment({
      user_id: userId,
      course_id: null,
      coupon_id: coupon.couponId ?? null,
      base_amount: coupon.baseAmount,
      discount_amount: coupon.discountAmount,
      amount_paid: 0,
      amount_subunits: 0,
      currency: this.currency,
      razorpay_order_id: `free_${Date.now()}_${userId.slice(0, 8)}`,
      status: 'completed',
      razorpay_payment_id: `free_${Date.now()}`,
      razorpay_signature: 'free',
      expires_at: new Date(Date.now() + 3600_000).toISOString(),
    });

    if (result.error) {
      this.logger.error(`Free enrollment insert failed: ${result.error.message}`, {
        userId,
      });
      throw new InternalServerErrorException(
        'Failed to create free enrollment',
      );
    }

    const payment = result.data;
    const paymentId = payment.id;
    const totalBaseAmount = courses.reduce(
      (s, c) => s + this.effectivePrice(c),
      0,
    );

    const paymentItems = courses.map((course) => {
      const itemBase = this.effectivePrice(course);
      const itemRatio =
        totalBaseAmount > 0 ? itemBase / totalBaseAmount : 1 / courses.length;
      const itemDiscount = this.roundMoney(coupon.discountAmount * itemRatio);
      return {
        payment_id: paymentId,
        course_id: course.id,
        coupon_id: coupon.couponId ?? null,
        base_amount: itemBase,
        discount_amount: itemDiscount,
        amount_paid: 0,
      };
    });

    await this.paymentsRepository.insertPaymentItems(paymentItems);

    const enrollmentResult = await this.enrollmentsService.enrollFromPayment(
      payment.razorpay_order_id,
      `free_${Date.now()}`,
      'free',
    );
    const resultData = enrollmentResult as { paymentId?: string } | null;
    const resultPaymentId = resultData?.paymentId || paymentId;
    await this.queueInvoiceGeneration(resultPaymentId);
    return enrollmentResult;
  }

  async verifyPayment(input: {
    razorpayOrderId: string;
    razorpayPaymentId: string;
    razorpaySignature: string;
  }) {
    const payment = await this.paymentsRepository.findPaymentByOrderId(
      input.razorpayOrderId,
    );
    const gateway = await this.getGatewayForPayment(payment);

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

    try {
      return await this.completePayment(input, payment.user_id);
    } catch (err) {
      this.logger.error(
        `Payment verification succeeded but enrollment failed: ${(err as Error).message}`,
        {
          razorpayOrderId: input.razorpayOrderId,
          razorpayPaymentId: input.razorpayPaymentId,
        },
      );
      await this.paymentsRepository.updatePaymentStatusByOrderId(
        input.razorpayOrderId,
        'failed',
      );
      throw err;
    }
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
    const eventType =
      typeof payload.event === 'string' ? payload.event : 'unknown';
    const eventId = typeof payload.id === 'string' ? payload.id : null;
    const paymentEntity = this.getWebhookPaymentEntity(payload);
    const orderId = paymentEntity?.order_id;
    const paymentId = paymentEntity?.id;

    const signatureVerified =
      eventId && orderId
        ? await this.verifyWebhookSignatureForOrder(rawBody, signature, orderId)
        : false;

    const logged = await this.logWebhook({
      eventId,
      orderId,
      paymentId,
      eventType,
      payload,
      signatureVerified,
    });

    if (!signatureVerified) {
      if (!logged) {
        throw new BadRequestException('Invalid Razorpay webhook signature');
      }
      return { received: true, processed: false };
    }

    if (eventType !== 'payment.captured' || !orderId || !paymentId) {
      return { received: true, processed: false };
    }

    let payment: PaymentRow;
    try {
      payment = await this.paymentsRepository.findPaymentByOrderId(orderId);
    } catch {
      return { received: true, processed: false };
    }

    if (payment.amount_subunits !== Number(paymentEntity.amount)) {
      this.logger.warn(`Webhook amount mismatch for order ${orderId}`);
      throw new BadRequestException('Webhook payment amount mismatch');
    }

    try {
      await this.completePayment(
        {
          razorpayOrderId: orderId,
          razorpayPaymentId: paymentId,
          razorpaySignature: signature,
        },
        payment.user_id,
      );
    } catch (err) {
      this.logger.error(
        `Webhook enrollment failed for order ${orderId}: ${(err as Error).message}`,
        {
          razorpayOrderId: orderId,
          razorpayPaymentId: paymentId,
        },
      );
      await this.paymentsRepository.updatePaymentStatusByOrderId(
        orderId,
        'failed',
      );
      throw err;
    }

    await this.markWebhookProcessed(eventId);
    return { received: true, processed: true };
  }

  private async completePayment(
    input: {
      razorpayOrderId: string;
      razorpayPaymentId: string;
      razorpaySignature: string;
    },
    userId: string,
  ) {
    const result = await this.enrollmentsService.enrollFromPayment(
      input.razorpayOrderId,
      input.razorpayPaymentId,
      input.razorpaySignature,
    );
    const resultData = result as { paymentId?: string } | null;
    if (resultData?.paymentId) {
      await this.queueInvoiceGeneration(resultData.paymentId);
      await this.notificationsService.notify(userId, {
        type: 'payment_confirmation',
        title: 'Payment Successful',
        body: `Your payment was successful. Receipt #${resultData.paymentId.slice(-8).toUpperCase()}`,
        data: { payment_id: resultData.paymentId },
      });
    }
    return result;
  }

  private async queueInvoiceGeneration(paymentId: string) {
    try {
      await this.invoicesQueue.add('generate-invoice', { paymentId });
      this.logger.log(`Queued invoice generation for payment: ${paymentId}`);
    } catch (err) {
      this.logger.error(
        `Failed to queue invoice generation for payment ${paymentId}: ${(err as Error).message}`,
      );
    }
  }

  private async assertNotEnrolled(userId: string, courseId: string) {
    const enrollment =
      await this.paymentsRepository.findActiveEnrollment(userId, courseId);

    if (enrollment) {
      throw new ConflictException('User is already enrolled in this course');
    }
  }

  private async getGatewayForPayment(payment: PaymentRow) {
    if (payment.course_id) {
      const course = await this.paymentsRepository.findCourseById(
        payment.course_id,
      );
      return this.razorpayService.getGatewayForCategory(course.category);
    }

    const firstItem =
      await this.paymentsRepository.findFirstPaymentItem(payment.id);

    if (firstItem) {
      return this.razorpayService.getGatewayForCategory(
        firstItem.courses?.category ?? null,
      );
    }

    return this.razorpayService.getGatewayForCategory(null);
  }

  private inferCategory(courses: CourseRow[]): string | null {
    const hasHardware = courses.some((c) =>
      c.category?.toLowerCase().includes('hardware'),
    );
    return hasHardware ? 'hardware' : 'software';
  }

  private effectivePrice(course: CourseRow): number {
    return Number(course.discount_price ?? course.price);
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

  private async verifyWebhookSignatureForOrder(
    rawBody: Buffer,
    signature: string,
    orderId: string,
  ): Promise<boolean> {
    try {
      const payment = await this.paymentsRepository.findPaymentByOrderId(
        orderId,
      );
      const gateway = await this.getGatewayForPayment(payment);
      return this.verifyWebhookSecret(rawBody, signature, gateway.name);
    } catch {
      const fallback =
        this.configService.get<string>('razorpay.hardware.webhookSecret') ??
        this.configService.get<string>('razorpay.software.webhookSecret');
      if (fallback) {
        const expected = createHmac('sha256', fallback)
          .update(rawBody)
          .digest('hex');
        return this.safeCompare(expected, signature);
      }
      return false;
    }
  }

  private verifyWebhookSecret(
    rawBody: Buffer,
    signature: string,
    gatewayName: 'hardware' | 'software',
  ): boolean {
    const secret = this.configService.get<string>(
      `razorpay.${gatewayName}.webhookSecret`,
    );
    if (!secret) {
      throw new BadGatewayException(
        `Razorpay ${gatewayName} webhook secret is not configured`,
      );
    }

    const expected = createHmac('sha256', secret).update(rawBody).digest('hex');
    return this.safeCompare(expected, signature);
  }

  private safeCompare(expected: string, actual: string): boolean {
    if (expected.length !== actual.length) return false;
    const expectedBuffer = Buffer.from(expected);
    const actualBuffer = Buffer.from(actual);
    return timingSafeEqual(expectedBuffer, actualBuffer);
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
  }): Promise<boolean> {
    const { error } = await this.paymentsRepository.insertWebhookLog({
      razorpay_event_id: input.eventId,
      razorpay_order_id: input.orderId || null,
      razorpay_payment_id: input.paymentId || null,
      event_type: input.eventType,
      payload: input.payload,
      signature_verified: input.signatureVerified,
    });

    if (!error) return true;

    if (
      error &&
      (error as unknown as Record<string, unknown>).code === '23505'
    ) {
      return false;
    }

    this.logger.warn(`Failed to log webhook: ${error.message}`);
    return false;
  }

  private async markWebhookProcessed(eventId: string | null) {
    if (!eventId) return;

    await this.paymentsRepository.updateWebhookProcessed(eventId);
  }

  private toSubunits(amount: number): number {
    return Math.round(amount * 100);
  }

  private roundMoney(value: number): number {
    return Math.round(value * 100) / 100;
  }
}
