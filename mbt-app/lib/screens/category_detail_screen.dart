import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CategoryDetailScreen extends StatelessWidget {
  const CategoryDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark), onPressed: () => Navigator.pop(context)),
        title: const Text('Web Development', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.search, color: AppColors.textDark), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2260),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Icon(Icons.code, color: Colors.white.withValues(alpha: 0.1), size: 120),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('Web Development', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('128 Courses', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Popular Courses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 16),
          _buildCourseListCard(
            title: 'React - The Complete Guide',
            rating: '4.8 (12.6K)',
            enrolled: '12.5K Enrolled',
            price: '₹799',
            originalPrice: '₹1,999',
            icon: Icons.science,
            color: const Color(0xFF0D1B2A),
          ),
          _buildCourseListCard(
            title: 'Node.js Complete Guide',
            rating: '4.6 (6.1K)',
            enrolled: '6.1K Enrolled',
            price: '₹499',
            originalPrice: '₹1,499',
            icon: Icons.javascript,
            color: Colors.green,
          ),
          _buildCourseListCard(
            title: 'Full Stack Web Development',
            rating: '4.7 (8.2K)',
            enrolled: '8.2K Enrolled',
            price: '₹1,499',
            originalPrice: '₹2,999',
            icon: Icons.javascript,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildCourseListCard({
    required String title,
    required String rating,
    required String enrolled,
    required String price,
    required String originalPrice,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            ),
            child: Center(child: Icon(icon, color: Colors.white, size: 36)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark), maxLines: 2),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 12),
                      const SizedBox(width: 4),
                      Text(rating, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      const SizedBox(width: 8),
                      Text(enrolled, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      const SizedBox(width: 8),
                      Text(originalPrice, style: const TextStyle(fontSize: 10, color: AppColors.textLight, decoration: TextDecoration.lineThrough)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
