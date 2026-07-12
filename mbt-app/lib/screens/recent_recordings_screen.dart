import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'home_dashboard.dart';
import 'my_learning_screen.dart';
import 'live_classes_screen.dart';
import 'profile_screen.dart';
import 'package:go_router/go_router.dart';
import '../widgets/filter_bottom_sheet.dart';

class RecentRecordingsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> recordings;

  const RecentRecordingsScreen({
    super.key,
    this.recordings = const [], // Empty default
  });

  @override
  State<RecentRecordingsScreen> createState() => _RecentRecordingsScreenState();
}

class _RecentRecordingsScreenState extends State<RecentRecordingsScreen> {
  String _selectedCourse = 'All Courses';
  String _sortBy = 'Newest First';

  void _onNavTapped(int index) {
    if (index == 3) return; // Downloads/Recordings
    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = const HomeDashboard();
        break;
      case 1:
        nextScreen = const MyLearningScreen();
        break;
      case 2:
        nextScreen = const LiveClassesScreen();
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
        automaticallyImplyLeading: false,
        title: Column(
          children: const [
            Text('Recent Recordings', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Latest recordings across all your courses', style: TextStyle(color: AppColors.textLight, fontSize: 11)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.search, color: AppColors.textDark), onPressed: () => context.push('/search')),
          IconButton(icon: const Icon(Icons.filter_alt_outlined, color: AppColors.textDark), onPressed: () => FilterBottomSheet.show(context)),
        ],
      ),
      body: Column(
        children: [
          // Filter and Sort Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Course Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(_selectedCourse, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textDark),
                    ],
                  ),
                ),
                // Sort Dropdown
                Row(
                  children: [
                    const Text('Sort by: ', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                    Text(_sortBy, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textDark),
                  ],
                ),
              ],
            ),
          ),
          
          // Secure Streaming Banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.lightBlueBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Secure Streaming', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                      Text(
                        'All recordings are protected and available for streaming only. Downloading and screen recording are disabled.',
                        style: TextStyle(fontSize: 10, color: AppColors.textDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: widget.recordings.isEmpty ? _buildEmptyState() : _buildPopulatedState(),
          ),
        ],
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
              'assets/images/recent_recordings_empty.png',
              width: 200,
              height: 200,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.video_camera_front_outlined, size: 120, color: AppColors.primaryBlue);
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'No recordings yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "You don't have any recent recordings across\nyour enrolled courses.\nNew recordings will appear here once available.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textLight,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.search, color: Colors.white, size: 20),
                label: const Text(
                  'Explore Courses',
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
              onPressed: () {
                // Return and maybe go to My Courses tab
                context.pop();
              },
              child: const Text(
                'Go to My Courses >',
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
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: widget.recordings.length,
      separatorBuilder: (context, index) => const Divider(color: AppColors.border, height: 32),
      itemBuilder: (context, index) {
        return _buildRecordingCard(widget.recordings[index]);
      },
    );
  }

  Widget _buildRecordingCard(Map<String, dynamic> recording) {
    bool isWatched = recording['isWatched'] ?? false;
    bool isNew = recording['isNew'] ?? false;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Stack(
            children: [
              Container(
                width: 100,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade900,
                  image: recording['thumbnail'] != null
                      ? DecorationImage(
                          image: AssetImage(recording['thumbnail']),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withValues(alpha: 0.3),
                            BlendMode.darken,
                          ),
                        )
                      : null,
                ),
                child: const Center(
                  child: Icon(Icons.play_circle_fill, color: Colors.white, size: 28),
                ),
              ),
              if (isNew)
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                    child: const Text('New', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ),
              Positioned(
                bottom: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(4)),
                  child: Text(recording['duration'] ?? '0:00', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recording['courseName'] ?? '', style: const TextStyle(fontSize: 9, color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(recording['title'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark), maxLines: 2),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.remove_red_eye, size: 10, color: AppColors.textLight),
                    const SizedBox(width: 4),
                    Text('${recording['views'] ?? 0} views', style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                    const SizedBox(width: 12),
                    const Icon(Icons.calendar_today, size: 10, color: AppColors.textLight),
                    const SizedBox(width: 4),
                    Text('Uploaded on ${recording['date'] ?? ''}', style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                  ],
                ),
              ],
            ),
          ),
          // Action Area
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.play_arrow_outlined, color: AppColors.primaryBlue, size: 16),
              ),
              const SizedBox(height: 4),
              Text(
                isWatched ? 'Watch Again' : 'Watch Now',
                style: const TextStyle(fontSize: 9, color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
              ),
              if (isWatched) ...[
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Icon(Icons.check, size: 10, color: Colors.green),
                    SizedBox(width: 2),
                    Text('Watched', style: TextStyle(fontSize: 9, color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
