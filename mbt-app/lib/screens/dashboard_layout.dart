import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'home_dashboard.dart';
import 'my_learning_screen.dart';
import 'live_classes_screen.dart';
import 'course_store_screen.dart';
import 'more_screen.dart';

class DashboardLayout extends StatefulWidget {
  const DashboardLayout({Key? key}) : super(key: key);

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeDashboard(),
    const MyLearningScreen(),
    const LiveClassesScreen(),
    const CourseStoreScreen(),
    const MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textLight,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), activeIcon: Icon(Icons.menu_book), label: 'My Learning'),
          BottomNavigationBarItem(icon: Icon(Icons.video_camera_front_outlined), activeIcon: Icon(Icons.video_camera_front), label: 'Live Classes'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), activeIcon: Icon(Icons.shopping_bag), label: 'Store'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), activeIcon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}

