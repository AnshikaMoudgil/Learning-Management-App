import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RenewCourseScreen extends StatefulWidget {
  const RenewCourseScreen({Key? key}) : super(key: key);

  @override
  State<RenewCourseScreen> createState() => _RenewCourseScreenState();
}

class _RenewCourseScreenState extends State<RenewCourseScreen> {
  int _selectedPlan = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Renew Course', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            Text('Extend your access and keep learning without interruption.', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
          ],
        ),
        actions: [
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.lightBlueBg, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.shopping_cart_outlined, color: AppColors.textDark, size: 18),
              ),
              Positioned(
                right: 0, top: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                  child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.lightBlueBg, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.notifications_outlined, color: AppColors.textDark, size: 18),
              ),
              Positioned(
                right: 0, top: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Course Info Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A237E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('React\nJS', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF61DAFB), fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('React JS - Complete Guide', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        const SizedBox(height: 2),
                        const Text('By Coding Academy', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                        const SizedBox(height: 6),
                        Row(
                          children: const [
                            Icon(Icons.calendar_today_outlined, size: 10, color: AppColors.textLight),
                            SizedBox(width: 4),
                            Text('Current valid till: 15 Jun 2024', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE53935)),
                    ),
                    child: Column(
                      children: const [
                        Text('Expires in', style: TextStyle(fontSize: 9, color: Color(0xFFE53935))),
                        Text('07', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFE53935))),
                        Text('Days', style: TextStyle(fontSize: 9, color: Color(0xFFE53935))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Select Renewal Plan
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Select Renewal Plan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Choose a plan to extend your course validity.', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
            ),
            const SizedBox(height: 16),

            // Plan Options
            _buildPlanOption(0, '3 Months', 'Most Popular', const Color(0xFFE8F5E9), const Color(0xFF43A047), '₹799', '₹266 / month', 'Extend access for 3 months.'),
            _buildPlanOption(1, '6 Months', 'Best Value', const Color(0xFFFFF3E0), const Color(0xFFE65100), '₹1,399', '₹233 / month', 'Extend access for 6 months.'),
            _buildPlanOption(2, '12 Months', null, null, null, '₹2,499', '₹208 / month', 'Extend access for 12 months.'),

            const SizedBox(height: 16),

            // Info Box
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightBlueBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, size: 16, color: AppColors.primaryBlue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Your progress, certificates, and access will be continued after renewal.', style: TextStyle(fontSize: 11, color: AppColors.textDark)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payment Summary
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Payment Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 16),
                  _buildSummaryRow('Course', 'React JS - Complete Guide'),
                  const Divider(height: 24, color: AppColors.border),
                  _buildSummaryRow('Plan', '3 Months'),
                  const Divider(height: 24, color: AppColors.border),
                  _buildSummaryRow('Subtotal', '₹799.00'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Discount (10% OFF)', style: TextStyle(fontSize: 13, color: Color(0xFF43A047))),
                      Text('- ₹79.90', style: TextStyle(fontSize: 13, color: Color(0xFF43A047))),
                    ],
                  ),
                  const Divider(height: 24, color: AppColors.border),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Total', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      Text('₹719.10', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Why Renew
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Why renew your course?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildReasonCard(Icons.menu_book, const Color(0xFFE3F2FD), const Color(0xFF1976D2), 'Continue Learning', 'Keep your access\nwithout interruption'),
                      const SizedBox(width: 10),
                      _buildReasonCard(Icons.trending_up, const Color(0xFFF3E5F5), const Color(0xFF7B1FA2), 'Track Progress', 'Your progress\nwill be saved'),
                      const SizedBox(width: 10),
                      _buildReasonCard(Icons.workspace_premium, const Color(0xFFFFEBEE), const Color(0xFFE53935), 'Get Certified', 'Stay on track to\nearn your certificate'),
                      const SizedBox(width: 10),
                      _buildReasonCard(Icons.update, const Color(0xFFE8F5E9), const Color(0xFF43A047), 'Access Updates', 'Get new content\nand improvements'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Exclusive Offer Banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FFF0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFC8E6C9)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFF43A047).withOpacity(0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.local_offer, color: Color(0xFF43A047), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Exclusive Offer!', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        SizedBox(height: 2),
                        Text('Renew now and get 10% OFF on your renewal.', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF43A047)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('10% OFF Applied', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF43A047))),
                        SizedBox(width: 4),
                        Icon(Icons.check_circle, size: 14, color: Color(0xFF43A047)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Proceed Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.lock_outline, color: Colors.white, size: 18),
                  label: const Text('Proceed to Payment', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Secure payment
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.verified_user_outlined, size: 14, color: AppColors.primaryBlue),
                SizedBox(width: 4),
                Text('Secure payment powered by Razorpay', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanOption(int index, String duration, String? badge, Color? badgeBg, Color? badgeText, String price, String perMonth, String subtitle) {
    final isSelected = _selectedPlan == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightBlueBg : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primaryBlue : AppColors.border, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: isSelected ? AppColors.primaryBlue : AppColors.textLight, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(duration, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(12)),
                          child: Text(badge, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: badgeText)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                Text(perMonth, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.textLight, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textLight)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
      ],
    );
  }

  Widget _buildReasonCard(IconData icon, Color bgColor, Color iconColor, String title, String subtitle) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 2),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 8, color: AppColors.textLight)),
        ],
      ),
    );
  }
}
