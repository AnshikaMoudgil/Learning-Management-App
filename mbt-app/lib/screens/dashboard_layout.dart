import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'home_dashboard.dart';
import 'my_courses_screen.dart';
import 'continue_watching_screen.dart';
import 'downloads_screen.dart';
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
    const MyCoursesScreen(),
    const ContinueWatchingScreen(),
    const DownloadsScreen(),
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
          BottomNavigationBarItem(icon: Icon(Icons.class_outlined), activeIcon: Icon(Icons.class_), label: 'My Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_outline), activeIcon: Icon(Icons.play_circle_fill), label: 'Continue'),
          BottomNavigationBarItem(icon: Icon(Icons.download_outlined), activeIcon: Icon(Icons.download), label: 'Downloads'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), activeIcon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}

