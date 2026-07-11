import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark), onPressed: () => Navigator.pop(context)),
        title: const Text('Help Center', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: AppColors.textLight, size: 20),
                  hintText: 'Search for help articles...',
                  hintStyle: TextStyle(fontSize: 12, color: AppColors.textLight),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Categories', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildHelpCategory(Icons.person_outline, 'Account & Login', '12 Articles', Colors.blue),
                _buildHelpCategory(Icons.payment, 'Payments & Refunds', '10 Articles', Colors.green),
                _buildHelpCategory(Icons.devices, 'Device Transfer', '8 Articles', Colors.blueAccent),
                _buildHelpCategory(Icons.sensors, 'Live Classes', '15 Articles', Colors.red),
                _buildHelpCategory(Icons.workspace_premium, 'Certificates', '7 Articles', Colors.orange),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHelpCategory(IconData icon, String title, String subtitle, Color color) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textLight),
          onTap: () {},
        ),
        const Divider(height: 1, color: AppColors.border, indent: 80),
      ],
    );
  }
}
