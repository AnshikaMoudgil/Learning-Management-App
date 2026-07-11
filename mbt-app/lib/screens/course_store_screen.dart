import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'home_dashboard.dart';
import 'my_learning_screen.dart';
import 'live_classes_screen.dart';
import 'categories_screen.dart';
import 'popular_courses_screen.dart';
import 'newly_added_courses_screen.dart';
import 'profile_screen.dart';

class CourseStoreScreen extends StatefulWidget {
  const CourseStoreScreen({Key? key}) : super(key: key);

  @override
  State<CourseStoreScreen> createState() => _CourseStoreScreenState();
}

class _CourseStoreScreenState extends State<CourseStoreScreen> {
  void _onNavTapped(int index) {
    if (index == 3) return; // Already on Store
    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = const HomeDashboard();
        break;
      case 1:
        nextScreen = const MyLearningScreen();
        break;
      case 2:
        nextScreen = const LiveClassesScreen();
        break;
      case 4:
        nextScreen = const ProfileScreen(); // Will create this next
        break;
      default:
        return;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => nextScreen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Store', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.textDark), onPressed: () {}),
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
          IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.textDark), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: AppColors.textLight, size: 20),
                    hintText: 'Search for courses, topics or teachers...',
                    hintStyle: TextStyle(fontSize: 12, color: AppColors.textLight),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Categories
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildCategoryItem(Icons.grid_view, 'All', AppColors.primaryBlue.withValues(alpha: 0.1), AppColors.primaryBlue, true),
                  _buildCategoryItem(Icons.code, 'Development', Colors.green.withValues(alpha: 0.1), Colors.green, false),
                  _buildCategoryItem(Icons.bar_chart, 'Data Science', Colors.purple.withValues(alpha: 0.1), Colors.purple, false),
                  _buildCategoryItem(Icons.design_services, 'Design', Colors.pink.withValues(alpha: 0.1), Colors.pink, false),
                  _buildCategoryItem(Icons.business_center, 'Business', Colors.orange.withValues(alpha: 0.1), Colors.orange, false),
                  _buildCategoryItem(Icons.campaign, 'Marketing', Colors.teal.withValues(alpha: 0.1), Colors.teal, false),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Popular Courses Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Popular Courses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PopularCoursesScreen())),
                    child: const Text('View All', style: TextStyle(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Popular Courses List
            SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildPopularCourseCard(
                    title: 'React - The Complete Guide',
                    author: 'John Doe',
                    rating: '4.8 (12.6K)',
                    price: '₹799',
                    originalPrice: '₹1,999',
                    color: const Color(0xFF0D1B2A),
                    icon: Icons.science,
                    isBestseller: true,
                  ),
                  const SizedBox(width: 16),
                  _buildPopularCourseCard(
                    title: 'Python for Data Science',
                    author: 'Priya Sharma',
                    rating: '4.7 (9.8K)',
                    price: '₹699',
                    originalPrice: '₹1,499',
                    color: const Color(0xFF1B4332),
                    icon: Icons.code,
                    isBestseller: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Newly Added Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Newly Added', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewlyAddedCoursesScreen())),
                    child: const Text('View All', style: TextStyle(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Newly Added List
            SizedBox(
              height: 190,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildNewlyAddedCard(
                    title: 'Node.js\nComplete Guide',
                    author: 'Aditya Singh',
                    rating: '4.5 (1.2K)',
                    price: '₹499',
                    originalPrice: '₹1,499',
                    color: Colors.green,
                    icon: Icons.javascript,
                  ),
                  const SizedBox(width: 16),
                  _buildNewlyAddedCard(
                    title: 'AWS Certified\nSolutions Architect',
                    author: 'Neha Kumari',
                    rating: '4.7 (932)',
                    price: '₹999',
                    originalPrice: '₹2,499',
                    color: Colors.orange,
                    icon: Icons.cloud,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        onTap: _onNavTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textLight,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'My Learning'),
          BottomNavigationBarItem(icon: Icon(Icons.sensors), label: 'Live Classes'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Store'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label, Color bgColor, Color iconColor, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (label == 'All') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen()));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: isSelected ? Border.all(color: AppColors.primaryBlue, width: 2) : null,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 10, color: isSelected ? AppColors.primaryBlue : AppColors.textDark, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularCourseCard({
    required String title,
    required String author,
    required String rating,
    required String price,
    required String originalPrice,
    required Color color,
    required IconData icon,
    required bool isBestseller,
  }) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            height: double.infinity,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            ),
            child: Stack(
              children: [
                Center(child: Icon(icon, color: Colors.white, size: 48)),
                if (isBestseller)
                  Positioned(
                    top: 8,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
                      ),
                      child: const Text('Bestseller', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
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
                      Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark), maxLines: 2)),
                      const Icon(Icons.favorite_border, size: 16, color: AppColors.textLight),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const CircleAvatar(radius: 8, backgroundImage: AssetImage('assets/1.png')),
                      const SizedBox(width: 4),
                      Expanded(child: Text(author, style: const TextStyle(fontSize: 10, color: AppColors.textLight), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 12),
                      const SizedBox(width: 4),
                      Text(rating, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    ],
                  ),
                  const SizedBox(height: 4),
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

  Widget _buildNewlyAddedCard({
    required String title,
    required String author,
    required String rating,
    required String price,
    required String originalPrice,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 24),
              ),
              const Icon(Icons.favorite_border, size: 16, color: AppColors.textLight),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark), maxLines: 2),
          const SizedBox(height: 8),
          Row(
            children: [
              const CircleAvatar(radius: 6, backgroundImage: AssetImage('assets/1.png')),
              const SizedBox(width: 4),
              Expanded(child: Text(author, style: const TextStyle(fontSize: 9, color: AppColors.textLight), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(price, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 10),
                  const SizedBox(width: 2),
                  Text(rating, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
