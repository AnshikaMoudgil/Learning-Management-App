class InvoiceItem {
  final String id;
  final String invoiceId;
  final String itemType;
  final String itemId;
  final String title;
  final String? description;
  final int quantity;
  final double unitPrice;
  final double discount;
  final double tax;
  final double total;

  InvoiceItem({
    required this.id,
    required this.invoiceId,
    required this.itemType,
    required this.itemId,
    required this.title,
    this.description,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
    required this.tax,
    required this.total,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'] as String,
      invoiceId: json['invoice_id'] as String,
      itemType: json['item_type'] as String,
      itemId: json['item_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num).toDouble(),
    );
  }
}

class Invoice {
  final String id;
  final String invoiceNumber;
  final String status;
  final String currency;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final DateTime issuedAt;
  final DateTime paidAt;
  final String? pdfUrl;
  final String paymentId;
  final Map<String, dynamic> customerSnapshot;
  final Map<String, dynamic> companySnapshot;
  final List<InvoiceItem>? items;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.status,
    required this.currency,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.issuedAt,
    required this.paidAt,
    this.pdfUrl,
    required this.paymentId,
    required this.customerSnapshot,
    required this.companySnapshot,
    this.items,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] as String,
      invoiceNumber: json['invoice_number'] as String,
      status: json['status'] as String,
      currency: json['currency'] as String,
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num).toDouble(),
      issuedAt: DateTime.parse(json['issued_at'] as String),
      paidAt: DateTime.parse(json['paid_at'] as String),
      pdfUrl: json['pdf_url'] as String?,
      paymentId: json['payment_id'] as String,
      customerSnapshot: json['customer_snapshot'] as Map<String, dynamic>,
      companySnapshot: json['company_snapshot'] as Map<String, dynamic>,
      items: (json['invoice_items'] as List<dynamic>?)
          ?.map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
