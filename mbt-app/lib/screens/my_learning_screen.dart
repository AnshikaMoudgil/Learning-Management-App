import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class MyLearningScreen extends StatefulWidget {
  const MyLearningScreen({Key? key}) : super(key: key);

  @override
  State<MyLearningScreen> createState() => _MyLearningScreenState();
}

class _MyLearningScreenState extends State<MyLearningScreen> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: 70,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('My Learning', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 22)),
              SizedBox(height: 4),
              Text('All your enrolled courses in one place', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
            ],
          ),
          actions: [
            IconButton(icon: const Icon(Icons.search, color: AppColors.textDark), onPressed: () => context.push('/search')),
            _buildIconBadge(Icons.notifications_outlined, '3', Colors.red, () => context.push('/notifications')),
            const SizedBox(width: 16),
          ],
          bottom: const TabBar(
            labelColor: AppColors.primaryBlue,
            unselectedLabelColor: AppColors.textLight,
            indicatorColor: AppColors.primaryBlue,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: [
              Tab(text: 'Enrolled Courses'),
              Tab(text: 'Wishlist'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Controls Row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: const [
                        Text('All Courses', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textDark),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _isGridView = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _isGridView ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: _isGridView ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : null,
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.grid_view, size: 14, color: _isGridView ? AppColors.primaryBlue : AppColors.textLight),
                                const SizedBox(width: 4),
                                Text('Grid', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _isGridView ? AppColors.primaryBlue : AppColors.textLight)),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _isGridView = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: !_isGridView ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: !_isGridView ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : null,
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.view_list, size: 14, color: !_isGridView ? AppColors.primaryBlue : AppColors.textLight),
                                const SizedBox(width: 4),
                                Text('List', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: !_isGridView ? AppColors.primaryBlue : AppColors.textLight)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: const [
                        Icon(Icons.filter_list, size: 16, color: AppColors.textDark),
                        SizedBox(width: 4),
                        Text('Filter', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Stack(
                children: [
                  TabBarView(
                    children: [
                      // Enrolled Courses Tab
                      _isGridView ? _buildGridView() : _buildListView(),
                      // Wishlist Tab
                      const Center(child: Text('Wishlist Empty', style: TextStyle(color: AppColors.textLight))),
                    ],
                  ),
                  // Floating Banner
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.school, color: AppColors.primaryBlue, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Keep learning, keep growing!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textDark)),
                                SizedBox(height: 4),
                                Text('Complete your courses and earn your certificate.', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () => context.push('/certificates'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primaryBlue),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.workspace_premium, size: 14, color: AppColors.primaryBlue),
                                SizedBox(width: 4),
                                Text('View Certificates', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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

  Widget _buildGridView() {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.75,
      children: [
        _buildGridCard(
          image: 'assets/iphone_hardware.png',
          statusText: 'In Progress',
          statusColor: AppColors.primaryBlue,
          title: 'iPhone Hardware Complete Course',
          subtitle: 'iPhone Repair Course',
          progress: 0.65,
          progressText: '65%',
          timeText: '42h 30m',
          lessonsText: '28 Lessons',
        ),
        _buildGridCard(
          image: 'assets/iphone_software.png',
          statusText: 'In Progress',
          statusColor: AppColors.primaryBlue,
          title: 'iPhone Software Mastery',
          subtitle: 'iPhone Repair Course',
          progress: 0.40,
          progressText: '40%',
          timeText: '36h 15m',
          lessonsText: '24 Lessons',
        ),
        _buildGridCard(
          image: 'assets/android_hardware.png',
          statusText: 'Not Started',
          statusColor: Colors.grey.shade700,
          title: 'Android Hardware Fundamentals',
          subtitle: 'Android Repair Course',
          progress: 0.0,
          progressText: '0%',
          timeText: '28h 00m',
          lessonsText: '20 Lessons',
        ),
        _buildGridCard(
          image: 'assets/iphone_hardware.png', // Placeholder
          statusText: 'Completed',
          statusColor: Colors.green,
          title: 'Laptop Chip Level Repairing',
          subtitle: 'Advanced Repair Course',
          progress: 1.0,
          progressText: '100%',
          timeText: '45h 20m',
          lessonsText: '30 Lessons',
        ),
      ],
    );
  }

  Widget _buildGridCard({
    required String image,
    required String statusText,
    required Color statusColor,
    required String title,
    required String subtitle,
    required double progress,
    required String progressText,
    required String timeText,
    required String lessonsText,
  }) {
    return GestureDetector(
      onTap: () => context.push('/course-progress'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Area
            Container(
              height: 90,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(12)),
                      child: Text(statusText, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.more_vert, size: 12, color: AppColors.textDark),
                    ),
                  ),
                ],
              ),
            ),
            // Details Area
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textDark), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                  const SizedBox(height: 12),
                  // Progress Bar
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                          minHeight: 4,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(progressText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Footer Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 12, color: AppColors.textLight),
                          const SizedBox(width: 4),
                          Text(timeText, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                        ],
                      ),
                      Container(width: 1, height: 10, color: Colors.grey.shade300),
                      Row(
                        children: [
                          const Icon(Icons.play_circle_outline, size: 12, color: AppColors.textLight),
                          const SizedBox(width: 4),
                          Text(lessonsText, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      children: [
        _buildListCard(
          image: 'assets/iphone_hardware.png',
          title: 'Mobile IC Repair Complete Course',
          progress: 0.65,
          progressText: '65%',
          lastAccessed: '2 days ago',
        ),
        const SizedBox(height: 16),
        _buildListCard(
          image: 'assets/iphone_software.png',
          title: 'Android Phone Repair Mastery',
          progress: 0.40,
          progressText: '40%',
          lastAccessed: '5 days ago',
        ),
      ],
    );
  }

  Widget _buildListCard({
    required String image,
    required String title,
    required double progress,
    required String progressText,
    required String lastAccessed,
  }) {
    return GestureDetector(
      onTap: () => context.push('/course-progress'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Row(
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
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark))),
                          const SizedBox(width: 8),
                          const Icon(Icons.favorite_border, color: Colors.grey, size: 20),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                              minHeight: 4,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(progressText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textLight)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Last accessed: $lastAccessed', style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/course-progress'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Continue Learning', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
