import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ProfileCoursesScreen extends StatefulWidget {
  const ProfileCoursesScreen({Key? key}) : super(key: key);

  @override
  State<ProfileCoursesScreen> createState() => _ProfileCoursesScreenState();
}

class _ProfileCoursesScreenState extends State<ProfileCoursesScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark), onPressed: () => Navigator.pop(context)),
        title: const Text('My Courses', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.search, color: AppColors.textDark), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: Row(
              children: [
                _buildTab('In Progress (3)', 0),
                _buildTab('Completed (2)', 1),
                _buildTab('Not Started (2)', 2),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (_selectedTab == 0) ...[
                  _buildCourseCard(
                    title: 'React - The Complete Guide',
                    progressPercent: 45,
                    completedLessons: 32,
                    totalLessons: 71,
                    buttonText: 'Continue',
                    icon: Icons.science,
                    color: const Color(0xFF0D1B2A),
                    isPrimaryBtn: true,
                  ),
                  _buildCourseCard(
                    title: 'Python for Data Science',
                    progressPercent: 30,
                    completedLessons: 12,
                    totalLessons: 40,
                    buttonText: 'Continue',
                    icon: Icons.code,
                    color: const Color(0xFF1B4332),
                    isPrimaryBtn: true,
                  ),
                  _buildCourseCard(
                    title: 'UI/UX Design Masterclass',
                    progressPercent: 20,
                    completedLessons: 10,
                    totalLessons: 50,
                    buttonText: 'Continue',
                    icon: Icons.design_services,
                    color: const Color(0xFF3B1E54),
                    isPrimaryBtn: true,
                  ),
                ] else if (_selectedTab == 2) ...[
                  _buildCourseCard(
                    title: 'Node.js Complete Guide',
                    progressPercent: 0,
                    completedLessons: 0,
                    totalLessons: 35,
                    buttonText: 'Start',
                    icon: Icons.javascript,
                    color: Colors.green,
                    isPrimaryBtn: false,
                  ),
                  _buildCourseCard(
                    title: 'AWS Certified Solutions Architect',
                    progressPercent: 0,
                    completedLessons: 0,
                    totalLessons: 120,
                    buttonText: 'Start',
                    icon: Icons.cloud,
                    color: Colors.orange,
                    isPrimaryBtn: false,
                  ),
                ] else ...[
                  _buildCourseCard(
                    title: 'Flutter for Beginners',
                    progressPercent: 100,
                    completedLessons: 60,
                    totalLessons: 60,
                    buttonText: 'Review',
                    icon: Icons.flutter_dash,
                    color: Colors.blue,
                    isPrimaryBtn: false,
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: isSelected ? AppColors.primaryBlue : Colors.transparent, width: 2)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primaryBlue : AppColors.textLight,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard({
    required String title,
    required int progressPercent,
    required int completedLessons,
    required int totalLessons,
    required String buttonText,
    required IconData icon,
    required Color color,
    required bool isPrimaryBtn,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Icon(icon, color: Colors.white, size: 40)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark), maxLines: 2),
                const SizedBox(height: 8),
                Text('$progressPercent% Complete', style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$completedLessons / $totalLessons lessons', style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPrimaryBtn ? AppColors.primaryBlue : Colors.white,
                        foregroundColor: isPrimaryBtn ? Colors.white : AppColors.primaryBlue,
                        side: isPrimaryBtn ? null : const BorderSide(color: AppColors.primaryBlue),
                        elevation: 0,
                        minimumSize: const Size(80, 32),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(buttonText, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    )
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
