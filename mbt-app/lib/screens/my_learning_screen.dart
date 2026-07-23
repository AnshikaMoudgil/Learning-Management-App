import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../services/enrollments_service.dart';
import '../services/notification_service.dart';

class MyLearningScreen extends StatefulWidget {
  const MyLearningScreen({Key? key}) : super(key: key);

  @override
  State<MyLearningScreen> createState() => _MyLearningScreenState();
}

class _MyLearningScreenState extends State<MyLearningScreen> {
  bool _isGridView = true;
  late Future<List<EnrollmentItem>> _enrollmentsFuture;
  final _enrollmentsService = EnrollmentsService();
  final NotificationService _notificationService = NotificationService();
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _enrollmentsFuture = _enrollmentsService.getMyEnrollments();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final count = await _notificationService.getUnreadCount();
    if (mounted) setState(() => _unreadNotifications = count);
  }

  Future<void> _openNotifications() async {
    await context.push('/notifications');
    await _notificationService.markAllRead();
    _loadUnreadCount();
  }

  void _refreshEnrollments() {
    setState(() {
      _enrollmentsFuture = _enrollmentsService.getMyEnrollments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          _buildIconBadge(Icons.notifications_outlined, '$_unreadNotifications', Colors.red, _openNotifications),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshEnrollments(),
        child: Column(
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
              child: FutureBuilder<List<EnrollmentItem>>(
                future: _enrollmentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Failed to load courses: ${snapshot.error}', style: const TextStyle(color: AppColors.textLight)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _refreshEnrollments,
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    );
                  }
                  final enrollments = snapshot.data ?? [];
                  if (enrollments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.school_outlined, size: 64, color: AppColors.textLight),
                          const SizedBox(height: 16),
                          const Text('You are not enrolled in any courses yet', style: TextStyle(color: AppColors.textLight, fontSize: 14)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => context.push('/store'),
                            child: const Text('Explore Courses'),
                          ),
                        ],
                      ),
                    );
                  }

                  return _isGridView ? _buildGridView(enrollments) : _buildListView(enrollments);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBadge(IconData icon, String count, Color badgeColor, VoidCallback onTap) {
    final showBadge = count != '0' && count.isNotEmpty;
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(icon: Icon(icon, color: AppColors.textDark), onPressed: onTap),
        if (showBadge)
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

  Widget _buildGridView(List<EnrollmentItem> enrollments) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: enrollments.length,
      itemBuilder: (context, index) {
        final item = enrollments[index];
        final isCompleted = item.progressPercent >= 100;
        final statusColor = isCompleted ? Colors.green : AppColors.primaryBlue;
        final statusText = isCompleted ? 'Completed' : 'In Progress';

        return _buildGridCard(
          enrollment: item,
          statusText: statusText,
          statusColor: statusColor,
        );
      },
    );
  }

  Widget _buildGridCard({
    required EnrollmentItem enrollment,
    required String statusText,
    required Color statusColor,
  }) {
    final progress = enrollment.progressPercent / 100.0;
    return GestureDetector(
      onTap: () => context.push('/course-progress?id=${enrollment.courseId}'),
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
                image: DecorationImage(
                  image: enrollment.thumbnailUrl != null
                      ? NetworkImage(enrollment.thumbnailUrl!) as ImageProvider
                      : const AssetImage('assets/iphone_hardware.png'),
                  fit: BoxFit.cover,
                ),
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
                ],
              ),
            ),
            // Details Area
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(enrollment.title ?? 'Course Title', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textDark), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(enrollment.instructorName ?? 'MBT Instructor', style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
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
                      Text('${enrollment.progressPercent}%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
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
                          Text(enrollment.estimatedDuration ?? 'Self-paced', style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                        ],
                      ),
                      Container(width: 1, height: 10, color: Colors.grey.shade300),
                      Row(
                        children: [
                          const Icon(Icons.play_circle_outline, size: 12, color: AppColors.textLight),
                          const SizedBox(width: 4),
                          Text('${enrollment.totalLessons} Lessons', style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
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

  Widget _buildListView(List<EnrollmentItem> enrollments) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: enrollments.length,
      itemBuilder: (context, index) {
        final item = enrollments[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildListCard(enrollment: item),
        );
      },
    );
  }

  Widget _buildListCard({
    required EnrollmentItem enrollment,
  }) {
    final progress = enrollment.progressPercent / 100.0;
    return GestureDetector(
      onTap: () => context.push('/course-progress?id=${enrollment.courseId}'),
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
                    image: DecorationImage(
                      image: enrollment.thumbnailUrl != null
                          ? NetworkImage(enrollment.thumbnailUrl!) as ImageProvider
                          : const AssetImage('assets/iphone_hardware.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(enrollment.title ?? 'Course Title', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
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
                          Text('${enrollment.progressPercent}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textLight)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Instructor: ${enrollment.instructorName ?? 'MBT Instructor'}', style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/course-progress?id=${enrollment.courseId}'),
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
