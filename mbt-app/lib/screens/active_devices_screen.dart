import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class ActiveDevicesScreen extends StatelessWidget {
  const ActiveDevicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark), onPressed: () => context.pop()),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Device Security', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Manage your active devices and sessions', style: TextStyle(color: AppColors.textLight, fontSize: 10)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.textDark),
            onPressed: () => context.push('/cart'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textDark),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Active Devices', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 4),
            const Text('These are the devices currently logged in to your account.', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
            const SizedBox(height: 16),

            // Current Device
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.1)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.laptop_mac, color: Colors.green, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                          child: const Text('Current Device', style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 4),
                        const Text("Abhishek's iPhone", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        const SizedBox(height: 4),
                        Row(
                          children: const [
                            Icon(Icons.apple, size: 12, color: AppColors.textLight),
                            SizedBox(width: 4),
                            Text('iOS 17.5', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: const [
                            Icon(Icons.location_on_outlined, size: 12, color: AppColors.textLight),
                            SizedBox(width: 4),
                            Text('Panipat, Haryana, India', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: const [
                            Icon(Icons.open_in_browser, size: 12, color: AppColors.textLight),
                            SizedBox(width: 4),
                            Text('Chrome Mobile 125.0', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Last Login', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                      const SizedBox(height: 2),
                      const Text('Today, 09:30 AM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                        child: const Text('This Device', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('Other Active Devices', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 16),
            _buildOtherDevice(Icons.desktop_windows, 'Windows PC', 'Windows 11', 'Panipat, Haryana, India', 'Chrome 124.0', 'Yesterday, 07:45 PM', Colors.blue),
            const SizedBox(height: 12),
            _buildOtherDevice(Icons.smartphone, 'Samsung Galaxy S23', 'Android 14', 'Panipat, Haryana, India', 'Chrome Mobile 124.0', '2 Jun 2024, 11:20 AM', Colors.deepPurple),
            const SizedBox(height: 12),
            _buildOtherDevice(Icons.laptop_mac, 'MacBook Air', 'macOS Sonoma 14.4', 'Gurugram, Haryana, India', 'Safari 17.4', '28 May 2024, 09:15 PM', Colors.orange),
            
            const SizedBox(height: 24),
            // Security Alert
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.security, color: AppColors.primaryBlue, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Don't recognize a device?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textDark)),
                        const SizedBox(height: 4),
                        RichText(
                          text: const TextSpan(
                            text: 'If you see any unfamiliar device or location, log out immediately and ',
                            style: TextStyle(fontSize: 11, color: AppColors.textLight, height: 1.5),
                            children: [
                              TextSpan(text: 'change your password.', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.lock_outline, size: 16, color: AppColors.textLight),
                SizedBox(width: 8),
                Expanded(
                  child: Text('For your security, we automatically log out inactive sessions after 30 days.', style: TextStyle(fontSize: 10, color: AppColors.textLight, height: 1.5)),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherDevice(IconData icon, String name, String os, String location, String browser, String lastLogin, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.computer, size: 12, color: AppColors.textLight),
                    const SizedBox(width: 4),
                    Text(os, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textLight),
                    const SizedBox(width: 4),
                    Text(location, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.open_in_browser, size: 12, color: AppColors.textLight),
                    const SizedBox(width: 4),
                    Text(browser, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(Icons.more_vert, size: 16, color: AppColors.textLight),
              const SizedBox(height: 12),
              const Text('Last Login', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
              const SizedBox(height: 2),
              Text(lastLogin, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  minimumSize: const Size(0, 28),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.logout, size: 12, color: Colors.redAccent),
                    SizedBox(width: 4),
                    Text('Log Out', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
