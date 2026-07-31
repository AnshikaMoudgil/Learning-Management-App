import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/enrollments_service.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';

class ExpiringCoursesScreen extends StatefulWidget {
  const ExpiringCoursesScreen({super.key});

  @override
  State<ExpiringCoursesScreen> createState() => _ExpiringCoursesScreenState();
}

class _ExpiringCoursesScreenState extends State<ExpiringCoursesScreen> {
  final EnrollmentsService _enrollmentsService = EnrollmentsService();

  bool _isLoading = true;
  List<EnrollmentItem> _expiringSoon = [];
  List<EnrollmentItem> _alreadyExpired = [];

  @override
  void initState() {
    super.initState();
    _loadEnrollments();
  }

  Future<void> _loadEnrollments() async {
    try {
      final enrollments = await _enrollmentsService.getMyEnrollments();
      final now = DateTime.now();
      final expiringSoon = <EnrollmentItem>[];
      final alreadyExpired = <EnrollmentItem>[];

      for (final e in enrollments) {
        if (e.validityEndAt == null) continue;
        if (e.validityEndAt!.isBefore(now)) {
          alreadyExpired.add(e);
        } else if (e.validityEndAt!.difference(now).inDays <= 30) {
          expiringSoon.add(e);
        }
      }

      expiringSoon.sort((a, b) => a.validityEndAt!.compareTo(b.validityEndAt!));
      alreadyExpired.sort((a, b) => b.validityEndAt!.compareTo(a.validityEndAt!));

      if (mounted) {
        setState(() {
          _expiringSoon = expiringSoon;
          _alreadyExpired = alreadyExpired;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool get _isEmpty => _expiringSoon.isEmpty && _alreadyExpired.isEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
        title: const Text('Expiring Courses', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppColors.textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isEmpty
              ? _buildEmptyState()
              : _buildPopulatedState(),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("You're all set!", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                    Text("None of your courses are expiring soon.", style: TextStyle(fontSize: 12, color: Colors.green)),
                  ],
                ),
              ),
              const Icon(Icons.calendar_month, color: Colors.green, size: 32),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/no_expiring_courses.png',
                    width: 250,
                    height: 250,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.event_available, size: 120, color: Colors.green);
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No Courses Expiring Soon',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'All your enrolled courses are valid.\nKeep learning and growing!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.textLight, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                      label: const Text('Explore More Courses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                onPressed: () => context.go(RouteNames.store),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPopulatedState() {
    final allCourses = [..._expiringSoon, ..._alreadyExpired];
    final hasExpiringSoon = _expiringSoon.isNotEmpty;
    final hasAlreadyExpired = _alreadyExpired.isNotEmpty;
    final minDays = _expiringSoon.isNotEmpty
        ? DateTime.now().difference(_expiringSoon.first.validityEndAt!).inDays.abs()
        : 999;
    final isUrgent = _expiringSoon.isNotEmpty && minDays < 3;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isUrgent ? Colors.red.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(isUrgent ? Icons.warning_amber_rounded : Icons.access_time,
                  color: isUrgent ? Colors.red : Colors.orange, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isUrgent ? 'Action Required!' : "Don't lose access!",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                            color: isUrgent ? Colors.red : Colors.orange)),
                    const SizedBox(height: 4),
                    Text(
                      isUrgent
                          ? 'Your course is expiring soon. Renew now to avoid\nlosing access.'
                          : 'Renew before your course expires to keep learning\nseamlessly.',
                      style: TextStyle(fontSize: 11, color: isUrgent ? Colors.red : Colors.orange),
                    ),
                  ],
                ),
              ),
              Icon(isUrgent ? Icons.notifications_active : Icons.calendar_today,
                  color: (isUrgent ? Colors.red : Colors.orange).withValues(alpha: 0.5), size: 40),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Showing ${allCourses.length} courses',
                  style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
              Row(
                children: const [
                  Text('Sort by: ', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                  Text('Soonest Expiring',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textDark),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            children: [
              if (hasExpiringSoon) ...[
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text('Expiring Soon',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                ),
                ..._expiringSoon.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildCourseCard(e, isExpired: false),
                    )),
              ],
              if (hasAlreadyExpired) ...[
                const Padding(
                  padding: EdgeInsets.only(bottom: 12, top: 8),
                  child: Text('Already Expired',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                ),
                ..._alreadyExpired.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildCourseCard(e, isExpired: true),
                    )),
              ],
            ],
          ),
        ),

        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightBlueBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Why renew?',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                    SizedBox(height: 4),
                    Text('Renew your course to continue learning without interruption\nand retain your progress.',
                        style: TextStyle(fontSize: 11, color: AppColors.textDark, height: 1.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCourseCard(EnrollmentItem course, {required bool isExpired}) {
    final daysLeft = isExpired
        ? 0
        : course.validityEndAt != null
            ? DateTime.now().difference(course.validityEndAt!).inDays.abs()
            : 0;
    final isUrgent = !isExpired && daysLeft < 3;
    final badgeColor = isExpired ? Colors.red : (isUrgent ? Colors.red : Colors.orange);
    final buttonColor = isExpired ? Colors.red : (isUrgent ? Colors.red : AppColors.primaryBlue);
    final daysText = isExpired ? 'Expired' : 'Expires in $daysLeft day${daysLeft > 1 ? 's' : ''}!';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade900,
                      image: course.thumbnailUrl != null
                          ? DecorationImage(
                              image: course.thumbnailUrl!.startsWith('http')
                                  ? NetworkImage(course.thumbnailUrl!) as ImageProvider
                                  : AssetImage(course.thumbnailUrl!) as ImageProvider,
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        daysText,
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title ?? '',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.star, color: Colors.orange, size: 10),
                          SizedBox(width: 4),
                          Text('Premium', style: TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Expiry Date', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textDark),
                        const SizedBox(width: 6),
                        Text(
                          course.validityEndAt != null
                              ? '${course.validityEndAt!.day}/${course.validityEndAt!.month}/${course.validityEndAt!.year}'
                              : '',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isExpired ? 'Expired' : '$daysLeft day${daysLeft > 1 ? 's' : ''} remaining',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: badgeColor),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                  minimumSize: const Size(0, 36),
                ),
                onPressed: () => context.push('${RouteNames.renewCourse}?courseId=${course.courseId}&enrollmentId=${course.enrollmentId}'),
                child: Text(
                  isExpired ? 'Renew Access' : 'Renew Now',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
