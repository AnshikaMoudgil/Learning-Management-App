import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ExpiringCoursesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> courses;

  const ExpiringCoursesScreen({
    super.key,
    this.courses = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
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
      body: courses.isEmpty ? _buildEmptyState() : _buildPopulatedState(context),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        // Success Banner
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
                      onPressed: () {},
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

  Widget _buildPopulatedState(BuildContext context) {
    // Determine the most urgent course for the banner
    int minDays = 999;
    for (var c in courses) {
      if ((c['daysLeft'] ?? 999) < minDays) {
        minDays = c['daysLeft'];
      }
    }

    bool isUrgent = minDays < 3;
    Color bannerColor = isUrgent ? Colors.red : Colors.orange;
    Color bannerBg = isUrgent ? Colors.red.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1);
    IconData bannerIcon = isUrgent ? Icons.warning_amber_rounded : Icons.access_time;
    String bannerTitle = isUrgent ? 'Action Required!' : "Don't lose access!";
    String bannerSubtitle = isUrgent
        ? 'Your course is expiring soon. Renew now to avoid\nlosing access.'
        : 'Renew before your course expires to keep learning\nseamlessly.';
    IconData bannerRightIcon = isUrgent ? Icons.notifications_active : Icons.calendar_today;

    return Column(
      children: [
        // Alert Banner
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bannerBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(bannerIcon, color: bannerColor, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bannerTitle, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: bannerColor)),
                    const SizedBox(height: 4),
                    Text(bannerSubtitle, style: TextStyle(fontSize: 11, color: bannerColor)),
                  ],
                ),
              ),
              Icon(bannerRightIcon, color: bannerColor.withValues(alpha: 0.5), size: 40),
            ],
          ),
        ),

        // Sort Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Showing ${courses.length} courses', style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
              Row(
                children: const [
                  Text('Sort by: ', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                  Text('Soonest Expiring', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textDark),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Course List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: courses.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildCourseCard(courses[index]);
            },
          ),
        ),

        // Info Banner at Bottom
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
                    Text('Why renew?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                    SizedBox(height: 4),
                    Text('Renew your course to continue learning without interruption\nand retain your progress.', style: TextStyle(fontSize: 11, color: AppColors.textDark, height: 1.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    int daysLeft = course['daysLeft'] ?? 0;
    bool isUrgent = daysLeft < 3;
    Color badgeColor = isUrgent ? Colors.red : Colors.orange;
    Color buttonColor = isUrgent ? Colors.red : AppColors.primaryBlue;

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
              // Thumbnail
              Stack(
                children: [
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
                        'Expires in $daysLeft day${daysLeft > 1 ? 's' : ''}!',
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course['title'] ?? '',
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
                        Text(course['expiryDate'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
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
          // Action Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$daysLeft day${daysLeft > 1 ? 's' : ''} remaining',
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
                onPressed: () {},
                child: const Text('Renew Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
