import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'dashboard_layout.dart'; // Just to link back to home if needed

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color darkBg = Color(0xFF0F1116);
    const Color cardColor = Color(0xFF1A1D24);
    
    return Scaffold(
      backgroundColor: darkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF1EAD56),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 50),
              ),
              const SizedBox(height: 24),
              
              // Texts
              const Text('Payment Successful!', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Thank you for your purchase.\nYour order has been confirmed.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
              const SizedBox(height: 24),
              
              // Order ID Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF1EAD56).withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                      child: const Text('Order ID', style: TextStyle(color: Color(0xFF1EAD56), fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    const Text('ORD-2024-05-24-7843', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('May 24, 2024 • 09:41 AM', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Payment Summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Payment Summary', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildSummaryRow('Total Items', '3 Items'),
                    const SizedBox(height: 12),
                    _buildSummaryRow('Subtotal', '₹3,387'),
                    const SizedBox(height: 12),
                    _buildSummaryRow('Discount', '- ₹590', valueColor: const Color(0xFF1EAD56)),
                    const SizedBox(height: 12),
                    _buildSummaryRow('Tax (18% GST)', '₹610'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: Colors.white24),
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Paid', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('₹3,407', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Purchased Items
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: Colors.white24),
                    ),
                    const Text('Purchased Items', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildPurchasedItem('assets/iphone_hardware.png', 'Mobile Repair Mastery', 'Hardware (Skill Course)', 'Beginner to Advanced', '₹2,499'),
                    const SizedBox(height: 16),
                    _buildPurchasedItem('assets/iphone_software.png', 'React - The Complete Guide', 'Software (Skill Course)', 'Beginner to Advanced', '₹799'),
                    const SizedBox(height: 16),
                    _buildPurchasedItem('assets/android_hardware.png', 'Python for Data Science', 'Software (Skill Course)', 'Beginner', '₹699'),
                    
                    const SizedBox(height: 24),
                    // Invoice Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF232832),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.receipt_long, color: AppColors.primaryBlue, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Invoice sent to your email', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text('abhishek@example.com', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white24),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              children: [
                                Text('View Invoice', style: TextStyle(color: Colors.white, fontSize: 12)),
                                SizedBox(width: 4),
                                Icon(Icons.download, color: Colors.white, size: 14),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Buttons
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle_outline, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('Continue Learning', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const DashboardLayout()), (route) => false),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide.none,
                    backgroundColor: cardColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Go to My Learning', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),
              
              // Footer
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_outlined, color: Colors.white54, size: 14),
                  SizedBox(width: 4),
                  Text('Secured by', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  SizedBox(width: 4),
                  Text('Razorpay', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        Text(value, style: TextStyle(color: valueColor ?? Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPurchasedItem(String imagePath, String title, String subtitle, String level, String price) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                child: Text(level, style: const TextStyle(color: AppColors.primaryBlue, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        Text(price, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
