import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import 'edit_profile_screen.dart';
import 'notification_center_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';
import 'course_validity_screen.dart';
import 'package:go_router/go_router.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('More', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                          SizedBox(height: 4),
                          Text('Manage your account and app settings', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.push('/cart'),
                          child: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.lightBlueBg,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.shopping_cart_outlined, color: AppColors.textDark, size: 20),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                                  child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => context.push('/notifications'),
                          child: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.lightBlueBg,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.notifications_outlined, color: AppColors.textDark, size: 20),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                  child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Profile Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: StreamBuilder<AuthState>(
                    stream: Supabase.instance.client.auth.onAuthStateChange,
                    builder: (context, snapshot) {
                      final user = snapshot.data?.session?.user;
                      final avatarUrl = user?.userMetadata?['custom_avatar_url'] ?? user?.userMetadata?['avatar_url'];

                      return InkWell(
                        onTap: () {
                          context.push('/edit-profile');
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: const Color(0xFF0038FF),
                                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                                child: avatarUrl == null ? const Icon(Icons.person, color: Colors.white, size: 28) : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user?.userMetadata?['custom_full_name'] ?? user?.userMetadata?['full_name'] ?? 'Learner',
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      user?.phone ?? user?.email ?? 'Update Profile',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F0FF),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(Icons.workspace_premium, size: 12, color: Color(0xFF6C3FE8)),
                                          SizedBox(width: 4),
                                          Text('Premium Learner', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6C3FE8))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: AppColors.textLight),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),

              // Account Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Account', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textLight)),
              ),
              const SizedBox(height: 8),
              _buildMenuItem(context, Icons.person_outline, 'Edit Profile', onTap: () {
                context.push('/edit-profile');
              }),
              _buildMenuItem(context, Icons.credit_card_outlined, 'My Subscriptions', onTap: () {
                context.push('/subscriptions');
              }),
              _buildMenuItem(context, Icons.workspace_premium_outlined, 'Certificates', onTap: () {
                context.push('/certificates');
              }),
              _buildMenuItem(context, Icons.devices_outlined, 'Active Devices', onTap: () {
                context.push('/active-devices');
              }),
              _buildMenuItem(context, Icons.notifications_outlined, 'Notification Settings', onTap: () {
                context.push('/notification-settings');
              }),
              const SizedBox(height: 24),

              // Support Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Support & Information', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textLight)),
              ),
              const SizedBox(height: 8),
              _buildMenuItem(context, Icons.help_outline, 'Help Center', subtitle: 'Find answers to common questions'),
              _buildMenuItem(context, Icons.headset_mic_outlined, 'Support', subtitle: 'Get help from our support team'),
              _buildMenuItem(context, Icons.shield_outlined, 'Privacy Policy', subtitle: 'Learn how we protect your data', onTap: () {
                context.push('/privacy');
              }),
              _buildMenuItem(context, Icons.description_outlined, 'Terms of Service', subtitle: 'Read our terms and conditions', onTap: () {
                context.push('/terms');
              }),
              _buildMenuItem(context, Icons.info_outline, 'About Us', subtitle: 'More about our platform'),
              const SizedBox(height: 16),

              // Logout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InkWell(
                  onTap: () async {
                    await Supabase.instance.client.auth.signOut();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.logout, color: Colors.red, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Logout', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red)),
                              Text('Sign out from your account', style: TextStyle(fontSize: 11, color: Colors.red)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.red),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // App Version
              const Center(
                child: Text('App Version 1.0.0', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, {String? subtitle, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textDark, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textLight, size: 20),
          ],
        ),
      ),
    );
  }
}
