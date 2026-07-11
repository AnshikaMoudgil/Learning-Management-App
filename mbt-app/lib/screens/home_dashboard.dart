import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import 'payment_success_screen.dart'; // Just to link it for demo

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({Key? key}) : super(key: key);

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
                child: StreamBuilder<AuthState>(
                  stream: Supabase.instance.client.auth.onAuthStateChange,
                  builder: (context, snapshot) {
                    final user = Supabase.instance.client.auth.currentUser;
                    final fullName = user?.userMetadata?['custom_full_name'] ?? user?.userMetadata?['full_name'] ?? 'Learner';
                    final firstName = fullName.split(' ')[0];
                    final avatarUrl = user?.userMetadata?['custom_avatar_url'] ?? user?.userMetadata?['avatar_url'];

                    return Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: avatarUrl != null 
                              ? NetworkImage(avatarUrl) as ImageProvider
                              : const AssetImage('assets/1.png'), // placeholder for avatar
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text('Hi, $firstName!', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                                  const SizedBox(width: 4),
                                  const Text('👋', style: TextStyle(fontSize: 18)),
                                ],
                              ),
                              const Text('Keep learning, keep growing.', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                            ],
                          ),
                        ),
                    Stack(
                      children: [
                        IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.textDark), onPressed: () {}),
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
                    IconButton(icon: const Icon(Icons.search, color: AppColors.textDark), onPressed: () {}),
                  ],
                );
              }),
              ),

              // Live Class Banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage('assets/iphone_hardware.png'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Color(0xFF0038FF), BlendMode.multiply),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, color: Colors.white, size: 8),
                            SizedBox(width: 4),
                            Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            Text(' Upcoming Live Class', style: TextStyle(color: Colors.white, fontSize: 10)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text('iPhone Hardware Basics', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Text('by MBT Faculty ', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Icon(Icons.verified, color: Colors.blueAccent, size: 14),
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
                                Icon(Icons.calendar_today, color: Colors.white, size: 10),
                                SizedBox(width: 4),
                                Text('Today, 07:00 PM', style: TextStyle(color: Colors.white, fontSize: 10)),
                                SizedBox(width: 8),
                                Icon(Icons.access_time, color: Colors.white, size: 10),
                                SizedBox(width: 4),
                                Text('60 min', style: TextStyle(color: Colors.white, fontSize: 10)),
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
                                Icon(Icons.chevron_right, size: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 16, height: 4, decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 4),
                  Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                ],
              ),
              const SizedBox(height: 24),

              // Continue Watching
              _buildSectionHeader('Continue Watching'),
              SizedBox(
                height: 100,
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
              _buildSectionHeader('My Courses'),
              SizedBox(
                height: 180,
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
              _buildSectionHeader('Recent Recordings'),
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

              // Course Progress & Expiring
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildProgressWidget(context),
                    const SizedBox(height: 16),
                    _buildExpiringWidget(),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Notifications
              _buildSectionHeader('Notifications'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildNotificationTile(Icons.calendar_today, Colors.blue, 'Live Class Reminder', 'iPhone Hardware Basics is starting in 1 hour.', 'Today, 05:30 PM'),
                    _buildNotificationTile(Icons.shopping_bag, Colors.orange, 'Course Expiring Soon', 'iPhone Software Mastery will expire in 5 days.', 'Today, 04:15 PM'),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
        ],
      ),
    );
  }

  Widget _buildContinueWatchingCard(String imagePath, String title, String subtitle, int progress) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
              image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken)),
            ),
            child: const Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 32)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: progress / 100,
                          backgroundColor: AppColors.lightBlueBg,
                          valueColor: const AlwaysStoppedAnimation(AppColors.primaryBlue),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('$progress% completed', style: const TextStyle(fontSize: 10, color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(String imagePath, String title, String badge, int progress, Color badgeColor) {
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
          Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
            ),
            alignment: Alignment.topRight,
            padding: const EdgeInsets.all(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(4)),
              child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark, height: 1.2)),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: AppColors.lightBlueBg,
                  valueColor: AlwaysStoppedAnimation(badgeColor),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('$progress%', style: TextStyle(fontSize: 10, color: badgeColor, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingTile(String imagePath, String title, String course, String views, String duration) {
    return Row(
      children: [
        Container(
          width: 120,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.play_circle_outline, color: Colors.white, size: 28),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
                  child: Text(duration, style: const TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark)),
              const SizedBox(height: 4),
              Text(course, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
              const SizedBox(height: 2),
              Text(views, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
        IconButton(icon: const Icon(Icons.file_download_outlined, color: AppColors.primaryBlue), onPressed: () {}),
        IconButton(icon: const Icon(Icons.more_vert, color: AppColors.textLight), onPressed: () {}),
      ],
    );
  }

  Widget _buildProgressWidget(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentSuccessScreen()));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.trending_up, color: AppColors.primaryBlue, size: 16),
                    SizedBox(width: 4),
                    Text('Course Progress', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryBlue)),
                  ],
                ),
                Icon(Icons.chevron_right, size: 16, color: AppColors.textLight),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        value: 0.68,
                        backgroundColor: AppColors.lightBlueBg,
                        valueColor: AlwaysStoppedAnimation(AppColors.primaryBlue),
                        strokeWidth: 4,
                      ),
                    ),
                    Text('68%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                  ],
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
    );
  }

  Widget _buildExpiringWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.orange, size: 16),
                  SizedBox(width: 4),
                  Text('Expiring Courses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.orange)),
                ],
              ),
              Icon(Icons.chevron_right, size: 16, color: AppColors.textLight),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('2', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange)),
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
    );
  }

  Widget _buildNotificationTile(IconData icon, Color color, String title, String subtitle, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}
