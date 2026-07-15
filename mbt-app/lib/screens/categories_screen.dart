import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'category_detail_screen.dart';
import 'package:go_router/go_router.dart';
import '../widgets/cart_badge.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark), onPressed: () => context.pop()),
        title: const Text('Categories', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          const CartBadge(),
          IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.textDark), onPressed: () => context.push('/notifications')),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                  hintText: 'Search categories...',
                  hintStyle: TextStyle(fontSize: 12, color: AppColors.textLight),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildCategoryTile(context, 'Development', '128 Courses', Icons.code, Colors.green),
                _buildCategoryTile(context, 'Data Science', '86 Courses', Icons.bar_chart, Colors.purple),
                _buildCategoryTile(context, 'Design', '74 Courses', Icons.design_services, Colors.pink),
                _buildCategoryTile(context, 'Business', '62 Courses', Icons.business_center, Colors.orange),
                _buildCategoryTile(context, 'Marketing', '48 Courses', Icons.campaign, Colors.teal),
                _buildCategoryTile(context, 'IT & Software', '56 Courses', Icons.computer, Colors.blue),
                _buildCategoryTile(context, 'Personal Development', '40 Courses', Icons.favorite_border, Colors.red),
                _buildCategoryTile(context, 'Lifestyle', '34 Courses', Icons.emoji_emotions_outlined, Colors.orangeAccent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        if (title == 'Development') {
          context.push('/category-detail');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.1), Colors.white],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}
