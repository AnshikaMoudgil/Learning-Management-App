import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'home_dashboard.dart';
import 'live_classes_screen.dart';
import 'course_store_screen.dart';

class MyLearningScreen extends StatefulWidget {
  const MyLearningScreen({Key? key}) : super(key: key);

  @override
  State<MyLearningScreen> createState() => _MyLearningScreenState();
}

class _MyLearningScreenState extends State<MyLearningScreen> {
  int _selectedTab = 1; // "My Courses"
  
  // Filter States
  String _selectedStatus = 'In Progress';
  String _selectedCategory = 'Hardware-linked Courses';
  String _selectedSort = 'Recently accessed';

  void _onNavTapped(int index) {
    if (index == 1) return;
    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = const HomeDashboard();
        break;
      case 2:
        nextScreen = const LiveClassesScreen();
        break;
      case 3:
        nextScreen = const CourseStoreScreen();
        break;
      case 4:
        // Profile Screen (placeholder)
        nextScreen = const HomeDashboard();
        break;
      default:
        return;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => nextScreen));
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textDark),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              _selectedStatus = 'All';
                              _selectedCategory = 'All';
                              _selectedSort = 'Recently accessed';
                            });
                          },
                          child: const Text('Clear all', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  
                  // Filter Options
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _buildFilterExpansion(
                          title: '1. Status',
                          selectedValue: _selectedStatus,
                          options: ['All', 'In Progress', 'Completed', 'Not Started', 'Expiring Soon'],
                          onChanged: (val) => setModalState(() => _selectedStatus = val),
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: AppColors.border),
                        const SizedBox(height: 16),
                        
                        _buildFilterExpansion(
                          title: '2. Category',
                          selectedValue: _selectedCategory,
                          options: ['All', 'Software Courses', 'Hardware-linked Courses'],
                          onChanged: (val) => setModalState(() => _selectedCategory = val),
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: AppColors.border),
                        const SizedBox(height: 16),
                        
                        _buildFilterExpansion(
                          title: '3. Sort By',
                          selectedValue: _selectedSort,
                          options: ['Recently accessed', 'Name A - Z', 'Expiry date', 'Purchase date'],
                          onChanged: (val) => setModalState(() => _selectedSort = val),
                        ),
                      ],
                    ),
                  ),

                  // Apply Button
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        setState(() {}); // Update parent
                        Navigator.pop(context);
                      },
                      child: const Text('Apply Filters (2)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildFilterExpansion({
    required String title,
    required String selectedValue,
    required List<String> options,
    required Function(String) onChanged,
  }) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        initiallyExpanded: true,
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        children: options.map((option) {
          bool isSelected = selectedValue == option;
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primaryBlue : AppColors.textLight,
            ),
            title: Text(option, style: TextStyle(fontSize: 14, color: isSelected ? AppColors.textDark : AppColors.textLight, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            onTap: () => onChanged(option),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.menu, color: AppColors.textDark), onPressed: () {}),
        title: const Text('My Learning', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
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
                  child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center),
                ),
              )
            ],
          ),
          IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.textDark), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            padding: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTopTab('Continue Watching', 0),
                  _buildTopTab('My Courses', 1),
                  _buildTopTab('Live Classes', 2),
                  _buildTopTab('Recordings', 3),
                ],
              ),
            ),
          ),
          
          // Search and Filter
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.search, size: 18, color: AppColors.textLight),
                        SizedBox(width: 8),
                        Text('Search your courses...', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _showFilterModal,
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.primaryBlue),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.filter_list, size: 18, color: AppColors.primaryBlue),
                        SizedBox(width: 8),
                        Text('Filters', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Active Filters Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text('Active Filters', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const Spacer(),
                const Text('Clear all', style: TextStyle(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildActiveFilterChip(_selectedStatus),
                const SizedBox(width: 8),
                _buildActiveFilterChip(_selectedCategory),
                const SizedBox(width: 8),
                _buildActiveFilterChip('Sort by: $_selectedSort'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Courses List Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('4 Courses', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                Text('Recently accessed ▼', style: TextStyle(fontSize: 12, color: AppColors.textDark, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Courses List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildCourseItem(
                  title: 'Mobile IC Repair\nComplete Course',
                  progress: 0.65,
                  progressText: '65%',
                  lastAccessed: '2 days ago',
                  image: 'assets/iphone_hardware.png',
                  actionText: 'Continue Learning',
                  isCompleted: false,
                ),
                const SizedBox(height: 16),
                _buildCourseItem(
                  title: 'Android Phone\nRepair Mastery',
                  progress: 0.40,
                  progressText: '40%',
                  lastAccessed: '5 days ago',
                  image: 'assets/android_hardware.png',
                  actionText: 'Continue Learning',
                  isCompleted: false,
                ),
                const SizedBox(height: 16),
                _buildCourseItem(
                  title: 'Power Supply Repair\nTechniques',
                  progress: 0.20,
                  progressText: '20%',
                  lastAccessed: '1 week ago',
                  image: 'assets/iphone_software.png',
                  actionText: 'Continue Learning',
                  isCompleted: false,
                ),
                const SizedBox(height: 16),
                _buildCourseItem(
                  title: 'Laptop Chip Level\nRepair Techniques',
                  progress: 1.0,
                  progressText: 'Completed',
                  lastAccessed: '10 May 2025',
                  image: 'assets/android_hardware.png',
                  actionText: 'Review Course',
                  isCompleted: true,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Store'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildTopTab(String label, int index) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: isSelected ? AppColors.primaryBlue : Colors.transparent, width: 2)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.primaryBlue : AppColors.textLight,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightBlueBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          const Icon(Icons.close, size: 12, color: AppColors.primaryBlue),
        ],
      ),
    );
  }

  Widget _buildCourseItem({
    required String title,
    required double progress,
    required String progressText,
    required String lastAccessed,
    required String image,
    required String actionText,
    required bool isCompleted,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark))),
                    const Icon(Icons.favorite_border, size: 18, color: AppColors.textLight),
                  ],
                ),
                const SizedBox(height: 12),
                if (!isCompleted)
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                          minHeight: 4,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(progressText, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                    ],
                  ),
                if (isCompleted)
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 12),
                      const SizedBox(width: 4),
                      Text(progressText, style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                const SizedBox(height: 4),
                Text(isCompleted ? 'Completed on: $lastAccessed' : 'Last accessed: $lastAccessed', style: const TextStyle(fontSize: 9, color: AppColors.textLight)),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCompleted ? Colors.white : AppColors.primaryBlue,
                      foregroundColor: isCompleted ? AppColors.primaryBlue : Colors.white,
                      side: isCompleted ? const BorderSide(color: AppColors.primaryBlue) : null,
                      elevation: 0,
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {},
                    child: Text(actionText, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
