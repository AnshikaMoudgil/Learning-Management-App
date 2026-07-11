import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ActiveDevicesScreen extends StatelessWidget {
  const ActiveDevicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark), onPressed: () => Navigator.pop(context)),
        title: const Text('Active Devices', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Current Active Device', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              Text('This Device', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.laptop_mac, size: 40, color: AppColors.textDark),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Rahul\'s MacBook Air', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      SizedBox(height: 4),
                      Text('macOS 14.4', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                      SizedBox(height: 4),
                      Text('Last login: Today, 09:30 AM', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: AppColors.primaryBlue, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: const Text(
                    'You can access the platform on one device at a time. To use on a new device, request a device transfer.',
                    style: TextStyle(fontSize: 12, color: AppColors.textDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Request Device Transfer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          const SizedBox(height: 32),
          const Text('Transfer History', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 16),
          _buildHistoryItem(
            from: 'Redmi Note 12 Pro',
            to: 'Rahul\'s MacBook Air',
            date: '05 May 2025, 10:15 AM',
            status: 'Approved',
            isApproved: true,
          ),
          _buildHistoryItem(
            from: 'Windows Laptop',
            to: 'Redmi Note 12 Pro',
            date: '20 Apr 2025, 04:45 PM',
            status: 'Approved',
            isApproved: true,
          ),
          _buildHistoryItem(
            from: 'iPhone 13',
            to: 'Windows Laptop',
            date: '10 Apr 2025, 11:20 AM',
            status: 'Rejected',
            isApproved: false,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem({
    required String from,
    required String to,
    required String date,
    required String status,
    required bool isApproved,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.swap_horiz, color: AppColors.textLight),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('From: $from', style: const TextStyle(fontSize: 12, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text('To: $to', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text(date, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
              ],
            ),
          ),
          Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isApproved ? Colors.green : Colors.red)),
        ],
      ),
    );
  }
}
