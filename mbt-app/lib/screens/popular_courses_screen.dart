import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class PopularCoursesScreen extends StatelessWidget {
  const PopularCoursesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark), onPressed: () => context.pop()),
        title: const Text('Popular Courses', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.textDark), onPressed: () => context.push('/cart')),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center),
                ),
              )
            ],
          ),
          IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.textDark), onPressed: () => context.push('/notifications')),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('48 Courses', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                Row(
                  children: const [
                    Text('Sorted by: ', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                    Text('Popularity', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    Icon(Icons.keyboard_arrow_down, size: 16),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: 8,
              itemBuilder: (context, index) {
                return _buildPopularCard(index + 1);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPopularCard(int rank) {
    // Generate dummy data based on rank for variety
    String title = rank % 2 != 0 ? 'React - The Complete Guide' : 'Python for Data Science';
    Color color = rank % 2 != 0 ? const Color(0xFF0D1B2A) : const Color(0xFF1B4332);
    IconData icon = rank % 2 != 0 ? Icons.science : Icons.code;
    String price = rank % 2 != 0 ? '₹799' : '₹699';
    String originalPrice = rank % 2 != 0 ? '₹1,999' : '₹1,299';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Stack(
                children: [
                  Center(child: Icon(icon, color: Colors.white, size: 40)),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                      child: Center(child: Text('$rank', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10))),
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark), maxLines: 2),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 12),
                    const SizedBox(width: 4),
                    const Text('4.8 (12.6K)', style: TextStyle(fontSize: 9, color: AppColors.textDark, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    const SizedBox(width: 8),
                    Text(originalPrice, style: const TextStyle(fontSize: 10, color: AppColors.textLight, decoration: TextDecoration.lineThrough)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
