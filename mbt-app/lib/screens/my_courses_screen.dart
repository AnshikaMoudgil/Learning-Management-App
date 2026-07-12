import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'home_dashboard.dart';
import 'live_classes_screen.dart';
import 'recent_recordings_screen.dart';
import 'profile_screen.dart';
import 'package:go_router/go_router.dart';

class MyCoursesScreen extends StatefulWidget {
  final List<Map<String, dynamic>> courses;

  const MyCoursesScreen({
    super.key,
    this.courses = const [], // Default empty to show empty state
  });

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _sortBy = 'Recently Accessed';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
        nextScreen = const RecentRecordingsScreen();
        break;
      case 4:
        nextScreen = const ProfileScreen();
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
        title: const Text(
          'My Courses',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textDark),
            onPressed: () {},
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: AppColors.textDark),
                onPressed: () {},
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.textDark,
          indicatorColor: Colors.transparent,
          dividerColor: Colors.transparent,
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryBlue),
            color: Colors.white,
          ),
          tabs: [
            _buildTab('All'),
            _buildTab('In Progress'),
            _buildTab('Completed'),
            _buildTab('Expiring Soon'),
          ],
        ),
      ),
      body: widget.courses.isEmpty ? _buildEmptyState() : _buildPopulatedState(),
      
    );
  }

  Widget _buildTab(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
              'assets/images/my_courses_empty.png',
              width: 250,
              height: 250,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.inventory_2_outlined, size: 120, color: AppColors.primaryBlue);
              },
            ),
            const SizedBox(height: 24),
            const Text(
              "You haven't purchased any courses yet",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Explore our courses and start your\nlearning journey today.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textLight,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                label: const Text(
                  'Explore Store',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: () {},
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Browse Free Content',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopulatedState() {
    return Column(
      children: [
        // Sort and Filter Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Sort by: ',
                    style: TextStyle(color: AppColors.textLight, fontSize: 13),
                  ),
                  DropdownButton<String>(
                    value: _sortBy,
                    icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textDark),
                    elevation: 16,
                    style: const TextStyle(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.bold),
                    underline: const SizedBox(),
                    onChanged: (String? value) {
                      setState(() {
                        _sortBy = value!;
                      });
                    },
                    items: ['Recently Accessed', 'Newest First', 'A-Z']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.tune, color: AppColors.textLight, size: 20),
                onPressed: () {},
              ),
            ],
          ),
        ),
        const Divider(color: AppColors.border, height: 1),
        // List of Courses
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: widget.courses.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildCourseCard(widget.courses[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    bool isCompleted = (course['progress'] ?? 0) >= 1.0;
    
    return Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade900,
                  image: course['thumbnail'] != null
                      ? DecorationImage(
                          image: AssetImage(course['thumbnail']),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withValues(alpha: 0.3),
                            BlendMode.darken,
                          ),
                        )
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isCompleted ? Colors.green : AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isCompleted ? 'Completed' : 'In Progress',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            course['title'] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.more_vert, color: AppColors.textLight, size: 20),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${course['lessonsCount'] ?? 0} Lessons',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Progress
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: course['progress'] ?? 0.0,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                isCompleted ? Colors.green : AppColors.primaryBlue),
                            minHeight: 4,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${((course['progress'] ?? 0) * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Validity
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textLight),
                        const SizedBox(width: 4),
                        Text(
                          isCompleted
                              ? 'Completed on ${course['completedDate']}'
                              : 'Valid for ${course['validDays']} days',
                          style: TextStyle(
                            fontSize: 10,
                            color: isCompleted ? Colors.green : AppColors.textLight,
                          ),
                        ),
                        const Spacer(),
                        if (!isCompleted)
                          Text(
                            '${course['daysLeft']} days left',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: (course['daysLeft'] ?? 99) < 20 ? Colors.red : Colors.green,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Action Button
          SizedBox(
            width: double.infinity,
            height: 36,
            child: isCompleted
                ? OutlinedButton.icon(
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Review Again'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: const BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {},
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Continue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        SizedBox(width: 4),
                        Icon(Icons.play_arrow_outlined, size: 16),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
