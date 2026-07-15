import { Injectable } from '@nestjs/common';
import PDFDocument from 'pdfkit';

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

@Injectable()
export class PdfGeneratorService {
  async generateInvoicePdf(data: InvoiceData): Promise<Buffer> {
    return new Promise((resolve, reject) => {
      const doc = new PDFDocument({ size: 'A4', margin: 50 });
      const chunks: Buffer[] = [];

      doc.on('data', (chunk: Buffer) => chunks.push(chunk));
      doc.on('end', () => resolve(Buffer.concat(chunks)));
      doc.on('error', (err: Error) => reject(err));

      try {
        // --- Colors & Styling ---
        const primaryColor = '#1A365D'; // Dark Navy
        const secondaryColor = '#2B6CB0'; // Slate Blue
        const textColor = '#2D3748'; // Charcoal
        const lightGray = '#EDF2F7';
        const darkGray = '#4A5568';

        // --- Header Block (Branding & Title) ---
        doc
          .fillColor(primaryColor)
          .fontSize(22)
          .font('Helvetica-Bold')
          .text(data.companySnapshot.name.toUpperCase(), 50, 50);

        doc
          .fontSize(10)
          .font('Helvetica')
          .fillColor(darkGray)
          .text(data.companySnapshot.website || '', 50, 75)
          .text(data.companySnapshot.email, 50, 90);

        if (data.companySnapshot.phone) {
          doc.text(data.companySnapshot.phone, 50, 105);
        }
        if (data.companySnapshot.taxNumber) {
          doc.text(`Tax Reg: ${data.companySnapshot.taxNumber}`, 50, 120);
        }

        // --- Invoice Label ---
        doc
          .fillColor(primaryColor)
          .fontSize(28)
          .font('Helvetica-Bold')
          .text('INVOICE', 350, 50, { align: 'right', width: 200 });

        doc
          .fontSize(10)
          .font('Helvetica')
          .fillColor(textColor)
          .text(`Invoice No: ${data.invoiceNumber}`, 350, 85, {
            align: 'right',
            width: 200,
          })
          .text(
            `Date: ${new Date(data.issuedAt).toLocaleDateString()}`,
            350,
            100,
            { align: 'right', width: 200 },
          )
          .text(`Status: PAID`, 350, 115, { align: 'right', width: 200 });

        // Line separator
        doc
          .strokeColor(lightGray)
          .lineWidth(1)
          .moveTo(50, 150)
          .lineTo(545, 150)
          .stroke();

        // --- Bill To & Details Section ---
        doc
          .fillColor(secondaryColor)
          .fontSize(12)
          .font('Helvetica-Bold')
          .text('BILL TO', 50, 170);

        doc
          .fontSize(10)
          .font('Helvetica-Bold')
          .fillColor(textColor)
          .text(data.customerSnapshot.name, 50, 190)
          .font('Helvetica')
          .fillColor(darkGray)
          .text(data.customerSnapshot.email, 50, 205);

        if (data.customerSnapshot.phone) {
          doc.text(data.customerSnapshot.phone, 50, 220);
        }

        doc
          .fillColor(secondaryColor)
          .fontSize(12)
          .font('Helvetica-Bold')
          .text('PAYMENT INFORMATION', 300, 170);

        doc
          .fontSize(10)
          .font('Helvetica')
          .fillColor(darkGray)
          .text(
            `Payment Date: ${new Date(data.paidAt).toLocaleDateString()}`,
            300,
            190,
          )
          .text(`Method: Online Payment`, 300, 205)
          .text(`Currency: ${data.currency.toUpperCase()}`, 300, 220);

        // Line separator
        doc.strokeColor(lightGray).moveTo(50, 250).lineTo(545, 250).stroke();

        // --- Items Table ---
        let currentY = 275;

        // Table Header
        doc.rect(50, currentY, 495, 20).fill(lightGray);

        doc
          .fillColor(primaryColor)
          .font('Helvetica-Bold')
          .fontSize(9)
          .text('Item Description', 60, currentY + 6, { width: 220 })
          .text('Qty', 290, currentY + 6, { width: 30, align: 'center' })
          .text('Unit Price', 330, currentY + 6, { width: 60, align: 'right' })
          .text('Discount', 400, currentY + 6, { width: 60, align: 'right' })
          .text('Total', 475, currentY + 6, { width: 60, align: 'right' });

        currentY += 20;

        // Table Rows
        doc.font('Helvetica').fontSize(9).fillColor(textColor);
        data.items.forEach((item) => {
          doc
            .font('Helvetica-Bold')
            .text(item.title, 60, currentY + 8, { width: 220 });

          if (item.description) {
            doc
              .font('Helvetica-Oblique')
              .fillColor(darkGray)
              .text(item.description, 60, currentY + 20, { width: 220 });
          }

          doc
            .font('Helvetica')
            .fillColor(textColor)
            .text(item.quantity.toString(), 290, currentY + 8, {
              width: 30,
              align: 'center',
            })
            .text(item.unitPrice.toFixed(2), 330, currentY + 8, {
              width: 60,
              align: 'right',
            })
            .text(item.discount.toFixed(2), 400, currentY + 8, {
              width: 60,
              align: 'right',
            })
            .text(item.total.toFixed(2), 475, currentY + 8, {
              width: 60,
              align: 'right',
            });

          currentY += item.description ? 35 : 25;
        });

        // Line separator
        doc
          .strokeColor(lightGray)
          .moveTo(50, currentY + 10)
          .lineTo(545, currentY + 10)
          .stroke();

        currentY += 20;

        // --- Summary Totals ---
        const summaryX = 350;
        doc
          .fontSize(9)
          .fillColor(darkGray)
          .text('Subtotal:', summaryX, currentY, { width: 100, align: 'left' })
          .fillColor(textColor)
          .text(
            `${data.currency.toUpperCase()} ${data.subtotal.toFixed(2)}`,
            summaryX + 100,
            currentY,
            { width: 90, align: 'right' },
          );

        currentY += 15;

        if (data.discount > 0) {
          doc
            .fillColor(darkGray)
            .text('Discount:', summaryX, currentY, {
              width: 100,
              align: 'left',
            })
            .fillColor(textColor)
            .text(
              `- ${data.currency.toUpperCase()} ${data.discount.toFixed(2)}`,
              summaryX + 100,
              currentY,
              { width: 90, align: 'right' },
            );
          currentY += 15;
        }

        if (data.tax > 0) {
          doc
            .fillColor(darkGray)
            .text('Tax:', summaryX, currentY, { width: 100, align: 'left' })
            .fillColor(textColor)
            .text(
              `${data.currency.toUpperCase()} ${data.tax.toFixed(2)}`,
              summaryX + 100,
              currentY,
              { width: 90, align: 'right' },
            );
          currentY += 15;
        }

        // Grand Total Block
        doc.rect(summaryX, currentY, 195, 25).fill(primaryColor);

        doc
          .fillColor('#FFFFFF')
          .font('Helvetica-Bold')
          .fontSize(10)
          .text('Total Paid:', summaryX + 10, currentY + 8, {
            width: 80,
            align: 'left',
          })
          .text(
            `${data.currency.toUpperCase()} ${data.total.toFixed(2)}`,
            summaryX + 90,
            currentY + 8,
            { width: 95, align: 'right' },
          );

        // --- Footer Notes ---
        if (data.notes) {
          doc
            .fillColor(darkGray)
            .font('Helvetica-Oblique')
            .fontSize(8)
            .text('Notes:', 50, 700)
            .text(data.notes, 50, 712, { width: 495 });
        }

        doc
          .fillColor(darkGray)
          .font('Helvetica')
          .fontSize(8)
          .text(
            `Thank you for learning with ${data.companySnapshot.name}!`,
            50,
            750,
            { align: 'center', width: 495 },
          );

        doc.end();
      } catch (err) {
        reject(err instanceof Error ? err : new Error(String(err)));
      }
    });
  }
}
