import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SupabaseService } from '../supabase/supabase.service';
import { InvoicesRepository } from './invoices.repository';
import { PdfGeneratorService } from './pdf-generator.service';
import type {
  PaymentRow,
  InvoiceRow,
  InvoiceItemRow,
} from '../../common/types/invoices.types';

const COMPANY_SNAPSHOT = {
  name: 'Mobile Business Technology',
  email: 'support@mbt.com',
  phone: '+20123456789',
  address: 'Egypt',
  website: 'mbt.com',
  taxNumber: '123456789',
};

@Injectable()
export class InvoicesService {
  private readonly logger = new Logger(InvoicesService.name);

  constructor(
    private readonly invoicesRepository: InvoicesRepository,
    private readonly supabaseService: SupabaseService,
    private readonly pdfGeneratorService: PdfGeneratorService,
    private readonly configService: ConfigService,
  ) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async generateDailyInvoiceNumber(): Promise<string> {
    const dateObj = new Date();
    const yyyy = dateObj.getFullYear();
    const mm = String(dateObj.getMonth() + 1).padStart(2, '0');
    const dd = String(dateObj.getDate()).padStart(2, '0');
    const yyyymmdd = `${yyyy}${mm}${dd}`;
    const prefix = `MBT-${yyyymmdd}-`;

    const row = await this.invoicesRepository.findLatestInvoiceNumber(prefix);
    const seq = row ? parseInt(row.invoice_number.slice(-6), 10) + 1 : 1;
    return `${prefix}${String(seq).padStart(6, '0')}`;
  }

