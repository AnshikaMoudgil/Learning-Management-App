import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import '../services/profile_service.dart';
import '../models/profile.dart';
import 'my_courses_screen.dart';
import 'live_classes_screen.dart';
import 'recent_recordings_screen.dart';
import 'profile_screen.dart';
import 'course_progress_screen.dart';
import 'expiring_courses_screen.dart';
import 'continue_watching_screen.dart';
import 'notifications_screen.dart';
import 'package:go_router/go_router.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({Key? key}) : super(key: key);

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int _bannerIndex = 0;
  final PageController _pageController = PageController();
  final ProfileService _profileService = ProfileService();
  Profile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileService.getProfile();
      if (mounted) setState(() => _profile = profile);
    } catch (_) {}
  }

  void _onNavTapped(int index) {
    // Nav handled by dashboard_layout now
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child:                 Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: _profile?.avatarUrl != null ? NetworkImage(_profile!.avatarUrl!) as ImageProvider : const AssetImage('assets/1.png'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text('Hi, ${_profile?.fullName ?? 'Learner'}!', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                              const SizedBox(width: 4),
                              const Text('👋', style: TextStyle(fontSize: 18)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(_profile?.email ?? 'Keep learning, keep growing.', style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                        ],
                      ),
                    ),
                    Stack(
                      children: [
                        IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.textDark), onPressed: () => context.push('/notifications')),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                            child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center),
                          ),
                        )
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.search, color: AppColors.textDark), onPressed: () => context.push('/search')),
                  ],
                ),
              ),

              // Banner Carousel
              SizedBox(
                height: 180,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _bannerIndex = index),
                  children: [
                    _buildBanner(
                      color: const Color(0xFF0038FF),
                      tagText: 'LIVE',
                      tagTitle: 'Upcoming Live Class',
                      title: 'iPhone Hardware Basics',
                      subtitle: 'by MBT Faculty',
                      image: 'assets/iphone_hardware.png',
                      isLive: true,
                    ),
                    _buildBanner(
                      color: const Color(0xFF1B4332),
                      tagText: 'NEW',
                      tagTitle: 'Featured Course',
                      title: 'Advanced Soldering',
                      subtitle: 'by MBT Faculty',
                      image: 'assets/android_hardware.png',
                      isLive: false,
                    ),
                    _buildBanner(
                      color: const Color(0xFF3B1E54),
                      tagText: 'OFFER',
                      tagTitle: 'Limited Time',
                      title: 'Get Flat 25% OFF',
                      subtitle: 'Code: LEARN25',
                      image: 'assets/iphone_software.png',
                      isLive: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Dot indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _bannerIndex == index ? 16 : 6,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _bannerIndex == index ? AppColors.primaryBlue : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Continue Watching
              _buildSectionHeader('Continue Watching', onViewAll: () {
                context.push('/continue-watching');
              }),
              SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildContinueWatchingCard('assets/iphone_software.png', 'Display Light Problem Diagnosis', 'iPhone Repair Course', 35),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // My Courses
              _buildSectionHeader('My Courses', onViewAll: () {
                context.push('/my-courses');
              }),
              SizedBox(
                height: 170,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildCourseCard('assets/iphone_hardware.png', 'iPhone Hardware\nComplete Course', 'In Progress', 65, AppColors.primaryBlue),
                    const SizedBox(width: 16),
                    _buildCourseCard('assets/iphone_software.png', 'iPhone Software\nMastery', 'In Progress', 40, AppColors.primaryBlue),
                    const SizedBox(width: 16),
                    _buildCourseCard('assets/android_hardware.png', 'Android Hardware\nFundamentals', 'Not Started', 0, Colors.grey),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Recent Recordings
              _buildSectionHeader('Recent Recordings', onViewAll: () {
                context.push('/recent-recordings');
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildRecordingTile('assets/iphone_hardware.png', 'Charging Port Repair Live Session', 'iPhone Repair Course', 'Yesterday • 1.2K views', '1:12:34'),
                    const SizedBox(height: 12),
                    _buildRecordingTile('assets/iphone_software.png', 'Face ID Not Working - Troubleshooting', 'iPhone Repair Course', '2 days ago • 980 views', '48:20'),
                    const SizedBox(height: 12),
                    _buildRecordingTile('assets/android_hardware.png', 'Board Level Shorting Explained', 'Advanced Repair Course', '3 days ago • 1.1K views', '1:05:11'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Cards (Progress & Expiring)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.push('/course-progress'),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Row(
                                    children: [
                                      Icon(Icons.trending_up, color: AppColors.primaryBlue, size: 16),
                                      SizedBox(width: 4),
                                      Text('Course Progress', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
                                    ],
                                  ),
                                  Icon(Icons.chevron_right, color: AppColors.textLight, size: 16),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: CircularProgressIndicator(
                                            value: 0.68,
                                            backgroundColor: AppColors.border,
                                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                                            strokeWidth: 4,
                                          ),
                                        ),
                                        const Center(child: Text('68%', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue, fontSize: 12))),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text('Overall Progress', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textDark)),
                                        Text('Keep it up! You\'re doing great.', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.push('/expiring-courses'),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Row(
                                      children: [
                                        Icon(Icons.access_time, color: Colors.deepOrange, size: 16),
                                        SizedBox(width: 4),
                                        Text('Expiring Courses', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 12)),
                                      ],
                                    ),
                                    Icon(Icons.chevron_right, color: AppColors.textLight, size: 16),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const Text('2', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: const [
                                          Text('Courses expiring soon', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textDark)),
                                          Text('Renew now to continue learning', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Notifications
                _buildSectionHeader('Notifications', onViewAll: () {
                  context.push('/notifications');
                }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildNotificationItem(Icons.calendar_today, Colors.blue, 'Live Class Reminder', 'iPhone Hardware Basics is starting in 1 hour.', 'Today, 05:30 PM'),
                      const SizedBox(height: 12),
                      _buildNotificationItem(Icons.warning_amber_rounded, Colors.orange, 'Course Expiring Soon', 'iPhone Software Mastery will expire in 5 days.', 'Today, 04:15 PM'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );
    }

  Widget _buildBanner({
    required Color color,
    required String tagText,
    required String tagTitle,
    required String title,
    required String subtitle,
    required String image,
    required bool isLive,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(color.withValues(alpha: 0.85), BlendMode.srcOver),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLive) ...[
                        const Icon(Icons.circle, color: Colors.white, size: 8),
                        const SizedBox(width: 4),
                      ],
                      Text(tagText, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(tagTitle, style: const TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(width: 4),
                const Icon(Icons.verified, color: Colors.blueAccent, size: 14),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: const [
                      Icon(Icons.calendar_today, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text('Today, 07:00 PM', style: TextStyle(color: Colors.white, fontSize: 12)),
                      SizedBox(width: 12),
                      Icon(Icons.access_time, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text('60 min', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Row(
                    children: [
                      Text('Join Class', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Icon(Icons.chevron_right, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: const Text('View All', style: TextStyle(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildContinueWatchingCard(String image, String title, String subtitle, int progress) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 110,
                height: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                  image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                  ),
                  child: const Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 32)),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(4)),
                  child: const Text('18:45', style: TextStyle(color: Colors.white, fontSize: 8)),
                ),
              )
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textLight), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const Spacer(),
                  LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  const SizedBox(height: 4),
                  Text('$progress% completed', style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(String image, String title, String badgeText, int progress, Color badgeColor) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(4)),
                  child: Text(badgeText, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark), maxLines: 2),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('$progress%', style: const TextStyle(fontSize: 10, color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
                  ],
      ),
    );
  }

  Widget _buildRecordingTile(String image, String title, String subtitle, String details, String duration) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: Icon(Icons.play_circle_outline, color: Colors.white, size: 24)),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(4)),
                  child: Text(duration, style: const TextStyle(color: Colors.white, fontSize: 8)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                const SizedBox(height: 2),
                Text(details, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.file_download_outlined, color: AppColors.primaryBlue), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert, color: AppColors.textLight), onPressed: () => context.push('/more')),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(IconData icon, Color iconColor, String title, String description, String time) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    Text(time, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
