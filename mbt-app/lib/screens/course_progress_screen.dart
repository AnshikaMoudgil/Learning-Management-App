import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../services/my_course_service.dart';
import '../services/enrollments_service.dart';

class CourseProgressScreen extends StatefulWidget {
  final String? courseId;
  const CourseProgressScreen({Key? key, this.courseId}) : super(key: key);

  @override
  State<CourseProgressScreen> createState() => _CourseProgressScreenState();
}

class _CourseProgressScreenState extends State<CourseProgressScreen> {
  final _myCourseService = MyCourseService();
  final _enrollmentsService = EnrollmentsService();
  
  bool _isLoading = true;
  String? _error;
  
  String? _activeCourseId;
  MyCourseContent? _courseContent;
  EnrollmentItem? _activeEnrollment;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (widget.courseId == null) {
        // Fetch enrollments to get a default course
        final enrollments = await _enrollmentsService.getMyEnrollments();
        if (enrollments.isEmpty) {
          setState(() {
            _activeCourseId = null;
            _isLoading = false;
          });
          return;
        } else {
          _activeEnrollment = enrollments.first;
          _activeCourseId = _activeEnrollment!.courseId;
        }
      } else {
        _activeCourseId = widget.courseId;
        // Optionally fetch specific enrollment to get instructorName
        final enrollments = await _enrollmentsService.getMyEnrollments();
        try {
          _activeEnrollment = enrollments.firstWhere((e) => e.courseId == _activeCourseId);
        } catch (_) {}
      }

      _courseContent = await _myCourseService.getCourseContent(_activeCourseId!);
    } catch (e) {
      _error = 'Failed to load progress data.';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Course Progress',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            )
          ],
        ),
      );
    }

    if (_activeCourseId == null || _courseContent == null) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCourseHeader(),
          const SizedBox(height: 24),
          _buildOverallProgress(),
          const SizedBox(height: 24),
          _buildModulesList(),
          const SizedBox(height: 24),
          if (_courseContent!.enrollment.progressPercent == 100)
            _buildCertificateBanner(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder for the empty state image
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.lightBlueBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_mosaic, size: 80, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Courses Yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            const Text(
              "You haven't enrolled in any courses.\nStart your learning journey today!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textLight, height: 1.4),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/store'), // Assuming store is the explore path
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Explore Courses', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go('/store'),
              child: const Text('Browse Free Content >', style: TextStyle(color: AppColors.primaryBlue, fontSize: 14, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCourseHeader() {
    final title = _courseContent!.title;
    final instructor = _activeEnrollment?.instructorName ?? 'Mr. Ankit Verma';
    final imageUrl = _courseContent!.thumbnailUrl ?? _activeEnrollment?.thumbnailUrl;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 80,
              height: 80,
              color: AppColors.border,
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(imageUrl, fit: BoxFit.cover)
                  : Image.asset('assets/iphone_hardware.png', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Instructor: $instructor',
                  style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 12),
                      const SizedBox(width: 4),
                      const Text('Premium', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOverallProgress() {
    final progress = _courseContent!.enrollment.progressPercent;
    final totalLessons = _courseContent!.sections.fold<int>(0, (sum, sec) => sum + sec.totalLessons);
    final completedLessons = _courseContent!.sections.fold<int>(0, (sum, sec) => sum + sec.completedLessons);
    final remainingModules = _courseContent!.sections.where((s) => s.progressPercent < 100).length;

    final isCompleted = progress == 100;
    final progressColor = isCompleted ? Colors.green : AppColors.primaryBlue;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: progress / 100.0,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$progress%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark)),
                  const Text('Complete', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                ],
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Overall Progress', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  isCompleted ? 'Outstanding! 🎉' : "You're doing great! Keep it up!",
                  style: TextStyle(
                    fontSize: 13,
                    color: isCompleted ? Colors.green : AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress / 100.0,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
                const SizedBox(height: 8),
                Text('$completedLessons / $totalLessons Lessons Completed', style: const TextStyle(fontSize: 11, color: AppColors.textDark, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green.withValues(alpha: 0.1) : AppColors.lightBlueBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(isCompleted ? Icons.emoji_events : Icons.emoji_events_outlined, color: progressColor, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isCompleted
                              ? "Congratulations! You've completed the entire course."
                              : "Complete remaining $remainingModules modules to unlock your certificate.",
                          style: TextStyle(fontSize: 10, color: AppColors.textDark),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModulesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Course Modules', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _courseContent!.sections.length,
          separatorBuilder: (context, index) => const Divider(height: 24, color: AppColors.border),
          itemBuilder: (context, index) {
            final section = _courseContent!.sections[index];
            final isCompleted = section.progressPercent == 100;
            final isLocked = !section.isUnlocked;
            
            IconData statusIcon;
            Color iconColor;
            if (isCompleted) {
              statusIcon = Icons.check_circle;
              iconColor = Colors.green;
            } else if (isLocked) {
              statusIcon = Icons.lock;
              iconColor = AppColors.textLight;
            } else {
              statusIcon = Icons.play_circle;
              iconColor = AppColors.primaryBlue;
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(statusIcon, color: iconColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}. ${section.title}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${section.completedLessons} / ${section.totalLessons} Lessons',
                        style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: section.progressPercent / 100.0,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(isCompleted ? Colors.green : AppColors.primaryBlue),
                              minHeight: 4,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${section.progressPercent}%',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.keyboard_arrow_down, color: AppColors.textLight, size: 20),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildCertificateBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.workspace_premium, color: Colors.green, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Certificate Unlocked', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                const SizedBox(height: 4),
                const Text("You're eligible for your certificate.", style: TextStyle(fontSize: 12, color: AppColors.textDark)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to certificate view
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Certificate...')));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 36),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('View Certificate', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
