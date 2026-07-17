import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SupabaseService } from '../supabase/supabase.service';
import { PdfGeneratorService } from './pdf-generator.service';
import type {
  PaymentRow,
  ProfileRow,
  CourseRow,
  PaymentItemRow,
  NewInvoiceRow,
  ExistingInvoiceRow,
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
    private readonly supabaseService: SupabaseService,
    private readonly pdfGeneratorService: PdfGeneratorService,
    private readonly configService: ConfigService,
  ) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  /**
   * Generates a daily-based sequential invoice number: MBT-YYYYMMDD-XXXXXX
   */
  async generateDailyInvoiceNumber(): Promise<string> {
    const dateObj = new Date();
    const yyyy = dateObj.getFullYear();
    const mm = String(dateObj.getMonth() + 1).padStart(2, '0');
    const dd = String(dateObj.getDate()).padStart(2, '0');
    const yyyymmdd = `${yyyy}${mm}${dd}`;
    const prefix = `MBT-${yyyymmdd}-`;

    const { data } = await this.db
      .from('invoices')
      .select('invoice_number')
      .like('invoice_number', `${prefix}%`)
      .order('invoice_number', { ascending: false })
      .limit(1);

    const seq = data?.length ? parseInt((data[0] as any).invoice_number.slice(-6), 10) + 1 : 1;
    return `${prefix}${String(seq).padStart(6, '0')}`;
  }

  /**
   * Generates an invoice for a completed payment
   */
  async createInvoiceForPayment(paymentId: string): Promise<void> {
    this.logger.log(`Starting invoice generation for payment ID: ${paymentId}`);

    // 1. Fetch payment details
    const { data: payment, error: paymentError } = (await this.db
      .from('payments')
      .select('*')
      .eq('id', paymentId)
      .single()) as unknown as {
      data: PaymentRow | null;
      error: { message: string } | null;
    };

    if (paymentError || !payment) {
      this.logger.error(`Failed to find payment: ${paymentError?.message}`);
      throw new NotFoundException(`Payment not found: ${paymentId}`);
    }

    if (payment.status !== 'completed') {
      this.logger.warn(
        `Payment ${paymentId} is not in completed status. Current status: ${payment.status}`,
      );
      return;
    }

    // Check if invoice already exists for this payment to ensure idempotency
    const { data: existingInvoice } = (await this.db
      .from('invoices')
      .select('id, invoice_number, pdf_url')
      .eq('payment_id', paymentId)
      .single()) as unknown as {
      data: ExistingInvoiceRow | null;
    };

    if (existingInvoice) {
      this.logger.log(
        `Invoice already exists for payment ${paymentId}: ${existingInvoice.invoice_number}`,
      );
      return;
    }

    // 2. Fetch User profile and Auth credentials
    const userId = payment.user_id;
    const { data: profile } = (await this.db
      .from('profiles')
      .select('full_name')
      .eq('id', userId)
      .single()) as unknown as {
      data: ProfileRow | null;
    };

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

    // 3. Fetch invoice items (single course or grouped checkout)
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
      const { data: paymentItems } = (await this.db
        .from('payment_items')
        .select('course_id, base_amount, discount_amount, amount_paid')
        .eq('payment_id', paymentId)) as unknown as {
        data: PaymentItemRow[] | null;
      };

      if (!paymentItems?.length) {
        throw new NotFoundException(
          `No payment items found for payment: ${paymentId}`,
        );
      }

      const courseIds = paymentItems.map((i) => i.course_id);
      const { data: courses } = (await this.db
        .from('courses')
        .select('id, title, short_description')
        .in('id', courseIds)) as unknown as {
        data: CourseRow[] | null;
      };

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

      const { data: course } = (await this.db
        .from('courses')
        .select('title, short_description')
        .eq('id', singleCourseId)
        .single()) as unknown as {
        data: { title: string; short_description: string | null } | null;
      };

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

    // 4. Generate daily invoice number
    const invoiceNumber = await this.generateDailyInvoiceNumber();

    // 5. Compute totals
    const subtotal = invoiceItemsData.reduce((s, i) => s + i.base_amount, 0);
    const discount = invoiceItemsData.reduce(
      (s, i) => s + i.discount_amount,
      0,
    );
    const total = invoiceItemsData.reduce((s, i) => s + i.amount_paid, 0);
    const currency = payment.currency || 'INR';

    // 6. Create Invoice in database
    const { data: newInvoice, error: invoiceError } = (await this.db
      .from('invoices')
      .insert({
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
      } as never)
      .select('id, issued_at')
      .single()) as unknown as {
      data: NewInvoiceRow | null;
      error: { message: string } | null;
    };

    if (invoiceError || !newInvoice) {
      this.logger.error(`Failed to create invoice: ${invoiceError?.message}`);
      throw new Error(`Failed to create invoice: ${invoiceError?.message}`);
    }

    // 7. Create Invoice Items in database
    for (const item of invoiceItemsData) {
      const invoiceItem: InvoiceItemRow = {
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
      };
      const { error: itemError } = await this.db
        .from('invoice_items')
        .insert(invoiceItem as never);

      if (itemError) {
        this.logger.error(
          `Failed to create invoice item: ${itemError.message}`,
        );
        throw new Error(`Failed to create invoice item: ${itemError.message}`);
      }
    }

    // 8. Generate PDF
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

    // 9. Upload PDF to Supabase Storage
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

    // Get PDF public URL
    const { data: urlData } = this.db.storage
      .from('invoices')
      .getPublicUrl(filePath);

    // 10. Update Invoice with pdfUrl
    const { error: updateError } = await this.db
      .from('invoices')
      .update({ pdf_url: urlData.publicUrl } as never)
      .eq('id', newInvoice.id);

    if (updateError) {
      this.logger.error(
        `Failed to update invoice pdfUrl: ${updateError.message}`,
      );
      throw new Error(
        `Failed to update invoice pdfUrl: ${updateError.message}`,
      );
    }

    this.logger.log(
      `Invoice ${invoiceNumber} generated and uploaded successfully!`,
    );
  }

  async findByUser(userId: string): Promise<InvoiceRow[]> {
    const { data, error } = (await this.db
      .from('invoices')
      .select(
        `
        id,
        invoice_number,
        status,
        currency,
        subtotal,
        discount,
        tax,
        total,
        issued_at,
        paid_at,
        pdf_url,
        payment_id,
        customer_snapshot,
        company_snapshot
      `,
      )
      .eq('user_id', userId)
      .order('issued_at', { ascending: false })) as unknown as {
      data: InvoiceRow[] | null;
      error: { message: string } | null;
    };

    if (error) {
      this.logger.error(
        `Failed to fetch invoices for user ${userId}: ${error.message}`,
      );
      throw new Error('Failed to fetch invoices');
    }

    return data || [];
  }

  async findOneForUser(
    id: string,
    userId: string,
  ): Promise<InvoiceRow & { invoice_items?: unknown }> {
    const { data, error } = (await this.db
      .from('invoices')
      .select(
        `
        id,
        invoice_number,
        status,
        currency,
        subtotal,
        discount,
        tax,
        total,
        issued_at,
        paid_at,
        pdf_url,
        payment_id,
        customer_snapshot,
        company_snapshot,
        invoice_items (*)
      `,
      )
      .eq('id', id)
      .eq('user_id', userId)
      .single()) as unknown as {
      data: InvoiceRow | null;
      error: { message: string } | null;
    };

    if (error || !data) {
      throw new NotFoundException('Invoice not found');
    }

    return data;
  }
}
