import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../models/payment.dart';
import '../services/cart_service.dart';
import '../services/cart_provider.dart';
import '../services/payment_service.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({Key? key}) : super(key: key);

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  final _cartService = CartService();
  final _paymentService = PaymentService();
  CartResponse? _cart;
  bool _isLoading = true;
  String? _errorMessage;

  final _hardwareCouponController = TextEditingController();
  final _softwareCouponController = TextEditingController();
  bool _showHardwareCoupon = false;
  bool _showSoftwareCoupon = false;
  bool _isValidatingHardwareCoupon = false;
  bool _isValidatingSoftwareCoupon = false;
  String? _hardwareCouponError;
  String? _softwareCouponError;
  String? _hardwareCouponSuccess;
  String? _softwareCouponSuccess;
  CouponValidation? _hardwareCouponValidation;
  CouponValidation? _softwareCouponValidation;
  bool _isPayingHardware = false;
  bool _isPayingSoftware = false;
  String? _hardwarePaymentError;
  String? _softwarePaymentError;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  @override
  void dispose() {
    _hardwareCouponController.dispose();
    _softwareCouponController.dispose();
    super.dispose();
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final cart = await _cartService.getCart();
      if (!mounted) return;
      setState(() {
        _cart = cart;
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

  Future<void> _removeItem(String courseId) async {
    try {
      await CartProvider().removeItem(courseId);
      await _loadCart();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to remove item: $e')));
    }
  }

  Future<void> _applyCoupon({
    required List<CartItem> items,
    required bool isHardware,
  }) async {
    final controller =
        isHardware ? _hardwareCouponController : _softwareCouponController;
    final code = controller.text.trim();
    if (code.isEmpty) return;

    setState(() {
      if (isHardware) {
        _isValidatingHardwareCoupon = true;
        _hardwareCouponError = null;
        _hardwareCouponSuccess = null;
        _hardwareCouponValidation = null;
      } else {
        _isValidatingSoftwareCoupon = true;
        _softwareCouponError = null;
        _softwareCouponSuccess = null;
        _softwareCouponValidation = null;
      }
    });

    try {
      final validation = items.length == 1
          ? await _paymentService.validateCoupon(
              code: code,
              courseId: items.first.courseId,
            )
          : await _paymentService.validateCartCoupon(
              code: code,
              courseIds: items.map((i) => i.courseId).toList(),
            );

      setState(() {
        if (isHardware) {
          _isValidatingHardwareCoupon = false;
          if (validation.valid) {
            _hardwareCouponValidation = validation;
            _hardwareCouponSuccess =
                'Coupon applied! Saved ₹${validation.discountAmount.toInt()}';
          } else {
            _hardwareCouponError =
                validation.reason ?? 'Invalid coupon code';
          }
        } else {
          _isValidatingSoftwareCoupon = false;
          if (validation.valid) {
            _softwareCouponValidation = validation;
            _softwareCouponSuccess =
                'Coupon applied! Saved ₹${validation.discountAmount.toInt()}';
          } else {
            _softwareCouponError =
                validation.reason ?? 'Invalid coupon code';
          }
        }
      });
    } catch (e) {
      setState(() {
        final msg = e.toString().replaceAll(RegExp(r'^\[\d+\]\s*'), '');
        if (isHardware) {
          _isValidatingHardwareCoupon = false;
          _hardwareCouponError = msg;
        } else {
          _isValidatingSoftwareCoupon = false;
          _softwareCouponError = msg;
        }
      });
    }
  }

  Future<void> _pay({
    required List<CartItem> items,
    required String category,
    required bool isHardware,
    required String? couponCode,
  }) async {
    setState(() {
      if (isHardware) {
        _isPayingHardware = true;
        _hardwarePaymentError = null;
      } else {
        _isPayingSoftware = true;
        _softwarePaymentError = null;
      }
    });

    try {
      final result = await _paymentService.checkoutCourses(
        courseIds: items.map((i) => i.courseId).toList(),
        checkoutTitle: '$category Courses (${items.length} items)',
        couponCode: couponCode,
      );
      if (!mounted) return;
      context.push(
        '/payment-success?courseTitle=${Uri.encodeComponent('$category Courses')}&orderId=${Uri.encodeComponent(result.order.orderId)}',
      );
    } on PaymentPendingException catch (error) {
      if (!mounted) return;
      context.push(
        '/payment-success?status=pending&courseTitle=${Uri.encodeComponent('$category Courses')}&orderId=${Uri.encodeComponent(error.order.orderId)}',
      );
    } catch (error) {
      setState(() {
        final msg = error.toString().replaceAll('Exception:', '').trim();
        if (isHardware) {
          _isPayingHardware = false;
          _hardwarePaymentError = msg;
        } else {
          _isPayingSoftware = false;
          _softwarePaymentError = msg;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hardwareItems = _cart?.hardware ?? [];
    final softwareItems = _cart?.software ?? [];
    final totalItemsCount = hardwareItems.length + softwareItems.length;
    final grandTotal = [
      ...hardwareItems,
      ...softwareItems,
    ].fold<double>(0, (sum, item) => sum + item.effectivePrice);

    return Scaffold(
      backgroundColor: Colors.white,
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
          'Shopping Cart',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textDark),
            onPressed: _loadCart,
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
                totalItemsCount > 0
                    ? '$totalItemsCount item(s) in your cart'
                    : 'Your cart is empty',
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
                        'Failed to load cart: $_errorMessage',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadCart,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            : totalItemsCount == 0
            ? _buildEmptyCart()
            : _buildCartContent(
                hardwareItems,
                softwareItems,
                grandTotal,
                totalItemsCount,
              ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Browse courses and add them to your cart',
            style: TextStyle(fontSize: 13, color: AppColors.textLight),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/store'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Browse Courses',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(
    List<CartItem> hardwareItems,
    List<CartItem> softwareItems,
    double grandTotal,
    int totalItemsCount,
  ) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Info Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Two Separate Checkouts',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: AppColors.textDark,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Hardware and Software courses are sold by different partners. Please checkout them separately.',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textLight,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Hardware Section
                if (hardwareItems.isNotEmpty) ...[
                  _buildSectionHeader(
                    Icons.devices,
                    'Hardware (Skill Course)',
                    '${hardwareItems.length} Item(s)',
                  ),
                  const SizedBox(height: 12),
                  _buildItemsCard(
                    items: hardwareItems,
                    category: 'Hardware',
                    isHardware: true,
                  ),
                  const SizedBox(height: 32),
                ],

                // Software Section
                if (softwareItems.isNotEmpty) ...[
                  _buildSectionHeader(
                    Icons.code,
                    'Software (Skill Course)',
                    '${softwareItems.length} Item(s)',
                  ),
                  const SizedBox(height: 12),
                  _buildItemsCard(
                    items: softwareItems,
                    category: 'Software',
                    isHardware: false,
                  ),
                  const SizedBox(height: 32),
                ],
              ],
            ),
          ),
        ),
        // Bottom Sticky Bar
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Items',
                    style: TextStyle(fontSize: 10, color: AppColors.textLight),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$totalItemsCount Items',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Grand Total',
                    style: TextStyle(fontSize: 10, color: AppColors.textLight),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${grandTotal.toInt()}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemsCard({
    required List<CartItem> items,
    required String category,
    required bool isHardware,
  }) {
    final subtotal = items.fold<double>(
      0,
      (sum, item) => sum + item.effectivePrice,
    );
    final showCoupon =
        isHardware ? _showHardwareCoupon : _showSoftwareCoupon;
    final couponController =
        isHardware ? _hardwareCouponController : _softwareCouponController;
    final isValidating =
        isHardware ? _isValidatingHardwareCoupon : _isValidatingSoftwareCoupon;
    final couponError =
        isHardware ? _hardwareCouponError : _softwareCouponError;
    final couponSuccess =
        isHardware ? _hardwareCouponSuccess : _softwareCouponSuccess;
    final couponValidation =
        isHardware ? _hardwareCouponValidation : _softwareCouponValidation;
    final discount = couponValidation != null
        ? subtotal - couponValidation.finalPrice
        : 0.0;
    final isPaying = isHardware ? _isPayingHardware : _isPayingSoftware;
    final paymentError =
        isHardware ? _hardwarePaymentError : _softwarePaymentError;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ...items.map((item) => _buildCartItem(item: item)),
          const Divider(height: 1),
          // Apply Coupon section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: showCoupon
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: couponController,
                              textCapitalization:
                                  TextCapitalization.characters,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textDark,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter Coupon Code',
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                                filled: true,
                                fillColor:
                                    Colors.grey.withValues(alpha: 0.05),
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed:
                                isValidating ? null : () => _applyCoupon(
                                      items: items,
                                      isHardware: isHardware,
                                    ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: isValidating
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Apply',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                      if (couponError != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          couponError,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      if (couponSuccess != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          couponSuccess,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  )
                : GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isHardware) {
                          _showHardwareCoupon = true;
                        } else {
                          _showSoftwareCoupon = true;
                        }
                      });
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.discount_outlined,
                          color: AppColors.primaryBlue,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Apply Coupon',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Subtotal',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      '₹${subtotal.toInt()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                if (discount > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Discount',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        '-₹${discount.toInt()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Divider(height: 1),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        '₹${(subtotal - discount).toInt()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (paymentError != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                paymentError,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isPaying
                    ? null
                    : () => _pay(
                          items: items,
                          category: category,
                          isHardware: isHardware,
                          couponCode: couponValidation?.code,
                        ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isHardware
                      ? Colors.blue.withValues(alpha: 0.1)
                      : AppColors.primaryBlue,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isPaying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.credit_card,
                                  color: isHardware
                                      ? AppColors.primaryBlue
                                      : Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Pay ₹${(subtotal - discount).toInt()}',
                                  style: TextStyle(
                                    color: isHardware
                                        ? AppColors.primaryBlue
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Icon(
                              Icons.chevron_right,
                              color: isHardware
                                  ? AppColors.primaryBlue
                                  : Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, String itemsText) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.textDark,
            ),
          ),
        ),
        Text(
          itemsText,
          style: const TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(
          Icons.keyboard_arrow_up,
          color: AppColors.primaryBlue,
          size: 18,
        ),
      ],
    );
  }

  Widget _buildCartItem({required CartItem item}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: item.thumbnailUrl == null
                    ? const AssetImage('assets/iphone_software.png')
                    : NetworkImage(item.thumbnailUrl!) as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
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
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _removeItem(item.courseId),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.grey,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.shortDescription ?? '',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Text(
                  '₹${item.effectivePrice.toInt()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
