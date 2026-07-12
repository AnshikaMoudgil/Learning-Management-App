import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _liveClassReminders = true;
  bool _courseExpiryAlerts = true;
  bool _paymentConfirmations = true;
  bool _deviceTransferStatus = true;
  bool _promotionalMarketing = false;

  bool _pushNotifications = true;
  bool _email = true;
  bool _sms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark), onPressed: () => context.pop()),
        title: const Text('Notification Settings', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Notification Categories', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 16),
          _buildToggleItem(
            icon: Icons.sensors,
            title: 'Live class reminders',
            subtitle: 'Get reminders for upcoming live classes',
            value: _liveClassReminders,
            onChanged: (val) => setState(() => _liveClassReminders = val),
          ),
          _buildToggleItem(
            icon: Icons.calendar_today,
            title: 'Course expiry alerts',
            subtitle: 'Stay updated about subscription expiry',
            value: _courseExpiryAlerts,
            onChanged: (val) => setState(() => _courseExpiryAlerts = val),
          ),
          _buildToggleItem(
            icon: Icons.receipt_long,
            title: 'Payment confirmations',
            subtitle: 'Receipts and payment updates',
            value: _paymentConfirmations,
            onChanged: (val) => setState(() => _paymentConfirmations = val),
          ),
          _buildToggleItem(
            icon: Icons.devices,
            title: 'Device transfer status',
            subtitle: 'Updates about your transfer requests',
            value: _deviceTransferStatus,
            onChanged: (val) => setState(() => _deviceTransferStatus = val),
          ),
          _buildToggleItem(
            icon: Icons.campaign,
            title: 'Promotional & marketing',
            subtitle: 'Offers, new courses and promotions',
            value: _promotionalMarketing,
            onChanged: (val) => setState(() => _promotionalMarketing = val),
          ),
          const SizedBox(height: 32),
          const Text('Preferred Channels', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 4),
          const Text('Choose how you want to receive notifications', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
          const SizedBox(height: 16),
          _buildCheckboxItem(
            icon: Icons.notifications_active,
            title: 'Push Notifications',
            value: _pushNotifications,
            onChanged: (val) => setState(() => _pushNotifications = val ?? false),
          ),
          _buildCheckboxItem(
            icon: Icons.email,
            title: 'Email',
            value: _email,
            onChanged: (val) => setState(() => _email = val ?? false),
          ),
          _buildCheckboxItem(
            icon: Icons.message,
            title: 'SMS',
            value: _sms,
            onChanged: (val) => setState(() => _sms = val ?? false),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textLight, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryBlue,
          )
        ],
      ),
    );
  }

  Widget _buildCheckboxItem({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textLight, size: 20),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14, color: AppColors.textDark, fontWeight: FontWeight.w500))),
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryBlue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          )
        ],
      ),
    );
  }
}
