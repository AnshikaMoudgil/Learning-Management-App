import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ContinueWatchingScreen extends StatelessWidget {
  final List<Map<String, dynamic>> inProgressCourses;

  const ContinueWatchingScreen({
    Key? key,
    this.inProgressCourses = const [],
  }) : super(key: key);

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
        title: const Text(
          'Continue Watching',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined, color: AppColors.textDark),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Pick up where you left off',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textLight,
              ),
            ),
          ),
        ),
      ),
      body: inProgressCourses.isEmpty ? _buildEmptyState() : _buildListState(),
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
              'assets/images/clapperboard_empty.png',
              width: 200,
              height: 200,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.movie_creation_outlined,
                  size: 150,
                  color: AppColors.primaryBlue,
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Nothing in progress yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'You haven\'t started any lessons yet.\nStart a course and your in-progress\nlessons will appear here.',
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
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  'Explore Courses',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.explore_outlined, color: AppColors.primaryBlue),
              label: const Text(
                'Browse All Courses',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListState() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'In Progress (${inProgressCourses.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Row(
                children: const [
                  Text(
                    'Most Recently Watched',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.primaryBlue),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: inProgressCourses.length,
              itemBuilder: (context, index) {
                final course = inProgressCourses[index];
                return _buildCourseCard(course);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Container(
            width: 100,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(8),
              image: course['thumbnail'] != null
                  ? DecorationImage(
                      image: NetworkImage(course['thumbnail']),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['courseName'] ?? 'Course Name',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  course['lessonTitle'] ?? 'Lesson Title',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  course['lessonSubtitle'] ?? 'Subtitle',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: AppColors.textLight),
                    const SizedBox(width: 4),
                    Text(
                      '${course['timeRemaining'] ?? 0}m remaining',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textLight,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(course['progress'] ?? 0) * 100}%',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: course['progress'] ?? 0.0,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Play Button Outline
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.play_arrow_outlined, color: AppColors.primaryBlue, size: 20),
          ),
        ],
      ),
    );
  }
}
