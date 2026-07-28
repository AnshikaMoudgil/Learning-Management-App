import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
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

@Injectable()
export class InvoicesRepository {
  private readonly logger = new Logger(InvoicesRepository.name);

  constructor(private readonly supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async findLatestInvoiceNumber(prefix: string) {
    const { data } = await this.db
      .from('invoices')
      .select('invoice_number')
      .like('invoice_number', `${prefix}%`)
      .order('invoice_number', { ascending: false })
      .limit(1);

    return data?.[0] as { invoice_number: string } | undefined;
  }

  async findPaymentById(paymentId: string) {
    const { data: payment, error: paymentError } = (await this.db
      .from('payments')
      .select('status, user_id, course_id, base_amount, discount_amount, amount_paid, currency, updated_at')
      .eq('id', paymentId)
      .single()) as unknown as {
      data: PaymentRow | null;
      error: { message: string } | null;
    };

    if (paymentError || !payment) {
      this.logger.error(`Failed to find payment: ${paymentError?.message}`);
      throw new NotFoundException(`Payment not found: ${paymentId}`);
    }

    return payment;
  }

  async findInvoiceByPaymentId(paymentId: string) {
    const { data: existingInvoice } = (await this.db
      .from('invoices')
      .select('id, invoice_number, pdf_url')
      .eq('payment_id', paymentId)
      .single()) as unknown as {
      data: ExistingInvoiceRow | null;
    };

    return existingInvoice;
  }

  async findProfileById(userId: string) {
    const { data: profile } = (await this.db
      .from('profiles')
      .select('full_name')
      .eq('id', userId)
      .single()) as unknown as {
      data: ProfileRow | null;
    };

    return profile;
  }

  async findPaymentItemsByPaymentId(paymentId: string) {
    const { data: paymentItems } = (await this.db
      .from('payment_items')
      .select('course_id, base_amount, discount_amount, amount_paid')
      .eq('payment_id', paymentId)) as unknown as {
      data: PaymentItemRow[] | null;
    };

    return paymentItems;
  }

  async findCoursesByIds(courseIds: string[]) {
    const { data: courses } = (await this.db
      .from('courses')
      .select('id, title, short_description')
      .in('id', courseIds)) as unknown as {
      data: CourseRow[] | null;
    };

    return courses;
  }

  async findCourseById(courseId: string) {
    const { data: course } = (await this.db
      .from('courses')
      .select('title, short_description')
      .eq('id', courseId)
      .single()) as unknown as {
      data: { title: string; short_description: string | null } | null;
    };

    return course;
  }

  async insertInvoice(data: Record<string, unknown>) {
    const { data: newInvoice, error: invoiceError } = (await this.db
      .from('invoices')
      .insert(data as never)
      .select('id, issued_at')
      .single()) as unknown as {
      data: NewInvoiceRow | null;
      error: { message: string } | null;
    };

    if (invoiceError || !newInvoice) {
      this.logger.error(`Failed to create invoice: ${invoiceError?.message}`);
      throw new Error(`Failed to create invoice: ${invoiceError?.message}`);
    }

    return newInvoice;
  }

  async insertInvoiceItems(items: InvoiceItemRow[]) {
    const { error: itemError } = await this.db
      .from('invoice_items')
      .insert(items as never);

    if (itemError) {
      this.logger.error(`Failed to create invoice items: ${itemError.message}`);
      throw new Error(`Failed to create invoice items: ${itemError.message}`);
    }
  }

  async updateInvoicePdfUrl(invoiceId: string, pdfUrl: string) {
    const { error: updateError } = await this.db
      .from('invoices')
      .update({ pdf_url: pdfUrl } as never)
      .eq('id', invoiceId);

    if (updateError) {
      this.logger.error(
        `Failed to update invoice pdfUrl: ${updateError.message}`,
      );
      throw new Error(
        `Failed to update invoice pdfUrl: ${updateError.message}`,
      );
    }
  }

  async findInvoicesByUserId(userId: string) {
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

  async findInvoiceByIdAndUser(id: string, userId: string) {
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