  async createInvoiceForPayment(paymentId: string): Promise<void> {
    this.logger.log(`Starting invoice generation for payment ID: ${paymentId}`);

    const payment = await this.invoicesRepository.findPaymentById(paymentId);

    if (payment.status !== 'completed') {
      this.logger.warn(
        `Payment ${paymentId} is not in completed status. Current status: ${payment.status}`,
      );
      return;
    }

    const existingInvoice = await this.invoicesRepository.findInvoiceByPaymentId(paymentId);

    if (existingInvoice) {
      this.logger.log(
        `Invoice already exists for payment ${paymentId}: ${existingInvoice.invoice_number}`,
      );
      return;
    }

    const userId = payment.user_id;
    const profile = await this.invoicesRepository.findProfileById(userId);

    const { data: authUserResult } = (await this.db.auth.admin.getUserById(
      userId,
    )) as {
      data: {
        user: {
          email?: string;
          phone?: string;
          user_metadata?: { full_name?: string };
        } | null;
      } | null;
    };
    const authUser = authUserResult?.user;

    const customerSnapshot = {
      name:
        profile?.full_name ||
        authUser?.user_metadata?.full_name ||
        'Valued Customer',
      email: authUser?.email || 'customer@example.com',
      phone: authUser?.phone || undefined,
    };

    const isGrouped = !payment.course_id;

    interface InvoiceItemData {
      course_id: string;
      base_amount: number;
      discount_amount: number;
      amount_paid: number;
      title: string;
      short_description: string | null;
    }

    let invoiceItemsData: InvoiceItemData[];

    if (isGrouped) {
      const paymentItems = await this.invoicesRepository.findPaymentItemsByPaymentId(paymentId);

      if (!paymentItems?.length) {
        throw new NotFoundException(
          `No payment items found for payment: ${paymentId}`,
        );
      }

      const courseIds = paymentItems.map((i) => i.course_id);
      const courses = await this.invoicesRepository.findCoursesByIds(courseIds);

      const courseMap = new Map<
        string,
        { title: string; short_description: string | null }
      >();
      if (courses) {
        for (const c of courses) {
          courseMap.set(c.id, c);
        }
      }

      invoiceItemsData = paymentItems.map((item) => {
        const course = courseMap.get(item.course_id);
        return {
          course_id: item.course_id,
          base_amount: Number(item.base_amount),
          discount_amount: Number(item.discount_amount),
          amount_paid: Number(item.amount_paid),
          title: course?.title ?? 'Unknown Course',
          short_description: course?.short_description ?? null,
        };
      });
    } else {
      const singleCourseId = payment.course_id;
      if (!singleCourseId) {
        throw new NotFoundException(
          `Course not found for payment: ${paymentId}`,
        );
      }

      const course = await this.invoicesRepository.findCourseById(singleCourseId);

      if (!course) {
        throw new NotFoundException(
          `Course not found for ID: ${singleCourseId}`,
        );
      }

      invoiceItemsData = [
        {
          course_id: singleCourseId,
          base_amount: Number(payment.base_amount),
          discount_amount: Number(payment.discount_amount),
          amount_paid: Number(payment.amount_paid),
          title: course.title,
          short_description: course.short_description,
        },
      ];
    }

    const invoiceNumber = await this.generateDailyInvoiceNumber();

    const subtotal = invoiceItemsData.reduce((s, i) => s + i.base_amount, 0);
    const discount = invoiceItemsData.reduce(
      (s, i) => s + i.discount_amount,
      0,
    );
    const total = invoiceItemsData.reduce((s, i) => s + i.amount_paid, 0);
    const currency = payment.currency || 'INR';

    const newInvoice = await this.invoicesRepository.insertInvoice({
      invoice_number: invoiceNumber,
      payment_id: paymentId,
      user_id: userId,
      status: 'paid',
      currency,
      subtotal,
      discount,
      tax: 0.0,
      total,
      paid_at: payment.updated_at || new Date().toISOString(),
      company_snapshot: COMPANY_SNAPSHOT,
      customer_snapshot: customerSnapshot,
    });

    const invoiceItems: InvoiceItemRow[] = invoiceItemsData.map((item) => ({
      invoice_id: newInvoice.id,
      item_type: 'course',
      item_id: item.course_id,
      title: item.title,
      description: item.short_description || undefined,
      quantity: 1,
      unit_price: item.base_amount,
      discount: item.discount_amount,
      tax: 0.0,
      total: item.amount_paid,
    }));

    await this.invoicesRepository.insertInvoiceItems(invoiceItems);

    const pdfItems = invoiceItemsData.map((item) => ({
      title: item.title,
      description: item.short_description || undefined,
      quantity: 1,
      unitPrice: item.base_amount,
      discount: item.discount_amount,
      tax: 0.0,
      total: item.amount_paid,
    }));

    const pdfBuffer = await this.pdfGeneratorService.generateInvoicePdf({
      invoiceNumber,
      currency,
      subtotal,
      discount,
      tax: 0.0,
      total,
      issuedAt: new Date(newInvoice.issued_at),
      paidAt: new Date(payment.updated_at || new Date().toISOString()),
      companySnapshot: COMPANY_SNAPSHOT,
      customerSnapshot,
      items: pdfItems,
    });

    const fileName = `${invoiceNumber}.pdf`;
    const filePath = `invoices/${fileName}`;

    const { error: uploadError } = await this.db.storage
      .from('invoices')
      .upload(filePath, pdfBuffer, {
        contentType: 'application/pdf',
        upsert: true,
      });

    if (uploadError) {
      this.logger.error(`Failed to upload invoice PDF: ${uploadError.message}`);
      throw new Error(`Failed to upload invoice PDF: ${uploadError.message}`);
    }

    const { data: urlData } = this.db.storage
      .from('invoices')
      .getPublicUrl(filePath);

    await this.invoicesRepository.updateInvoicePdfUrl(newInvoice.id, urlData.publicUrl);

    this.logger.log(
      `Invoice ${invoiceNumber} generated and uploaded successfully!`,
    );
  }

  async findByUser(userId: string): Promise<InvoiceRow[]> {
    return this.invoicesRepository.findInvoicesByUserId(userId);
  }

  async findOneForUser(
    id: string,
    userId: string,
  ): Promise<InvoiceRow & { invoice_items?: unknown }> {
    return this.invoicesRepository.findInvoiceByIdAndUser(id, userId);
  }
}
