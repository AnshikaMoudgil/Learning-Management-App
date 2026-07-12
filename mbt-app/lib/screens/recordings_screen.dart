import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class RecordingsScreen extends StatelessWidget {
  const RecordingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Recordings Library', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 22)),
            Text('Watch and revise your past live classes anytime.', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: AppColors.textDark), onPressed: () => context.push('/search')),
          Stack(
            alignment: Alignment.center,
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
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filters
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(20)),
                      child: const Text('All Recordings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: const [
                          Text('Courses', style: TextStyle(color: AppColors.textDark, fontSize: 12)),
                          SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textDark),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: const [
                          Text('Teachers', style: TextStyle(color: AppColors.textDark, fontSize: 12)),
                          SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textDark),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: const [
                          Icon(Icons.tune, size: 14, color: AppColors.textDark),
                          SizedBox(width: 4),
                          Text('Filter', style: TextStyle(color: AppColors.textDark, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Recent Recordings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                  Text('See All', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryBlue)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildRecordingCard('assets/iphone_hardware.png', 'iPhone Hardware Course', 'Display Light Problem Diagnosis', 'Rahul Verma', 'Hardware Expert', '02 May 2025', '245 Attended', '58:24'),
                  const SizedBox(height: 16),
                  _buildRecordingCard('assets/iphone_software.png', 'iPhone Hardware Course', 'Face ID Not Working - Deep Dive', 'Amit Sharma', 'Hardware Expert', '30 Apr 2025', '210 Attended', '1:12:35'),
                  const SizedBox(height: 16),
                  _buildRecordingCard('assets/android_hardware.png', 'Advanced Repair Course', 'Board Level Shorting Explained', 'Pankaj Singh', 'Board Level Specialist', '28 Apr 2025', '189 Attended', '47:18'),
                  const SizedBox(height: 16),
                  _buildRecordingCard('assets/iphone_hardware.png', 'Android Hardware Course', 'Battery Replacement Best Practices', 'Neeraj Patel', 'Android Expert', '26 Apr 2025', '176 Attended', '1:03:45'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Browse by Course', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                  Text('View All', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryBlue)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Browse Grid
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildBrowseCard(Icons.phone_iphone, 'iPhone Hardware\nCourse', '12 Recordings', const Color(0xFFE5F0FF)),
                  _buildBrowseCard(Icons.android, 'Android Hardware\nCourse', '8 Recordings', const Color(0xFFEAF9E5)),
                  _buildBrowseCard(Icons.build, 'Advanced Repair\nCourse', '6 Recordings', const Color(0xFFF4E5FF)),
                  _buildBrowseCard(Icons.memory, 'Board Level\nCourse', '4 Recordings', const Color(0xFFFFF2E5)),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingCard(String imagePath, String course, String title, String instructor, String instructorRole, String date, String attended, String duration) {
    return Container(
      height: 140, // Fixed height
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 24),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
                    child: Text(duration, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          
          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.lightBlueBg, borderRadius: BorderRadius.circular(12)),
                        child: Text(course, style: const TextStyle(color: AppColors.primaryBlue, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                      const Icon(Icons.more_vert, size: 16, color: AppColors.textDark),
                    ],
                  ),
                  Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark, height: 1.2)),
                  Row(
                    children: [
                      const CircleAvatar(radius: 12, backgroundImage: AssetImage('assets/1.png')), // placeholder
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(instructor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textDark)),
                            Text(instructorRole, style: const TextStyle(fontSize: 9, color: AppColors.textLight)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Icon(Icons.calendar_today, size: 10, color: AppColors.textLight),
                            const SizedBox(width: 4),
                            Text(date, style: const TextStyle(fontSize: 9, color: AppColors.textLight)),
                            const SizedBox(width: 6),
                            const Text('|', style: TextStyle(color: AppColors.border, fontSize: 10)),
                            const SizedBox(width: 6),
                            const Icon(Icons.people_outline, size: 12, color: AppColors.textLight),
                            const SizedBox(width: 4),
                            Text(attended, style: const TextStyle(fontSize: 9, color: AppColors.textLight)),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primaryBlue),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          minimumSize: const Size(0, 28),
                        ),
                        child: const Text('Watch Again', style: TextStyle(color: AppColors.primaryBlue, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
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

  Widget _buildBrowseCard(IconData icon, String title, String subtitle, Color bgColor) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 24),
          const Spacer(),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textDark, height: 1.2)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
        ],
      ),
    );
  }
}
