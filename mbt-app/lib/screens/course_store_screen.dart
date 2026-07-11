import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CourseStoreScreen extends StatelessWidget {
  const CourseStoreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(),
              _buildSearchBar(),
              _buildCategories(),
              _buildPopularCourses(),
              _buildNewlyAdded(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Course Store', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                SizedBox(height: 4),
                Text('Discover the best courses to learn and grow', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
              ],
            ),
          ),
          Row(
            children: [
              Stack(
                children: [
                  const Icon(Icons.shopping_cart_outlined, color: AppColors.textDark, size: 24),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                      child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Stack(
                children: [
                  const Icon(Icons.notifications_none, color: AppColors.textDark, size: 24),
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: const [
                  Icon(Icons.search, color: AppColors.textLight, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search for courses, topics or teachers...',
                        hintStyle: TextStyle(color: AppColors.textLight, fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: const [
                Icon(Icons.tune, color: AppColors.textDark, size: 16),
                SizedBox(width: 8),
                Text('Filters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'icon': Icons.grid_view, 'label': 'All', 'color': Colors.blue},
      {'icon': Icons.code, 'label': 'Development', 'color': Colors.green},
      {'icon': Icons.bar_chart, 'label': 'Data Science', 'color': Colors.purple},
      {'icon': Icons.design_services, 'label': 'Design', 'color': Colors.pink},
      {'icon': Icons.business_center, 'label': 'Business', 'color': Colors.orange},
      {'icon': Icons.campaign, 'label': 'Marketing', 'color': Colors.teal},
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
              Text('View All', style: TextStyle(color: AppColors.primaryBlue, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = index == 0;
              return Container(
                width: 70,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? Colors.blue : AppColors.border),
                  boxShadow: isSelected ? [BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))] : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: (cat['color'] as Color).withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(cat['icon'] as IconData, color: cat['color'] as Color, size: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(cat['label'] as String, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textDark), overflow: TextOverflow.ellipsis),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularCourses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Popular Courses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
              Text('View All', style: TextStyle(color: AppColors.primaryBlue, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildPopularCourseCard('assets/iphone_software.png', 'React - The Complete Guide', 'Build modern web apps using React, Hooks, Context API and more.', 'John Doe', 'Senior Frontend Developer', '4.8 (12.6K)', '32 hours', 'Beginner to Advanced', '₹799', '₹1,999', true),
        _buildPopularCourseCard('assets/iphone_software.png', 'Python for Data Science', 'Learn Python, NumPy, Pandas, Matplotlib and build real-world projects.', 'Priya Sharma', 'Data Scientist', '4.7 (8.9K)', '28 hours', 'Beginner', '₹699', '₹1,799', false),
        _buildPopularCourseCard('assets/iphone_software.png', 'UI/UX Design Masterclass', 'Design beautiful and user-friendly interfaces like a pro.', 'Rohan Verma', 'Product Designer', '4.6 (6.4K)', '18 hours', 'All Levels', '₹599', '₹1,499', false),
      ],
    );
  }

  Widget _buildPopularCourseCard(String imagePath, String title, String desc, String instructor, String instructorRole, String rating, String duration, String level, String price, String oldPrice, bool isBestseller) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120,
                height: 130, // Adjusted height to accommodate text
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                  color: Color(0xFF0F172A),
                ),
                child: Stack(
                  children: [
                    Center(child: Icon(Icons.code, color: Colors.blue.withOpacity(0.5), size: 48)), // Placeholder
                    if (isBestseller)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(4)),
                          child: const Text('Bestseller', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                        child: const Icon(Icons.play_circle_outline, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark))),
                          const Icon(Icons.favorite_border, color: AppColors.textLight, size: 16),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(desc, style: const TextStyle(fontSize: 10, color: AppColors.textLight, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const CircleAvatar(radius: 10, backgroundImage: AssetImage('assets/1.png')),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(instructor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textDark)),
                                Text(instructorRole, style: const TextStyle(fontSize: 9, color: AppColors.textLight)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
                              Text(oldPrice, style: const TextStyle(fontSize: 9, color: AppColors.textLight, decoration: TextDecoration.lineThrough)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Bottom Stats
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.lightBlueBg,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 12),
                const SizedBox(width: 4),
                Text(rating, style: const TextStyle(fontSize: 10, color: AppColors.textDark, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                const Text('•', style: TextStyle(color: AppColors.textLight)),
                const SizedBox(width: 8),
                Text(duration, style: const TextStyle(fontSize: 10, color: AppColors.textDark)),
                const SizedBox(width: 8),
                const Text('•', style: TextStyle(color: AppColors.textLight)),
                const SizedBox(width: 8),
                Text(level, style: const TextStyle(fontSize: 10, color: AppColors.textDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewlyAdded() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Newly Added', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
              Text('View All', style: TextStyle(color: AppColors.primaryBlue, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildSmallCourseCard('Node.js', 'Complete Guide', 'Aditya Singh', '₹499', '₹1,299', '4.5 (1.2K)', '16 hours', Colors.green),
              _buildSmallCourseCard('AWS', 'AWS Certified\nSolutions Architect', 'Neha Kumari', '₹999', '₹2,499', '4.7 (932)', '20 hours', Colors.orange),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSmallCourseCard(String iconText, String title, String instructor, String price, String oldPrice, String rating, String duration, Color color) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text(iconText, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textDark), maxLines: 2)),
                    const Icon(Icons.favorite_border, color: AppColors.textLight, size: 14),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const CircleAvatar(radius: 8, backgroundImage: AssetImage('assets/1.png')),
                    const SizedBox(width: 4),
                    Expanded(child: Text(instructor, style: const TextStyle(fontSize: 10, color: AppColors.textDark))),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 10),
                    const SizedBox(width: 2),
                    Text(rating, style: const TextStyle(fontSize: 9, color: AppColors.textDark, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    const Text('•', style: TextStyle(color: AppColors.textLight, fontSize: 8)),
                    const SizedBox(width: 4),
                    Text(duration, style: const TextStyle(fontSize: 9, color: AppColors.textDark)),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textDark)),
                        Text(oldPrice, style: const TextStyle(fontSize: 8, color: AppColors.textLight, decoration: TextDecoration.lineThrough)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
