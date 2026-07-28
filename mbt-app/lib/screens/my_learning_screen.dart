import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../services/enrollment_provider.dart';
import '../services/enrollments_service.dart';
import '../services/notification_service.dart';
import '../utils/duration_formatter.dart';

class MyLearningScreen extends StatefulWidget {
  const MyLearningScreen({Key? key}) : super(key: key);

  @override
  State<MyLearningScreen> createState() => _MyLearningScreenState();
}

class _MyLearningScreenState extends State<MyLearningScreen> {
  bool _isGridView = true;
  String _selectedFilter = 'All Courses';
  String _selectedCategory = 'All Categories';
  String _selectedLevel = 'All Levels';
  final _enrollmentProvider = EnrollmentProvider();
  final NotificationService _notificationService = NotificationService();
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _enrollmentProvider.addListener(_onEnrollmentsChanged);
    _enrollmentProvider.refresh();
    _loadUnreadCount();
  }

  @override
  void dispose() {
    _enrollmentProvider.removeListener(_onEnrollmentsChanged);
    super.dispose();
  }

  void _onEnrollmentsChanged() {
    if (mounted) setState(() {});
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

  Future<void> _refreshEnrollments() async {
    await _enrollmentProvider.refresh();
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
                  GestureDetector(
                    onTap: () => _showFilterMenu(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Text(_selectedFilter, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textDark),
                        ],
                      ),
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
                  GestureDetector(
                    onTap: () => _showFilterSheet(),
                    child: Container(
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
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: _buildEnrollmentsContent(),
            ),
          ],
        ),
      ),
    );
  }

  List<EnrollmentItem> get _filteredEnrollments {
    final enrollments = _enrollmentProvider.enrollments;
    final now = DateTime.now();
    return enrollments.where((e) {
      final isExpired = e.status == 'expired' || (e.validityEndAt != null && e.validityEndAt!.isBefore(now));
      final isCompleted = e.progressPercent >= 100;
      if (_selectedFilter == 'In Progress' && (isExpired || isCompleted)) return false;
      if (_selectedFilter == 'Completed' && !isCompleted) return false;
      if (_selectedFilter == 'Expired' && !isExpired) return false;
      if (_selectedCategory != 'All Categories' && e.category != _selectedCategory) return false;
      if (_selectedLevel != 'All Levels' && e.level != _selectedLevel) return false;
      return true;
    }).toList();
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('Filter by Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            ...['All Courses', 'In Progress', 'Completed', 'Expired'].map(
              (option) => ListTile(
                leading: Icon(
                  _selectedFilter == option ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: _selectedFilter == option ? AppColors.primaryBlue : AppColors.textLight,
                  size: 20,
                ),
                title: Text(option, style: TextStyle(fontSize: 14, fontWeight: _selectedFilter == option ? FontWeight.bold : FontWeight.normal, color: AppColors.textDark)),
                onTap: () {
                  setState(() => _selectedFilter = option);
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    String localCategory = _selectedCategory;
    String localLevel = _selectedLevel;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Filter Courses', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    IconButton(icon: const Icon(Icons.close, color: AppColors.textLight), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDropdown('Category', localCategory, ['All Categories', 'Hardware', 'Software'], (val) => setSheetState(() => localCategory = val!)),
                const SizedBox(height: 16),
                _buildDropdown('Skill Level', localLevel, ['All Levels', 'Beginner', 'Intermediate', 'Advanced'], (val) => setSheetState(() => localLevel = val!)),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setSheetState(() {
                            localCategory = 'All Categories';
                            localLevel = 'All Levels';
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Reset', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = localCategory;
                            _selectedLevel = localLevel;
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textLight),
              items: items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item, style: const TextStyle(color: AppColors.textDark)));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnrollmentsContent() {
    if (!_enrollmentProvider.initialized) {
      return const Center(child: CircularProgressIndicator());
    }
    final enrollments = _filteredEnrollments;
    if (enrollments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school_outlined, size: 64, color: AppColors.textLight),
            const SizedBox(height: 16),
            Text(_enrollmentProvider.enrollments.isEmpty
                ? 'You are not enrolled in any courses yet'
                : 'No courses match the selected filter',
                style: const TextStyle(color: AppColors.textLight, fontSize: 14)),
            const SizedBox(height: 12),
            if (_enrollmentProvider.enrollments.isEmpty)
              ElevatedButton(
                onPressed: () => context.push('/store'),
                child: const Text('Explore Courses'),
              ),
          ],
        ),
      );
    }
    return _isGridView ? _buildGridView(enrollments) : _buildListView(enrollments);
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
        final now = DateTime.now();
        final isExpired = item.status == 'expired' || (item.validityEndAt != null && item.validityEndAt!.isBefore(now));

        String statusText;
        Color statusColor;

        if (isExpired) {
          statusText = 'Expired';
          statusColor = Colors.grey;
        } else if (item.progressPercent >= 100) {
          statusText = 'Completed';
          statusColor = Colors.green;
        } else {
          statusText = 'In Progress';
          statusColor = AppColors.primaryBlue;
        }

        return _buildGridCard(
          enrollment: item,
          isExpired: isExpired,
          statusText: statusText,
          statusColor: statusColor,
        );
      },
    );
  }

  Widget _buildGridCard({
    required EnrollmentItem enrollment,
    required bool isExpired,
    required String statusText,
    required Color statusColor,
  }) {
    final progress = enrollment.progressPercent / 100.0;
    return GestureDetector(
      onTap: isExpired ? null : () => context.push('/course-progress?id=${enrollment.courseId}'),
      child: Container(
        decoration: BoxDecoration(
          color: isExpired ? Colors.grey.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isExpired ? Colors.grey.shade300 : Colors.grey.shade200),
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
                  colorFilter: isExpired ? ColorFilter.mode(Colors.grey, BlendMode.saturation) : null,
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
                          Text(enrollment.estimatedDuration != null ? '${enrollment.estimatedDuration}hours' : 'Self-paced', style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
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
        final now = DateTime.now();
        final isExpired = item.status == 'expired' || (item.validityEndAt != null && item.validityEndAt!.isBefore(now));
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildListCard(enrollment: item, isExpired: isExpired),
        );
      },
    );
  }

  Widget _buildListCard({
    required EnrollmentItem enrollment,
    required bool isExpired,
  }) {
    final progress = enrollment.progressPercent / 100.0;
    return GestureDetector(
      onTap: isExpired ? null : () => context.push('/course-progress?id=${enrollment.courseId}'),
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
                onPressed: isExpired ? null : () => context.push('/course-progress?id=${enrollment.courseId}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isExpired ? Colors.grey.shade300 : AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  isExpired ? 'Expired' : 'Continue Learning',
                  style: TextStyle(
                    color: isExpired ? Colors.grey.shade500 : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
