import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../widgets/cart_badge.dart';

class NewlyAddedCoursesScreen extends StatelessWidget {
  const NewlyAddedCoursesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark), onPressed: () => context.pop()),
        title: const Text('Newly Added', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('32 Courses', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                Row(
                  children: const [
                    Text('Sorted by: ', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                    Text('Newest First', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
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
                childAspectRatio: 0.85,
              ),
              itemCount: 8,
              itemBuilder: (context, index) {
                return _buildNewCard(index);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNewCard(int index) {
    List<Map<String, dynamic>> items = [
      {'title': 'Flutter for Beginners', 'price': '₹2,199', 'color': Colors.blue, 'icon': Icons.flutter_dash},
      {'title': 'Docker Essentials', 'price': '₹1,799', 'color': Colors.lightBlue, 'icon': Icons.directions_boat},
      {'title': 'SQL - Complete Bootcamp', 'price': '₹1,699', 'color': Colors.blueAccent, 'icon': Icons.storage},
      {'title': 'Git & GitHub - Complete', 'price': '₹999', 'color': Colors.orange, 'icon': Icons.source},
      {'title': 'Data Structures & Algorithms', 'price': '₹2,399', 'color': Colors.blue, 'icon': Icons.account_tree},
      {'title': 'JavaScript Essentials', 'price': '₹1,499', 'color': Colors.yellow.shade700, 'icon': Icons.javascript},
      {'title': 'C++ Programming Masterclass', 'price': '₹1,799', 'color': Colors.blue.shade800, 'icon': Icons.terminal},
      {'title': 'Machine Learning A-Z', 'price': '₹2,499', 'color': Colors.red, 'icon': Icons.psychology},
    ];

    var item = items[index % items.length];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.purple, borderRadius: BorderRadius.circular(4)),
                child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: item['color'].withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(item['icon'], color: item['color'], size: 32),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['title'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark), maxLines: 2),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(Icons.star, color: Colors.orange, size: 10),
                    SizedBox(width: 2),
                    Text('4.6 (460)', style: TextStyle(fontSize: 9, color: AppColors.textDark, fontWeight: FontWeight.bold)),
                    SizedBox(width: 4),
                    Text('562 Enrolled', style: TextStyle(fontSize: 9, color: AppColors.textLight)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(item['price'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
