import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../services/coupon_service.dart';

enum CouponSortOption {
  discountHighToLow,
  discountLowToHigh,
  expirySoonest,
  codeAZ,
}

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  final CouponService _couponService = CouponService();
  final TextEditingController _searchController = TextEditingController();

  List<CouponItem> _coupons = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  CouponSortOption _sortOption = CouponSortOption.discountHighToLow;

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCoupons() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final coupons = await _couponService.getActiveCoupons();
      if (!mounted) return;
      setState(() {
        _coupons = coupons;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _copyCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Coupon code "$code" copied'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatExpiry(DateTime? expiresAt) {
    if (expiresAt == null) return 'No expiry';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return 'Valid till ${expiresAt.day} ${months[expiresAt.month - 1]} ${expiresAt.year}';
  }

  String _sortLabel(CouponSortOption option) {
    switch (option) {
      case CouponSortOption.discountHighToLow:
        return 'Discount: High to Low';
      case CouponSortOption.discountLowToHigh:
        return 'Discount: Low to High';
      case CouponSortOption.expirySoonest:
        return 'Expiry: Soonest';
      case CouponSortOption.codeAZ:
        return 'Code: A to Z';
    }
  }

  List<CouponItem> get _filteredAndSortedCoupons {
    var result = _coupons.where((c) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return c.code.toLowerCase().contains(q) ||
          c.discountText.toLowerCase().contains(q);
    }).toList();

    double discountValue(CouponItem c) {
      return (c.discountValue is num)
          ? (c.discountValue as num).toDouble()
          : double.tryParse(c.discountValue.toString()) ?? 0;
    }

    switch (_sortOption) {
      case CouponSortOption.discountHighToLow:
        result.sort((a, b) => discountValue(b).compareTo(discountValue(a)));
      case CouponSortOption.discountLowToHigh:
        result.sort((a, b) => discountValue(a).compareTo(discountValue(b)));
      case CouponSortOption.expirySoonest:
        result.sort((a, b) {
          final aDate = a.expiresAt;
          final bDate = b.expiresAt;
          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return aDate.compareTo(bDate);
        });
      case CouponSortOption.codeAZ:
        result.sort((a, b) => a.code.compareTo(b.code));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Icon(Icons.chevron_left, color: AppColors.textDark),
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Coupons',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textDark),
            onPressed: _loadCoupons,
          ),
          IconButton(
            icon: const Icon(
              Icons.shopping_cart_outlined,
              color: AppColors.textDark,
            ),
            onPressed: () => context.push('/cart'),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(left: 56, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _coupons.isNotEmpty
                    ? '${_coupons.length} coupon(s) available'
                    : 'No coupons available',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Failed to load coupons: $_errorMessage',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadCoupons,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _coupons.isEmpty
                    ? _buildEmptyState()
                    : Column(
                        children: [
                          _buildSearchAndSortBar(),
                          Expanded(child: _buildCouponsList()),
                        ],
                      ),
      ),
    );
  }

  Widget _buildSearchAndSortBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textDark,
                ),
                decoration: const InputDecoration(
                  hintText: 'Search coupons...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          PopupMenuButton<CouponSortOption>(
            onSelected: (option) {
              setState(() {
                _sortOption = option;
              });
            },
            itemBuilder: (context) => [
              for (final option in CouponSortOption.values)
                PopupMenuItem<CouponSortOption>(
                  value: option,
                  child: Row(
                    children: [
                      Icon(
                        _sortOption == option
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 16,
                        color: _sortOption == option
                            ? AppColors.primaryBlue
                            : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(_sortLabel(option)),
                    ],
                  ),
                ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sort, color: AppColors.textDark, size: 18),
                  SizedBox(width: 4),
                  Text(
                    'Sort',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.confirmation_number_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'No coupons available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check back later for new offers',
            style: TextStyle(fontSize: 13, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponsList() {
    final coupons = _filteredAndSortedCoupons;
    if (coupons.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            const Text(
              'No coupons found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Try a different search term',
              style: TextStyle(fontSize: 13, color: AppColors.textLight),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadCoupons,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: coupons.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _buildCouponCard(coupons[index]);
        },
      ),
    );
  }

  Widget _buildCouponCard(CouponItem coupon) {
    final isPercentage = coupon.discountType == 'percentage';
    final accentColor = isPercentage ? AppColors.primaryBlue : Colors.green;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left discount section
              Container(
                width: 110,
                color: accentColor,
                child: Stack(
                  children: [
                    // Top notch
                    Positioned(
                      top: 0,
                      right: 0,
                      child: _buildNotch(isTop: true),
                    ),
                    // Bottom notch
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: _buildNotch(isTop: false),
                    ),
                    // Content
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_offer,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isPercentage
                                ? '${coupon.discountValue}%'
                                : '₹${coupon.discountValue}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'OFF',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Dashed separator
              Container(
                width: 1,
                margin: const EdgeInsets.symmetric(vertical: 14),
                child: CustomPaint(
                  painter: _DashedLinePainter(color: Colors.grey.shade300),
                ),
              ),
              // Right content section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        coupon.discountText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Coupon code box
                      GestureDetector(
                        onTap: () => _copyCode(coupon.code),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  coupon.code,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: accentColor,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.copy,
                                size: 14,
                                color: accentColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _formatExpiry(coupon.expiresAt),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a circular notch (semi-circle) that creates the ticket tear effect.
  Widget _buildNotch({required bool isTop}) {
    return Transform.translate(
      offset: Offset(0, isTop ? -6 : 6),
      child: Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          color: Color(0xFFF5F6FA),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    const dashHeight = 4.0;
    const dashSpace = 4.0;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}