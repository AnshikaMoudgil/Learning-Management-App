import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({Key? key}) : super(key: key);

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  int _hardwareQuantity = 1;
  int _reactQuantity = 1;
  int _pythonQuantity = 1;

  void _showPaymentBottomSheet(BuildContext context, String title, int itemCount, int totalAmount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1F2B), // Dark theme
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return _PaymentBottomSheet(title: title, itemCount: itemCount, totalAmount: totalAmount);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
            child: const Icon(Icons.chevron_left, color: AppColors.textDark),
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text('Shopping Cart', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
          _buildIconBadge(Icons.shopping_cart_outlined, '3', Colors.blue, () {}),
          const SizedBox(width: 16),
          _buildIconBadge(Icons.notifications_outlined, '3', Colors.red, () => context.push('/notifications')),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(left: 56, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text('Review your items and proceed to checkout', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Info Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.withValues(alpha: 0.1))),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.primaryBlue, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Two Separate Checkouts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textDark)),
                                SizedBox(height: 4),
                                Text('Hardware (skill courses) and Software (skill courses) are sold by different partners. Please checkout them separately.', style: TextStyle(fontSize: 11, color: AppColors.textLight, height: 1.4)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Hardware Section
                    _buildSectionHeader(Icons.devices, 'Hardware (Skill Course)', '1 Item'),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))]),
                      child: Column(
                        children: [
                          _buildCartItem(
                            image: 'assets/iphone_hardware.png',
                            title: 'Mobile Repair Mastery',
                            subtitle: 'Complete course on smartphone repairing from basic to advanced level.',
                            level: 'Beginner to Advanced',
                            price: 2499,
                            quantity: _hardwareQuantity,
                            onQuantityChanged: (val) => setState(() => _hardwareQuantity = val),
                          ),
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Hardware Subtotal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textDark)),
                                Text('₹${2499 * _hardwareQuantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _showPaymentBottomSheet(context, 'Hardware (Skill Course)', _hardwareQuantity, 2499 * _hardwareQuantity),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Padding(
                                      padding: EdgeInsets.only(left: 16),
                                      child: Row(
                                        children: [
                                          Icon(Icons.credit_card, color: AppColors.primaryBlue, size: 18),
                                          SizedBox(width: 8),
                                          Text('Checkout Hardware Items', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.chevron_right, color: AppColors.primaryBlue, size: 20)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Software Section
                    _buildSectionHeader(Icons.code, 'Software (Skill Course)', '2 Items'),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))]),
                      child: Column(
                        children: [
                          _buildCartItem(
                            image: 'assets/iphone_software.png',
                            title: 'React – The Complete Guide',
                            subtitle: 'Build modern web apps using React, Hooks, Context API and more.',
                            level: 'Beginner to Advanced',
                            price: 799,
                            quantity: _reactQuantity,
                            onQuantityChanged: (val) => setState(() => _reactQuantity = val),
                          ),
                          const Divider(height: 1),
                          _buildCartItem(
                            image: 'assets/android_hardware.png', // Placeholder
                            title: 'Python for Data Science',
                            subtitle: 'Learn Python, NumPy, Pandas, Matplotlib and build real-world projects.',
                            level: 'Beginner',
                            price: 699,
                            quantity: _pythonQuantity,
                            onQuantityChanged: (val) => setState(() => _pythonQuantity = val),
                          ),
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Software Subtotal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textDark)),
                                Text('₹${(799 * _reactQuantity) + (699 * _pythonQuantity)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _showPaymentBottomSheet(context, 'Software (Skill Course)', _reactQuantity + _pythonQuantity, (799 * _reactQuantity) + (699 * _pythonQuantity)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Padding(
                                      padding: EdgeInsets.only(left: 16),
                                      child: Row(
                                        children: [
                                          Icon(Icons.credit_card, color: Colors.white, size: 18),
                                          SizedBox(width: 8),
                                          Text('Checkout Software Items', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.chevron_right, color: Colors.white, size: 20)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
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
                      const Text('Total Items', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                      const SizedBox(height: 2),
                      Text('${_hardwareQuantity + _reactQuantity + _pythonQuantity} Items', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Grand Total', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                      const SizedBox(height: 2),
                      Text('₹${(2499 * _hardwareQuantity) + (799 * _reactQuantity) + (699 * _pythonQuantity)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBadge(IconData icon, String count, Color badgeColor, VoidCallback onTap) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(icon: Icon(icon, color: AppColors.textDark), onPressed: onTap),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: Text(count, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ),
        )
      ],
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, String itemsText) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
          child: Icon(icon, color: AppColors.primaryBlue, size: 16),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark))),
        Text(itemsText, style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(width: 4),
        const Icon(Icons.keyboard_arrow_up, color: AppColors.primaryBlue, size: 18),
      ],
    );
  }

  Widget _buildCartItem({
    required String image,
    required String title,
    required String subtitle,
    required String level,
    required int price,
    required int quantity,
    required Function(int) onQuantityChanged,
  }) {
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
              image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
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
                    Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark))),
                    const SizedBox(width: 8),
                    const Icon(Icons.delete_outline, color: Colors.grey, size: 18),
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textLight), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(level, style: const TextStyle(color: AppColors.primaryBlue, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: quantity > 1 ? () => onQuantityChanged(quantity - 1) : null,
                            child: const Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: Icon(Icons.remove, size: 14, color: AppColors.textDark)),
                          ),
                          Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          InkWell(
                            onTap: () => onQuantityChanged(quantity + 1),
                            child: const Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: Icon(Icons.add, size: 14, color: AppColors.textDark)),
                          ),
                        ],
                      ),
                    ),
                    Text('₹$price', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentBottomSheet extends StatefulWidget {
  final String title;
  final int itemCount;
  final int totalAmount;

  const _PaymentBottomSheet({Key? key, required this.title, required this.itemCount, required this.totalAmount}) : super(key: key);

  @override
  State<_PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<_PaymentBottomSheet> {
  int _selectedMethod = 0; // 0: UPI, 1: Card, 2: NetBanking, 3: Wallet

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Complete Your Payment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Text('Secure payment powered by ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('Razorpay', style: TextStyle(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text('${widget.itemCount} Item', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 14),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text('₹${widget.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Pay Using', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  _buildPaymentMethod(0, 'UPI / QR', 'Pay using any UPI app', Icons.qr_code, true),
                  const Divider(height: 1, color: Colors.white12),
                  _buildPaymentMethod(1, 'Card', 'Visa, Mastercard, Rupay & more', Icons.credit_card, false),
                  const Divider(height: 1, color: Colors.white12),
                  _buildPaymentMethod(2, 'Net Banking', 'All major banks supported', Icons.account_balance, false),
                  const Divider(height: 1, color: Colors.white12),
                  _buildPaymentMethod(3, 'Wallet', 'Pay using wallet balance', Icons.account_balance_wallet, false),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.verified_user_outlined, color: Colors.grey, size: 14),
              SizedBox(width: 8),
              Text('Your payment is secured with 256-bit SSL encryption', style: TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Amount', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('₹${widget.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Text('View Details', style: TextStyle(color: Colors.grey, fontSize: 10)),
                        Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 12),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close bottom sheet
                      context.push('/payment-success'); // Navigate to success
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text('Pay ₹${widget.totalAmount}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('Secured by ', style: TextStyle(color: Colors.grey, fontSize: 10)),
                Text('Razorpay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(int index, String title, String subtitle, IconData icon, bool showBadges) {
    final isSelected = _selectedMethod == index;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = index),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? AppColors.primaryBlue : Colors.grey, width: 2),
              ),
              child: isSelected ? Center(child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle))) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
            ),
            // Placeholder for badges (GPay, Paytm, etc)
            if (showBadges)
              Row(
                children: [
                  _buildDummyBadge(Colors.green, 'GPay'),
                  const SizedBox(width: 4),
                  _buildDummyBadge(Colors.blue, 'Paytm'),
                  const SizedBox(width: 4),
                  _buildDummyBadge(Colors.purple, 'PhonePe'),
                ],
              )
            else
              Icon(icon, color: Colors.grey, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDummyBadge(Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold)),
    );
  }
}
