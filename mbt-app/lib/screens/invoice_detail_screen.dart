import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/invoice_service.dart';
import '../models/invoice.dart';
import '../theme/app_colors.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final String invoiceId;

  const InvoiceDetailScreen({Key? key, required this.invoiceId})
    : super(key: key);

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
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _downloadPdf(Invoice invoice) async {
    try {
      final result = await _invoiceService.getPdfUrl(widget.invoiceId);
      final uri = Uri.parse(result);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Could not open PDF')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
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
        actions: [
          IconButton(
            icon: const Icon(
              Icons.download_outlined,
              color: AppColors.primaryBlue,
            ),
            onPressed: () {},
          ),
        ],
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
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load invoice',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final invoice = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(invoice),
                const SizedBox(height: 16),
                _buildCompanyCard(invoice),
                const SizedBox(height: 16),
                _buildBillToCard(invoice),
                const SizedBox(height: 16),
                _buildItemsSection(invoice),
                const SizedBox(height: 16),
                _buildTotalsSection(invoice),
                const SizedBox(height: 16),
                _buildTotalPaidBar(invoice),
                const SizedBox(height: 12),
                _buildDownloadButton(invoice),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Header Card ──────────────────────────────────────────────────────────────
  Widget _buildHeaderCard(Invoice invoice) {
    final isPaid = invoice.status == 'paid';
    final isRefunded = invoice.status == 'refunded';

    final statusColor = isPaid
        ? const Color(0xFF22C55E)
        : isRefunded
        ? Colors.red
        : Colors.orange;

    final statusBg = isPaid
        ? const Color(0xFFDCFCE7)
        : isRefunded
        ? Colors.red.withOpacity(0.1)
        : Colors.orange.withOpacity(0.1);

    final statusIcon = isPaid
        ? Icons.check_circle_outline
        : isRefunded
        ? Icons.cancel_outlined
        : Icons.hourglass_empty;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Invoice icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.lightBlueBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.primaryBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'INVOICE ID',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textLight,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      invoice.invoiceNumber,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      invoice.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: AppColors.textLight,
              ),
              const SizedBox(width: 6),
              Text(
                'Issued: ${_formatDate(invoice.issuedAt)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Company Card ─────────────────────────────────────────────────────────────
  Widget _buildCompanyCard(Invoice invoice) {
    final company = invoice.companySnapshot;
    final name = (company['name'] as String? ?? '').toUpperCase();
    final email = company['email'] as String?;
    final phone = company['phone'] as String?;
    final website = company['website'] as String?;
    final taxNumber = company['taxNumber'] as String?;

    return _card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company logo circle
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.business_center_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                if (email != null) _infoRow(Icons.email_outlined, email),
                if (phone != null) _infoRow(Icons.phone_outlined, phone),
                if (website != null) _infoRow(Icons.language_outlined, website),
                if (taxNumber != null)
                  _infoRow(Icons.receipt_outlined, 'Tax: $taxNumber'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 13, color: AppColors.textLight),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: AppColors.textLight),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bill To Card ─────────────────────────────────────────────────────────────
  Widget _buildBillToCard(Invoice invoice) {
    final customer = invoice.customerSnapshot;
    final name = customer['name'] as String? ?? '';
    final email = customer['email'] as String?;

    return _card(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.lightBlueBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.person_outline,
              color: AppColors.primaryBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BILL TO',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                if (email != null)
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Items Section ─────────────────────────────────────────────────────────────
  Widget _buildItemsSection(Invoice invoice) {
    final items = invoice.items ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.lightBlueBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  color: AppColors.primaryBlue,
                  size: 17,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'ITEMS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Item list
          ...List.generate(items.length, (index) {
            final item = items[index];
            final isLast = index == items.length - 1;
            return Column(
              children: [
                _buildItemTile(invoice, item),
                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: _dashedDivider(),
                  )
                else
                  const SizedBox(height: 4),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildItemTile(Invoice invoice, InvoiceItem item) {
    // Pick an icon color based on type
    final isDigital =
        item.itemType.toLowerCase().contains('course') ||
        item.itemType.toLowerCase().contains('class');
    final iconBg = isDigital
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFF3F6FF);
    final iconColor = isDigital
        ? const Color(0xFF16A34A)
        : AppColors.primaryBlue;
    final iconData = isDigital
        ? Icons.phone_android_outlined
        : Icons.build_outlined;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Item icon
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(iconData, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        // Item info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatCurrency(invoice.currency, item.total),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              if (item.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  item.description!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Text(
                'Qty: ${item.quantity} × ${_formatCurrency(invoice.currency, item.unitPrice)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dashedDivider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashWidth = 6.0;
        final dashSpace = 4.0;
        final totalWidth = constraints.maxWidth;
        final count = (totalWidth / (dashWidth + dashSpace)).floor();
        return Row(
          children: List.generate(count, (_) {
            return Row(
              children: [
                Container(width: dashWidth, height: 1, color: AppColors.border),
                SizedBox(width: dashSpace),
              ],
            );
          }),
        );
      },
    );
  }

  // ── Totals Section ────────────────────────────────────────────────────────────
  Widget _buildTotalsSection(Invoice invoice) {
    return _card(
      child: Column(
        children: [
          _buildTotalRow(
            'Subtotal',
            _formatCurrency(invoice.currency, invoice.subtotal),
          ),
          if (invoice.discount > 0) ...[
            const SizedBox(height: 8),
            _buildTotalRow(
              'Discount',
              '- ${_formatCurrency(invoice.currency, invoice.discount)}',
              valueColor: Colors.red,
            ),
          ],
          if (invoice.tax > 0) ...[
            const SizedBox(height: 8),
            _buildTotalRow(
              'Tax',
              _formatCurrency(invoice.currency, invoice.tax),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          _buildTotalRow(
            'Total Paid',
            _formatCurrency(invoice.currency, invoice.total),
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
            valueStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    String value, {
    Color? valueColor,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              labelStyle ??
              const TextStyle(fontSize: 13, color: AppColors.textLight),
        ),
        Text(
          value,
          style:
              valueStyle ??
              TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textDark,
              ),
        ),
      ],
    );
  }

  // ── Total Paid Bar ────────────────────────────────────────────────────────────
  Widget _buildTotalPaidBar(Invoice invoice) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sync_alt_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Total Paid',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Text(
            _formatCurrency(invoice.currency, invoice.total),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ── Download Button ───────────────────────────────────────────────────────────
  Widget _buildDownloadButton(Invoice invoice) {
    final hasPdf = invoice.pdfUrl != null;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: hasPdf ? () => _downloadPdf(invoice) : null,
        icon: const Icon(Icons.download_outlined),
        label: Text(hasPdf ? 'Download PDF' : 'PDF Not Available'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
