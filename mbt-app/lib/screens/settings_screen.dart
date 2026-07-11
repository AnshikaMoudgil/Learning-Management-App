import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark), onPressed: () => Navigator.pop(context)),
        title: const Text('Settings', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart_outlined, color: AppColors.textDark),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                    child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 8), textAlign: TextAlign.center),
                  ),
                )
              ],
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: AppColors.textDark),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                    child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 8), textAlign: TextAlign.center),
                  ),
                )
              ],
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text('Manage your preferences and account settings', style: TextStyle(color: AppColors.textLight, fontSize: 14)),
            ),
            const SizedBox(height: 16),
            
            // Preferences section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildListTile(Icons.language, 'Language', 'Choose your preferred app language', const Color(0xFF8B5CF6), trailingText: 'English'),
                  _buildDivider(),
                  _buildListTile(Icons.notifications_none, 'Notifications', 'Manage notification preferences', const Color(0xFFF59E0B)),
                  _buildDivider(),
                  _buildListTile(Icons.link, 'Linked Accounts', 'Connect and manage third-party accounts', const Color(0xFF10B981)),
                  _buildDivider(),
                  _buildListTile(Icons.devices, 'Device', 'Manage your devices and sessions', const Color(0xFF3B82F6)),
                  _buildDivider(),
                  _buildListTile(Icons.shield_outlined, 'Privacy', 'Manage your privacy and data', const Color(0xFF8B5CF6)),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text('More', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            
            // More section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildListTile(Icons.credit_card, 'Payment Methods', 'Manage your saved payment methods', AppColors.textLight, isMuted: true),
                  _buildDivider(),
                  _buildListTile(Icons.help_outline, 'Help & Support', 'Get help and contact support', AppColors.primaryBlue, isMuted: true),
                  _buildDivider(),
                  _buildListTile(Icons.info_outline, 'About', 'App info, terms and policies', const Color(0xFFEC4899), isMuted: true),
                  _buildDivider(),
                  _buildListTile(Icons.logout, 'Logout', 'Sign out from your account', const Color(0xFFEF4444), isMuted: true, onTap: () async {
                     await Supabase.instance.client.auth.signOut();
                  }),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            const Center(child: Text('App Version 1.0.0', style: TextStyle(color: AppColors.textLight, fontSize: 12))),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textLight,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), activeIcon: Icon(Icons.menu_book), label: 'My Learning'),
          BottomNavigationBarItem(icon: Icon(Icons.video_camera_front_outlined), activeIcon: Icon(Icons.video_camera_front), label: 'Live Classes'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), activeIcon: Icon(Icons.shopping_bag), label: 'Store'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, String subtitle, Color iconColor, {String? trailingText, bool isMuted = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isMuted ? AppColors.background : iconColor.withOpacity(0.1),
                border: isMuted ? Border.all(color: AppColors.border) : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
                ],
              ),
            ),
            if (trailingText != null) ...[
              Text(trailingText, style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.arrow_forward_ios, color: AppColors.textLight, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: AppColors.border, indent: 64);
  }
}
