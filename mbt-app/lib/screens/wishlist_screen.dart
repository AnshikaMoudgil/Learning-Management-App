import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'home_dashboard.dart';
import 'my_courses_screen.dart';
import 'live_classes_screen.dart';
import 'more_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  // Toggle this to see empty vs populated state
  bool _isEmpty = false;

  void _onNavTapped(int index) {
    if (index == 3) return;
    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = const HomeDashboard();
        break;
      case 1:
        nextScreen = const MyCoursesScreen();
        break;
      case 2:
        nextScreen = const LiveClassesScreen();
        break;
      case 4:
        nextScreen = const MoreScreen();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Wishlist', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.textDark), onPressed: () {}),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center),
                ),
              )
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isEmpty ? _buildEmptyState() : _buildPopulatedState(),
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
          BottomNavigationBarItem(icon: Icon(Icons.video_library_outlined), label: 'My Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.sensors), label: 'Live Classes'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Wishlist'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'More'),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/wishlist_empty.png',
              width: 250,
              height: 250,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.favorite_border, size: 100, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 24),
            const Text('Your wishlist is empty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 12),
            const Text(
              'Save courses and products you\'re interested in for later.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textLight),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.school, color: Colors.white, size: 20),
              label: const Text('Explore Courses', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.textDark, size: 20),
              label: const Text('Explore Store', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopulatedState() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('6 items', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
              Row(
                children: const [
                  Text('Sort by: ', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                  Text('Recently Added', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  Icon(Icons.keyboard_arrow_down, size: 16),
                ],
              )
            ],
          ),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.65,
            children: [
              _buildWishlistItem(
                title: 'Mobile IC Repair\nComplete Course',
                author: 'By Mr. Ankit Verma',
                price: '₹4,999',
                rating: '4.8 (1.2k)',
                image: 'assets/iphone_hardware.png',
                tag: 'COURSE',
                isPremium: true,
              ),
              _buildWishlistItem(
                title: 'Advanced Soldering\nTechniques',
                author: 'By Mr. Rahul Sharma',
                price: '₹2,499',
                rating: '4.7 (842)',
                image: 'assets/iphone_software.png',
                tag: 'COURSE',
                isPremium: true,
              ),
              _buildWishlistItem(
                title: 'Android Phone\nRepair Mastery',
                author: 'By Mr. Sonu Singh',
                price: '₹1,999',
                rating: '4.6 (621)',
                image: 'assets/android_hardware.png',
                tag: 'COURSE',
                isPremium: false,
              ),
              _buildWishlistItem(
                title: 'Quick 861DW Hot Air\nRework Station',
                author: '',
                price: '₹6,499',
                rating: '',
                image: 'assets/iphone_hardware.png', // placeholder
                tag: 'HARDWARE',
                isPremium: false,
              ),
              _buildWishlistItem(
                title: 'Trinocular Microscope\n7X-45X',
                author: '',
                price: '₹12,999',
                rating: '',
                image: 'assets/iphone_software.png', // placeholder
                tag: 'HARDWARE',
                isPremium: false,
              ),
              _buildWishlistItem(
                title: 'Digital Multimeter\nTrue RMS',
                author: '',
                price: '₹1,299',
                rating: '',
                image: 'assets/android_hardware.png', // placeholder
                tag: 'HARDWARE',
                isPremium: false,
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildWishlistItem({
    required String title,
    required String author,
    required String price,
    required String rating,
    required String image,
    required String tag,
    required bool isPremium,
  }) {
    bool isCourse = tag == 'COURSE';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image and badges
          Stack(
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: isCourse ? AppColors.primaryBlue : Colors.purple, borderRadius: BorderRadius.circular(4)),
                  child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.favorite, color: Colors.red, size: 16),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark), maxLines: 2, overflow: TextOverflow.ellipsis),
                if (author.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(author, style: const TextStyle(fontSize: 9, color: AppColors.textLight)),
                ],
                if (rating.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 10),
                      const SizedBox(width: 4),
                      Text(rating, style: const TextStyle(fontSize: 9, color: AppColors.textDark)),
                      const SizedBox(width: 4),
                      if (isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                          child: const Text('Premium', style: TextStyle(color: AppColors.primaryBlue, fontSize: 8)),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                          child: const Text('Free', style: TextStyle(color: Colors.green, fontSize: 8)),
                        )
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Text(price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.shopping_cart, size: 12),
                        label: const Text('Add to Cart', style: TextStyle(fontSize: 9)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                          minimumSize: const Size(0, 28),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.delete_outline, size: 16, color: AppColors.textLight),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
