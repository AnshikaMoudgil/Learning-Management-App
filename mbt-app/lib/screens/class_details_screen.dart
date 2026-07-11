import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ClassDetailsScreen extends StatelessWidget {
  const ClassDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark), onPressed: () => Navigator.pop(context)),
        title: const Text('Class Details', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined, color: AppColors.textDark), onPressed: () {}),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: const DecorationImage(
                          image: AssetImage('assets/iphone_hardware.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                        child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlueBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('iPhone Hardware Course', style: TextStyle(color: AppColors.primaryBlue, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                const Text('Display Light Problem Diagnosis', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const CircleAvatar(radius: 16, backgroundImage: AssetImage('assets/1.png')),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Text('Rahul Verma', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                            SizedBox(width: 4),
                            Icon(Icons.verified, color: AppColors.primaryBlue, size: 14),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text('Hardware Expert', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: _buildInfoBox(Icons.calendar_month_outlined, '2 May 2025, Friday')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildInfoBox(Icons.access_time, '07:00 PM - 08:00 PM')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildInfoBox(Icons.timer_outlined, '60 min')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildInfoBox(Icons.videocam_outlined, 'Live on Zoom (Secure)')),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('About this class', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 8),
                const Text(
                  'Learn to diagnose and fix display light issues in iPhones. We\'ll cover real-world examples and step-by-step troubleshooting.',
                  style: TextStyle(fontSize: 12, color: AppColors.textDark, height: 1.5),
                ),
                const SizedBox(height: 24),
                const Text('What you\'ll learn', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 12),
                _buildCheckListItem('Identify display backlight faults'),
                _buildCheckListItem('Use multimeter for light circuit checks'),
                _buildCheckListItem('Replace faulty components'),
                _buildCheckListItem('Real-life troubleshooting techniques'),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        side: const BorderSide(color: AppColors.primaryBlue),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Add to Calendar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text('Join Class', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoBox(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: AppColors.textLight),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 10, color: AppColors.textDark, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildCheckListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
            child: const Icon(Icons.check, color: Colors.white, size: 12),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textDark))),
        ],
      ),
    );
  }
}
