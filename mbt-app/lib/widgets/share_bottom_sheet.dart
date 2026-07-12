import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class ShareUtils {
  static void showShareBottomSheet(BuildContext context, {String courseName = 'Mobile IC Repair Complete Course', String url = 'https://app.skilltech.com/courses/mobile-ic-repair'}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                const Text('Share this course', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Icon(Icons.close, color: AppColors.textDark, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Share "$courseName" with your friends and help them learn.',
              style: const TextStyle(fontSize: 12, color: AppColors.textLight),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShareIcon(Icons.chat, Colors.green, 'WhatsApp', () {}),
                _buildShareIcon(Icons.telegram, Colors.blue, 'Telegram', () {}),
                _buildShareIcon(Icons.facebook, Colors.blue.shade800, 'Facebook', () {}),
                _buildShareIcon(Icons.flutter_dash, Colors.lightBlue, 'Twitter', () {}),
                _buildShareIcon(Icons.more_horiz, Colors.grey.shade600, 'More', () {
                  context.pop();
                  _showMoreShareOptionsBottomSheet(context);
                }),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      url,
                      style: const TextStyle(fontSize: 10, color: AppColors.textLight),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                    child: const Text('Copy', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  static Widget _buildShareIcon(IconData icon, Color color, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textDark, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  static void _showMoreShareOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text('More Options', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            ),
            const SizedBox(height: 24),
            _buildMoreOptionRow(Icons.link, 'Copy Link'),
            _buildMoreOptionRow(Icons.mail_outline, 'Share via Email'),
            _buildMoreOptionRow(Icons.camera_alt_outlined, 'Share to Instagram'),
            _buildMoreOptionRow(Icons.message_outlined, 'Share to SMS'),
            _buildMoreOptionRow(Icons.qr_code, 'QR Code'),
            _buildMoreOptionRow(Icons.report_problem_outlined, 'Report an Issue'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  static Widget _buildMoreOptionRow(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textDark, size: 20),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textDark)),
        ],
      ),
    );
  }
}
