export interface PaymentRow {
  id: string;
  user_id: string;
  course_id: string | null;
  coupon_id: string | null;
  base_amount: number;
  discount_amount: number;
  amount_paid: number;
  currency: string;
  status: string;
  updated_at: string | null;
}

export interface ProfileRow {
  full_name: string | null;
}

export interface CourseRow {
  id: string;
  title: string;
  short_description: string | null;
}

export interface PaymentItemRow {
  course_id: string;
  base_amount: number;
  discount_amount: number;
  amount_paid: number;
}

export interface NewInvoiceRow {
  id: string;
  issued_at: string;
}

export interface ExistingInvoiceRow {
  id: string;
  invoice_number: string;
  pdf_url: string | null;
}

export interface InvoiceRow {
  id: string;
  invoice_number: string;
  status: string;
  currency: string;
  subtotal: number;
  discount: number;
  tax: number;
  total: number;
  issued_at: string;
  paid_at: string | null;
  pdf_url: string | null;
  payment_id: string;
  customer_snapshot: unknown;
  company_snapshot: unknown;
  invoice_items?: unknown;
}

export interface InvoiceItemRow {
  invoice_id: string;
  item_type: string;
  item_id: string;
  title: string;
  description: string | undefined;
  quantity: number;
  unit_price: number;
  discount: number;
  tax: number;
  total: number;
}

export interface CompanySnapshot {
  name: string;
  email: string;
  phone?: string;
  address?: string;
  website?: string;
  taxNumber?: string;
}

export interface CustomerSnapshot {
  name: string;
  email: string;
  phone?: string;
}

export interface InvoiceItemData {
  title: string;
  description?: string;
  quantity: number;
  unitPrice: number;
  discount: number;
  tax: number;
  total: number;
}

export interface InvoiceData {
  invoiceNumber: string;
  currency: string;
  subtotal: number;
  discount: number;
  tax: number;
  total: number;
  issuedAt: Date;
  paidAt: Date;
  companySnapshot: CompanySnapshot;
  customerSnapshot: CustomerSnapshot;
  notes?: string;
  items: InvoiceItemData[];
}
