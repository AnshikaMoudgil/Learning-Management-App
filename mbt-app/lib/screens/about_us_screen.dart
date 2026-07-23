import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'terms_of_service_screen.dart';
import 'privacy_policy_screen.dart';
import 'package:go_router/go_router.dart';
// Note: Refund policy screen can be added later if needed

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

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
          'About Us',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.school, color: Colors.white, size: 28),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'MBT Platform',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Empowering learners. Everywhere.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'We are on a mission to make high-quality tech education accessible to everyone. Learn from industry experts and advance your career with in-demand skills.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textDark,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildSocialIcon(Icons.facebook),
              const SizedBox(width: 12),
              _buildSocialIcon(Icons.camera_alt), // Using camera for IG
              const SizedBox(width: 12),
              _buildSocialIcon(Icons.code), // placeholder
              const SizedBox(width: 12),
              _buildSocialIcon(Icons.link), // placeholder for linkedin
              const SizedBox(width: 12),
              _buildSocialIcon(Icons.play_arrow), // placeholder for youtube
            ],
          ),
          const SizedBox(height: 32),
          _buildLinkItem(
            'Terms of Service',
            onTap: () {
              context.push('/terms');
            },
          ),
          _buildLinkItem(
            'Privacy Policy',
            onTap: () {
              context.push('/privacy');
            },
          ),
          _buildLinkItem('Refund Policy', onTap: () {}),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Version',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
            trailing: const Text(
              'v2.3.1 (Build 45)',
              style: TextStyle(fontSize: 12, color: AppColors.textLight),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(child: Icon(icon, color: AppColors.primaryBlue, size: 20)),
    );
  }

  Widget _buildLinkItem(String title, {required VoidCallback onTap}) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textLight),
          onTap: onTap,
        ),
        const Divider(height: 1, color: AppColors.border),
      ],
    );
  }
}
