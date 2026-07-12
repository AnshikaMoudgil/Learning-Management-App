import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Notification Center', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            Text('Stay updated with important alerts', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
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
      body: Column(
        children: [
          // Filter Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', true),
                  _buildFilterChip('Live Class', false, icon: Icons.videocam),
                  _buildFilterChip('Expiry', false, icon: Icons.access_time),
                  _buildFilterChip('Payment', false, icon: Icons.payment),
                  _buildFilterChip('Device', false, icon: Icons.devices),
                  _buildFilterChip('Announcements', false, icon: Icons.campaign),
                ],
              ),
            ),
          ),

          // Notifications List
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Today
                  const Text('Today', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  _buildNotification(
                    icon: Icons.videocam_outlined,
                    iconBg: const Color(0xFFFFEBEE),
                    iconColor: const Color(0xFFE53935),
                    title: 'Live Class Starting Soon',
                    badge: 'Live Class',
                    badgeBg: const Color(0xFFE3F2FD),
                    badgeColor: AppColors.primaryBlue,
                    description: '"React for Beginners" class will start in 15 minutes.',
                    meta: 'Today, 10:00 AM',
                    metaIcon: Icons.calendar_today_outlined,
                    time: '9:45 AM',
                    dotColor: const Color(0xFFE53935),
                  ),
                  _buildNotification(
                    icon: Icons.access_time,
                    iconBg: const Color(0xFFFFF3E0),
                    iconColor: const Color(0xFFFF9800),
                    title: 'Course Expiry Reminder',
                    badge: 'Expiry',
                    badgeBg: const Color(0xFFFFF3E0),
                    badgeColor: const Color(0xFFFF9800),
                    description: '"UI/UX Design Fundamentals" will expire in 3 days.',
                    meta: 'Expires on 5 Jun 2024',
                    metaIcon: Icons.calendar_today_outlined,
                    time: '9:10 AM',
                    dotColor: const Color(0xFFE53935),
                  ),
                  _buildNotification(
                    icon: Icons.check_circle_outline,
                    iconBg: const Color(0xFFE8F5E9),
                    iconColor: const Color(0xFF43A047),
                    title: 'Payment Successful',
                    badge: 'Payment',
                    badgeBg: const Color(0xFFE8F5E9),
                    badgeColor: const Color(0xFF43A047),
                    description: 'Your payment of ₹1,499 for "Mobile Repair Mastery"\nwas successful.',
                    meta: 'Order ID: #ORD-2024-1287',
                    metaIcon: Icons.receipt_outlined,
                    time: '8:30 AM',
                    dotColor: const Color(0xFF43A047),
                  ),
                  _buildNotification(
                    icon: Icons.devices_outlined,
                    iconBg: const Color(0xFFE3F2FD),
                    iconColor: AppColors.primaryBlue,
                    title: 'New Login Detected',
                    badge: 'Device',
                    badgeBg: const Color(0xFFE3F2FD),
                    badgeColor: AppColors.primaryBlue,
                    description: 'A new login was detected on Windows PC.',
                    meta: 'Panipat, Haryana, India',
                    metaIcon: Icons.location_on_outlined,
                    time: '7:55 AM',
                    dotColor: AppColors.primaryBlue,
                  ),
                  _buildNotification(
                    icon: Icons.campaign_outlined,
                    iconBg: const Color(0xFFF3E5F5),
                    iconColor: const Color(0xFF7B1FA2),
                    title: 'New Announcement',
                    badge: 'Announcements',
                    badgeBg: const Color(0xFFF3E5F5),
                    badgeColor: const Color(0xFF7B1FA2),
                    description: 'New course "Advanced Micro Soldering" is now\navailable. Enroll now!',
                    meta: null,
                    metaIcon: null,
                    time: '7:20 AM',
                    dotColor: AppColors.primaryBlue,
                  ),
                  const SizedBox(height: 24),

                  // Yesterday
                  const Text('Yesterday', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  _buildNotification(
                    icon: Icons.access_time,
                    iconBg: const Color(0xFFFFF3E0),
                    iconColor: const Color(0xFFFF9800),
                    title: 'Course Expired',
                    badge: 'Expiry',
                    badgeBg: const Color(0xFFFFF3E0),
                    badgeColor: const Color(0xFFFF9800),
                    description: '"Digital Marketing Basics" has expired.',
                    meta: 'Expired on 1 Jun 2024',
                    metaIcon: Icons.calendar_today_outlined,
                    time: 'Yesterday, 6:30 PM',
                    dotColor: const Color(0xFFFF9800),
                  ),
                  _buildNotification(
                    icon: Icons.devices_outlined,
                    iconBg: const Color(0xFFE3F2FD),
                    iconColor: AppColors.primaryBlue,
                    title: 'Device Logged Out',
                    badge: 'Device',
                    badgeBg: const Color(0xFFE3F2FD),
                    badgeColor: AppColors.primaryBlue,
                    description: 'You were logged out from Android Phone.',
                    meta: '2 Jun 2024, 4:15 PM',
                    metaIcon: null,
                    time: 'Yesterday, 4:15 PM',
                    dotColor: AppColors.primaryBlue,
                  ),
                  _buildNotification(
                    icon: Icons.payment_outlined,
                    iconBg: const Color(0xFFF3E5F5),
                    iconColor: const Color(0xFF7B1FA2),
                    title: 'Refund Processed',
                    badge: 'Payment',
                    badgeBg: const Color(0xFFE8F5E9),
                    badgeColor: const Color(0xFF43A047),
                    description: 'Your refund of ₹999 for "Drone Technology Basics"\nhas been processed.',
                    meta: 'Refund ID: #RFND-2024-0891',
                    metaIcon: Icons.receipt_outlined,
                    time: 'Yesterday, 2:40 PM',
                    dotColor: const Color(0xFF7B1FA2),
                  ),

                  const SizedBox(height: 16),

                  // Enable push
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlueBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: AppColors.primaryBlue),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text('Enable push notifications to never miss an important update.', style: TextStyle(fontSize: 11, color: AppColors.textDark)),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            minimumSize: Size.zero,
                            elevation: 0,
                          ),
                          child: const Text('Enable Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primaryBlue : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: isSelected ? Colors.white : AppColors.textLight),
              const SizedBox(width: 4),
            ],
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotification({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String badge,
    required Color badgeBg,
    required Color badgeColor,
    required String description,
    String? meta,
    IconData? metaIcon,
    required String time,
    required Color dotColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark), overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(4)),
                            child: Text(badge, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: badgeColor)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 11, color: AppColors.textLight, height: 1.3)),
                if (meta != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (metaIcon != null) ...[
                        Icon(metaIcon, size: 10, color: AppColors.textLight),
                        const SizedBox(width: 4),
                      ],
                      Text(meta, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time, style: const TextStyle(fontSize: 9, color: AppColors.textLight)),
              const SizedBox(height: 6),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
