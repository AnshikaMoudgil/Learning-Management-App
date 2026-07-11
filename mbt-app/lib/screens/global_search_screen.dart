import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({Key? key}) : super(key: key);

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  int _selectedTab = 0;
  final TextEditingController _searchController = TextEditingController(text: 'react');
  final List<String> _tabs = ['All', 'Courses', 'Recordings', 'Teachers'];
  final List<String> _tabCounts = ['62', '18', '14', '10'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Global Search', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            SizedBox(height: 2),
            Text('Find courses, recordings and teachers', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
          ],
        ),
        actions: [
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.lightBlueBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.shopping_cart_outlined, color: AppColors.textDark, size: 18),
              ),
              Positioned(
                right: 0,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                  child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.lightBlueBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.notifications_outlined, color: AppColors.textDark, size: 18),
              ),
              Positioned(
                right: 0,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.textLight, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search courses, recordings, teachers...',
                        hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14),
                      ),
                      style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                    ),
                  ),
                  GestureDetector(
                    onTap: () { _searchController.clear(); },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: AppColors.textLight, shape: BoxShape.circle),
                      child: const Icon(Icons.close, color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  final isSelected = _selectedTab == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryBlue : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? AppColors.primaryBlue : AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (index == 0) Icon(Icons.filter_list, size: 14, color: isSelected ? Colors.white : AppColors.textLight),
                            if (index == 1) Icon(Icons.menu_book_outlined, size: 14, color: isSelected ? Colors.white : AppColors.textLight),
                            if (index == 2) Icon(Icons.play_circle_outline, size: 14, color: isSelected ? Colors.white : AppColors.textLight),
                            if (index == 3) Icon(Icons.person_outline, size: 14, color: isSelected ? Colors.white : AppColors.textLight),
                            const SizedBox(width: 6),
                            Text(_tabs[index], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textDark)),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white.withOpacity(0.2) : AppColors.lightBlueBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(_tabCounts[index], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.primaryBlue)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Results
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Courses Section
                  _buildSectionTitle(Icons.menu_book, 'Courses', 'View All (18)'),
                  const SizedBox(height: 12),
                  _buildCourseResult(
                    'React JS - Complete Guide',
                    'By Coding Academy',
                    'Beginner',
                    '4.8 (2.4K)',
                    '12 Hours',
                    '₹799',
                    '₹3,899',
                    '75% Off',
                    const Color(0xFF61DAFB),
                    'React\nJS',
                  ),
                  _buildCourseResult(
                    'Advanced React - Hooks, Context & More',
                    'By Dev Learn',
                    'Intermediate',
                    '4.7 (1.9K)',
                    '8.5 Hours',
                    '₹999',
                    '₹2,499',
                    '60% Off',
                    const Color(0xFF2196F3),
                    'React\nAdvanced',
                  ),
                  _buildCourseResult(
                    'React Projects - Build Real World Apps',
                    'By CodeWithYou',
                    'Intermediate',
                    '4.6 (856)',
                    '10 Hours',
                    '₹699',
                    '₹1,399',
                    '50% Off',
                    const Color(0xFF1565C0),
                    'React\nProjects',
                  ),
                  const SizedBox(height: 24),

                  // Recordings Section
                  _buildSectionTitle(Icons.play_circle_outline, 'Recordings', 'View All (14)'),
                  const SizedBox(height: 12),
                  _buildRecordingResult('React JS Crash Course for Beginners', 'By Ankit Sharma', '20 May 2024', '1:24:35', 'React\nCrash Course'),
                  _buildRecordingResult('Understanding useState in React', 'By Priya Verma', '18 May 2024', '32:18', 'useState\nin React'),
                  _buildRecordingResult('React Hooks Explained with Examples', 'By Rahul Kumar', '15 May 2024', '45:07', 'React Hooks\nExplained'),
                  const SizedBox(height: 24),

                  // Teachers Section
                  _buildSectionTitle(Icons.person_outline, 'Teachers', 'View All (10)'),
                  const SizedBox(height: 12),
                  _buildTeacherResult('Ankit Sharma', 'React Developer & Instructor', '4.8 (3.2K Students)', '12 Courses'),
                  _buildTeacherResult('Priya Verma', 'Frontend Engineer | React Specialist', '4.7 (2.1K Students)', '8 Courses'),
                  _buildTeacherResult('Rahul Kumar', 'Senior Software Engineer', '4.6 (1.6K Students)', '6 Courses'),
                  const SizedBox(height: 16),

                  // Bottom help
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.textLight, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Can't find what you're looking for?", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                              SizedBox(height: 2),
                              Text('Try different keywords or check the spelling.', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title, String viewAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primaryBlue),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          ],
        ),
        Row(
          children: [
            Text(viewAll, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 16, color: AppColors.primaryBlue),
          ],
        ),
      ],
    );
  }

  Widget _buildCourseResult(String title, String author, String level, String rating, String hours, String price, String oldPrice, String discount, Color iconBg, String iconText) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Course icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(iconText, textAlign: TextAlign.center, style: TextStyle(color: iconBg, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(author, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.lightBlueBg, borderRadius: BorderRadius.circular(4)),
                      child: Text(level, style: const TextStyle(fontSize: 9, color: AppColors.primaryBlue, fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.star, size: 10, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(rating, style: const TextStyle(fontSize: 9, color: AppColors.textLight)),
                    const SizedBox(width: 6),
                    Text('• $hours', style: const TextStyle(fontSize: 9, color: AppColors.textLight)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(4)),
                child: Text(discount, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green)),
              ),
              const SizedBox(height: 4),
              Text(price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              Text(oldPrice, style: const TextStyle(fontSize: 10, color: AppColors.textLight, decoration: TextDecoration.lineThrough)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingResult(String title, String author, String date, String duration, String iconText) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(iconText, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.play_arrow, size: 10, color: Color(0xFF1A237E)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(author, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 10, color: AppColors.textLight),
                    const SizedBox(width: 4),
                    Text(date, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                  ],
                ),
              ],
            ),
          ),
          Text(duration, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _buildTeacherResult(String name, String role, String rating, String courses) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFF1A237E),
            child: Icon(Icons.person, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(role, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 12, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(rating, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                    const SizedBox(width: 8),
                    const Text('|', style: TextStyle(color: AppColors.border)),
                    const SizedBox(width: 8),
                    Text(courses, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                  ],
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primaryBlue),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              minimumSize: Size.zero,
            ),
            child: const Text('Follow', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
          ),
        ],
      ),
    );
  }
}
