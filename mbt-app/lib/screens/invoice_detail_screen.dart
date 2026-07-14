import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/invoice_service.dart';
import '../models/invoice.dart';
import '../theme/app_colors.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final String invoiceId;

  const InvoiceDetailScreen({Key? key, required this.invoiceId}) : super(key: key);

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  final InvoiceService _invoiceService = InvoiceService();
  late Future<Invoice> _invoiceFuture;

  @override
  void initState() {
    super.initState();
    _invoiceFuture = _invoiceService.getInvoice(widget.invoiceId);
  }

  String _formatCurrency(String currency, double amount) {
    switch (currency.toUpperCase()) {
      case 'INR':
        return '₹${amount.toStringAsFixed(2)}';
      case 'USD':
        return '\$${amount.toStringAsFixed(2)}';
      case 'EUR':
        return '€${amount.toStringAsFixed(2)}';
      case 'EGP':
        return 'E£${amount.toStringAsFixed(2)}';
      default:
        return '${currency.toUpperCase()} ${amount.toStringAsFixed(2)}';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _downloadPdf(Invoice invoice) async {
    if (invoice.pdfUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF not yet available')),
      );
      return;
    }

    final url = _invoiceService.getPdfUrl(widget.invoiceId);
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open PDF')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Invoice Details',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Invoice>(
        future: _invoiceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load invoice',
                      style: TextStyle(color: AppColors.textLight, fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }

          final invoice = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(invoice),
                const SizedBox(height: 24),
                _buildCompanyInfo(invoice),
                const SizedBox(height: 24),
                _buildCustomerInfo(invoice),
                const SizedBox(height: 24),
                _buildItems(invoice),
                const SizedBox(height: 24),
                _buildTotals(invoice),
                const SizedBox(height: 32),
                _buildDownloadButton(invoice),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(Invoice invoice) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              invoice.invoiceNumber,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Issued: ${_formatDate(invoice.issuedAt)}',
              style: const TextStyle(fontSize: 12, color: AppColors.textLight),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: invoice.status == 'paid'
                ? Colors.green.withOpacity(0.1)
                : invoice.status == 'refunded'
                    ? Colors.red.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            invoice.status.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: invoice.status == 'paid'
                  ? Colors.green
                  : invoice.status == 'refunded'
                      ? Colors.red
                      : Colors.orange,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyInfo(Invoice invoice) {
    final company = invoice.companySnapshot;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightBlueBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (company['name'] as String? ?? '').toUpperCase(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          if (company['email'] != null)
            Text(company['email'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
          if (company['phone'] != null)
            Text(company['phone'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
          if (company['website'] != null)
            Text(company['website'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
          if (company['taxNumber'] != null)
            Text('Tax: ${company['taxNumber']}', style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo(Invoice invoice) {
    final customer = invoice.customerSnapshot;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BILL TO',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          customer['name'] as String? ?? '',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        if (customer['email'] != null)
          Text(customer['email'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
        if (customer['phone'] != null)
          Text(customer['phone'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
      ],
    );
  }

  Widget _buildItems(Invoice invoice) {
    final items = invoice.items ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.lightBlueBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'ITEMS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
                    if (item.description != null)
                      Text(
                        item.description!,
                        style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      'Qty: ${item.quantity} x ${_formatCurrency(invoice.currency, item.unitPrice)}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                    ),
                  ],
                ),
              ),
              Text(
                _formatCurrency(invoice.currency, item.total),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
            ],
          ),
        )),
        const Divider(),
      ],
    );
  }

  Widget _buildTotals(Invoice invoice) {
    return Column(
      children: [
        _buildTotalRow('Subtotal', _formatCurrency(invoice.currency, invoice.subtotal)),
        if (invoice.discount > 0)
          _buildTotalRow('Discount', '- ${_formatCurrency(invoice.currency, invoice.discount)}',
              color: Colors.red),
        if (invoice.tax > 0)
          _buildTotalRow('Tax', _formatCurrency(invoice.currency, invoice.tax)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Paid',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                _formatCurrency(invoice.currency, invoice.total),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color ?? AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(Invoice invoice) {
    final hasPdf = invoice.pdfUrl != null;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: hasPdf ? () => _downloadPdf(invoice) : null,
        icon: const Icon(Icons.download, color: Colors.white),
        label: Text(hasPdf ? 'Download PDF' : 'PDF Not Available'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
