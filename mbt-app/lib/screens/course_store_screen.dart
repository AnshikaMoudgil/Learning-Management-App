import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class CourseStoreScreen extends StatefulWidget {
  const CourseStoreScreen({Key? key}) : super(key: key);

  @override
  State<CourseStoreScreen> createState() => _CourseStoreScreenState();
}

class _CourseStoreScreenState extends State<CourseStoreScreen> {
  int _selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.grid_view_rounded, 'name': 'All', 'color': Colors.blue},
    {'icon': Icons.code, 'name': 'Development', 'color': Colors.green},
    {'icon': Icons.analytics_outlined, 'name': 'Data Science', 'color': Colors.purple},
    {'icon': Icons.design_services_outlined, 'name': 'Design', 'color': Colors.pink},
    {'icon': Icons.business_center_outlined, 'name': 'Business', 'color': Colors.orange},
    {'icon': Icons.campaign_outlined, 'name': 'Marketing', 'color': Colors.cyan},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Course Store', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                          SizedBox(height: 4),
                          Text('Discover the best courses to learn and grow', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                        ],
                      ),
                    ),
                    _buildIconBadge(Icons.shopping_cart_outlined, '2', Colors.blue, () => context.push('/cart')),
                    const SizedBox(width: 16),
                    _buildIconBadge(Icons.notifications_outlined, '3', Colors.red, () => context.push('/notifications')),
                  ],
                ),
              ),

              // Search & Filter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText: 'Search for courses, topics or teachers...',
                                  hintStyle: TextStyle(fontSize: 12, color: AppColors.textLight),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Categories
              _buildSectionHeader('Categories', onViewAll: () {
                context.push('/categories');
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedCategoryIndex = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _selectedCategoryIndex == 0 ? Colors.blue.withValues(alpha: 0.1) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _selectedCategoryIndex == 0 ? Colors.blue : Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.developer_mode, color: _selectedCategoryIndex == 0 ? Colors.blue : Colors.grey, size: 24),
                              const SizedBox(height: 8),
                              Text('Software', style: TextStyle(fontSize: 12, fontWeight: _selectedCategoryIndex == 0 ? FontWeight.bold : FontWeight.normal, color: AppColors.textDark)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedCategoryIndex = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _selectedCategoryIndex == 1 ? Colors.blue.withValues(alpha: 0.1) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _selectedCategoryIndex == 1 ? Colors.blue : Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.memory, color: _selectedCategoryIndex == 1 ? Colors.blue : Colors.grey, size: 24),
                              const SizedBox(height: 8),
                              Text('Hardware', style: TextStyle(fontSize: 12, fontWeight: _selectedCategoryIndex == 1 ? FontWeight.bold : FontWeight.normal, color: AppColors.textDark)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Popular Courses
              _buildSectionHeader('Popular Courses', onViewAll: () {
                context.push('/popular-courses');
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildPopularCourseCard(
                      image: 'assets/iphone_software.png',
                      title: 'React - The Complete Guide',
                      subtitle: 'Build modern web apps using React, Hooks, Context API and more.',
                      author: 'John Doe',
                      authorRole: 'Senior Frontend Developer',
                      rating: '4.8',
                      reviews: '12.6K',
                      duration: '32 hours',
                      level: 'Beginner to Advanced',
                      price: '₹799',
                      oldPrice: '₹1,999',
                      isBestseller: true,
                    ),
                    const SizedBox(height: 16),
                    _buildPopularCourseCard(
                      image: 'assets/android_hardware.png',
                      title: 'Python for Data Science',
                      subtitle: 'Learn Python, NumPy, Pandas, Matplotlib and build real-world projects.',
                      author: 'Priya Sharma',
                      authorRole: 'Data Scientist',
                      rating: '4.7',
                      reviews: '8.9K',
                      duration: '28 hours',
                      level: 'Beginner',
                      price: '₹699',
                      oldPrice: '₹1,799',
                    ),
                    const SizedBox(height: 16),
                    _buildPopularCourseCard(
                      image: 'assets/iphone_hardware.png',
                      title: 'UI/UX Design Masterclass',
                      subtitle: 'Design beautiful and user-friendly interfaces like a pro.',
                      author: 'Rohan Verma',
                      authorRole: 'Product Designer',
                      rating: '4.6',
                      reviews: '6.4K',
                      duration: '18 hours',
                      level: 'All Levels',
                      price: '₹599',
                      oldPrice: '₹1,499',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Newly Added
              _buildSectionHeader('Newly Added', onViewAll: () {
                context.push('/newly-added-courses');
              }),
              SizedBox(
                height: 160,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildNewlyAddedCard(
                      icon: Icons.hexagon_outlined,
                      iconColor: Colors.green,
                      title: 'Node.js\nComplete Guide',
                      author: 'Aditya Singh',
                      rating: '4.5',
                      reviews: '1.2K',
                      duration: '16 hours',
                      price: '₹499',
                      oldPrice: '₹1,299',
                    ),
                    const SizedBox(width: 16),
                    _buildNewlyAddedCard(
                      icon: Icons.cloud_outlined,
                      iconColor: Colors.orange,
                      title: 'AWS Certified\nSolutions Architect',
                      author: 'Neha Kumari',
                      rating: '4.7',
                      reviews: '932',
                      duration: '20 hours',
                      price: '₹999',
                      oldPrice: '₹2,499',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconBadge(IconData icon, String count, Color badgeColor, VoidCallback onTap) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(icon: Icon(icon, color: AppColors.textDark), onPressed: onTap),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: Text(count, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ),
        )
      ],
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: const Text('View All', style: TextStyle(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildPopularCourseCard({
    required String image,
    required String title,
    required String subtitle,
    required String author,
    required String authorRole,
    required String rating,
    required String reviews,
    required String duration,
    required String level,
    required String price,
    required String oldPrice,
    bool isBestseller = false,
  }) {
    return GestureDetector(
      onTap: () => context.push('/course'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Container(
              width: 140,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
              ),
              child: Stack(
                children: [
                  if (isBestseller)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(4)),
                        child: const Text('Bestseller', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black)),
                      ),
                    ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            // Details Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark), maxLines: 2, overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 4),
                        const Icon(Icons.favorite_border, size: 18, color: Colors.grey),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textLight), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const CircleAvatar(radius: 10, backgroundImage: AssetImage('assets/1.png')),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(author, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                              Text(authorRole, style: const TextStyle(fontSize: 8, color: AppColors.textLight)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 4),
                        Text('$rating ($reviews)', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        const SizedBox(width: 8),
                        const Text('•', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                        const SizedBox(width: 8),
                        Text(duration, style: const TextStyle(fontSize: 10, color: AppColors.textDark)),
                        const SizedBox(width: 8),
                        const Text('•', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(level, style: const TextStyle(fontSize: 10, color: AppColors.textDark), overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                        const SizedBox(width: 8),
                        Text(oldPrice, style: const TextStyle(fontSize: 10, color: AppColors.textLight, decoration: TextDecoration.lineThrough)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewlyAddedCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String author,
    required String rating,
    required String reviews,
    required String duration,
    required String price,
    required String oldPrice,
  }) {
    return GestureDetector(
      onTap: () => context.push('/course'),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const Icon(Icons.favorite_border, size: 18, color: Colors.grey),
              ],
            ),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textDark), maxLines: 2),
            const SizedBox(height: 8),
            Row(
              children: [
                const CircleAvatar(radius: 8, backgroundImage: AssetImage('assets/1.png')),
                const SizedBox(width: 6),
                Expanded(child: Text(author, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textDark))),
                Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textDark)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 10),
                const SizedBox(width: 4),
                Text('$rating ($reviews)', style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(width: 8),
                const Text('•', style: TextStyle(fontSize: 8, color: AppColors.textLight)),
                const SizedBox(width: 8),
                Text(duration, style: const TextStyle(fontSize: 8, color: AppColors.textDark)),
                const Spacer(),
                Text(oldPrice, style: const TextStyle(fontSize: 8, color: AppColors.textLight, decoration: TextDecoration.lineThrough)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
