import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class MySubscriptionsScreen extends StatelessWidget {
  const MySubscriptionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark), onPressed: () => context.pop()),
        title: const Text('My Subscriptions', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Active Subscriptions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 16),
          _buildSubscriptionCard(
            title: 'React - The Complete Guide',
            dateText: 'Valid till\n15 Jun 2025',
            autoRenewal: true,
            icon: Icons.science,
            color: const Color(0xFF0D1B2A),
            isActive: true,
          ),
          _buildSubscriptionCard(
            title: 'Python for Data Science',
            dateText: 'Valid till\n28 Aug 2025',
            autoRenewal: false,
            icon: Icons.code,
            color: const Color(0xFF1B4332),
            isActive: true,
          ),
          const SizedBox(height: 32),
          const Text('Expired Subscriptions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 16),
          _buildSubscriptionCard(
            title: 'UI/UX Design Masterclass',
            dateText: 'Expired on 10 Mar 2025',
            autoRenewal: false,
            icon: Icons.design_services,
            color: const Color(0xFF3B1E54),
            isActive: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard({
    required String title,
    required String dateText,
    required bool autoRenewal,
    required IconData icon,
    required Color color,
    required bool isActive,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Icon(icon, color: Colors.white, size: 36)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark), maxLines: 2),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(dateText, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                    if (isActive)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (autoRenewal)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                              child: const Text('Auto-renewal ON', style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold)),
                            )
                          else if (!autoRenewal)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                              child: const Text('Auto-renewal OFF', style: TextStyle(color: Colors.orange, fontSize: 8, fontWeight: FontWeight.bold)),
                            ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              minimumSize: const Size(70, 32),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('Renew', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          )
                        ],
                      )
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
