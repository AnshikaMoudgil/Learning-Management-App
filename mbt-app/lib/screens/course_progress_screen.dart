import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CourseProgressScreen extends StatelessWidget {
  final Map<String, dynamic>? course;

  const CourseProgressScreen({
    super.key,
    this.course, // If null or progress == 0, show empty state
  });

  @override
  Widget build(BuildContext context) {
    bool hasCourse = course != null;
    double progress = hasCourse ? (course!['progress'] ?? 0.0) : 0.0;
    bool isCompleted = progress >= 1.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Course Progress', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: !hasCourse ? _buildEmptyState(context) : _buildPopulatedState(context, isCompleted, progress),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/course_progress_empty.png',
              width: 250,
              height: 250,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.analytics_outlined, size: 120, color: AppColors.primaryBlue);
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'No Courses Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "You haven't enrolled in any courses.\nStart your learning journey today!",
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
                  'Explore Courses',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Browse Free Content', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 14)),
                  Icon(Icons.chevron_right, color: AppColors.primaryBlue, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopulatedState(BuildContext context, bool isCompleted, double progress) {
    final Color progressColor = isCompleted ? Colors.green : AppColors.primaryBlue;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade900,
                  image: course!['thumbnail'] != null
                      ? DecorationImage(
                          image: AssetImage(course!['thumbnail']),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course!['title'] ?? 'Course Title',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 8),
                    Text('Instructor: ${course!['instructor'] ?? 'Unknown'}', style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
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
                          Icon(Icons.star, color: Colors.orange, size: 12),
                          SizedBox(width: 4),
                          Text('Premium', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Progress Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        Text(isCompleted ? 'Complete' : 'Complete', style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Overall Progress', style: TextStyle(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(
                        isCompleted ? 'Outstanding! 🎉' : "You're doing great! Keep it up!",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: progressColor),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 4,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: progressColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('${course!['completedLessons'] ?? 0} / ${course!['totalLessons'] ?? 0} Lessons Completed', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!isCompleted) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.lightBlueBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.emoji_events, color: AppColors.primaryBlue, size: 16),
                  SizedBox(width: 8),
                  Expanded(child: Text('Complete remaining modules to unlock your certificate.', style: TextStyle(fontSize: 10, color: AppColors.primaryBlue))),
                ],
              ),
            ),
          ],
          if (isCompleted) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.emoji_events, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Expanded(child: Text('Congratulations! You\'ve completed the entire course.', style: TextStyle(fontSize: 10, color: Colors.green))),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          // Live Session Attendance
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.cast, color: AppColors.primaryBlue, size: 16),
                        SizedBox(width: 8),
                        Text('Live Session Attendance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      ],
                    ),
                    const Row(
                      children: [
                        Text('View Details', style: TextStyle(fontSize: 11, color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                        Icon(Icons.chevron_right, size: 16, color: AppColors.primaryBlue),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol('${course!['totalSessions'] ?? 0}', 'Total Sessions'),
                    _buildStatCol('${course!['attendedSessions'] ?? 0}', 'Attended'),
                    _buildStatCol('${course!['missedSessions'] ?? 0}', 'Missed'),
                    _buildStatCol('${course!['attendancePercent'] ?? 0}%', 'Attendance'),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text('Course Modules', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 16),

          // Modules List
          if (course!['modules'] != null)
            ...((course!['modules'] as List).map((mod) => _buildModuleTile(mod)).toList()),

          if (isCompleted) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.workspace_premium, color: Colors.green, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Certificate Unlocked', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                        const Text("You're eligible for your certificate.", style: TextStyle(fontSize: 12, color: Colors.green)),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.download, size: 14),
                          label: const Text('View Certificate', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            minimumSize: const Size(0, 32),
                            elevation: 0,
                          ),
                          onPressed: () {},
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildStatCol(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
      ],
    );
  }

  Widget _buildModuleTile(Map<String, dynamic> module) {
    double modProgress = module['progress'] ?? 0.0;
    bool modCompleted = modProgress >= 1.0;
    bool modLocked = module['locked'] ?? false;

    IconData icon;
    Color iconColor;
    if (modLocked) {
      icon = Icons.lock;
      iconColor = AppColors.textLight;
    } else if (modCompleted) {
      icon = Icons.check_circle;
      iconColor = Colors.green;
    } else {
      icon = Icons.play_circle_fill;
      iconColor = AppColors.primaryBlue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Icon(icon, color: iconColor),
          title: Text(
            module['title'] ?? 'Module',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: modLocked ? AppColors.textLight : AppColors.textDark,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text('${module['completedLessons'] ?? 0} / ${module['totalLessons'] ?? 0} Lessons', style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: modProgress,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(modCompleted ? Colors.green : AppColors.primaryBlue),
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${(modProgress * 100).toInt()}%', style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                ],
              ),
            ],
          ),
          children: const [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Module lessons list goes here.', style: TextStyle(color: AppColors.textLight)),
            )
          ],
        ),
      ),
    );
  }
}
