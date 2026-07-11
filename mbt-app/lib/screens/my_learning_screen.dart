import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'course_details_screen.dart';

class MyLearningScreen extends StatelessWidget {
  const MyLearningScreen({Key? key}) : super(key: key);

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
            Text('My Learning', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 22)),
            Text('All your enrolled courses in one place', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: AppColors.textDark), onPressed: () {}),
          Stack(
            alignment: Alignment.center,
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
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.primaryBlue, width: 2)),
                    ),
                    child: const Center(child: Text('Enrolled Courses', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold))),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
                    ),
                    child: const Center(child: Text('Wishlist', style: TextStyle(color: AppColors.textLight))),
                  ),
                ),
              ],
            ),
          ),
          
          // Filters
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: const [
                        Text('All Courses', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down, size: 16),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: AppColors.lightBlueBg, borderRadius: BorderRadius.circular(6)),
                          child: Row(
                            children: const [
                              Icon(Icons.grid_view, size: 14, color: AppColors.primaryBlue),
                              SizedBox(width: 4),
                              Text('Grid', style: TextStyle(color: AppColors.primaryBlue, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Row(
                            children: const [
                              Icon(Icons.view_list, size: 14, color: AppColors.textLight),
                              SizedBox(width: 4),
                              Text('List', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: const [
                        Icon(Icons.filter_list, size: 14),
                        SizedBox(width: 4),
                        Text('Filter', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Grid
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.65,
              children: [
                _buildCourseCard(context, 'assets/iphone_hardware.png', 'iPhone Hardware\nComplete Course', 'iPhone Repair Course', 'In Progress', 65, '42h 30m', '28 Lessons', AppColors.primaryBlue),
                _buildCourseCard(context, 'assets/iphone_software.png', 'iPhone Software\nMastery', 'iPhone Repair Course', 'In Progress', 40, '36h 15m', '24 Lessons', AppColors.primaryBlue),
                _buildCourseCard(context, 'assets/android_hardware.png', 'Android Hardware\nFundamentals', 'Android Repair Course', 'Not Started', 0, '28h 00m', '20 Lessons', Colors.grey),
                _buildCourseCard(context, 'assets/iphone_hardware.png', 'Laptop Chip Level\nRepairing', 'Advanced Repair Course', 'Completed', 100, '45h 20m', '30 Lessons', Colors.green),
                _buildCourseCard(context, 'assets/iphone_software.png', 'Charging Port Repair\nMasterclass', 'iPhone Repair Course', 'In Progress', 75, '18h 10m', '12 Lessons', AppColors.primaryBlue),
                _buildCourseCard(context, 'assets/android_hardware.png', 'Mic & Speaker Repair\nTechniques', 'iPhone Repair Course', 'Not Started', 10, '16h 00m', '10 Lessons', Colors.grey),
              ],
            ),
          ),
          
          // Banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightBlueBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.school, color: AppColors.primaryBlue, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Keep learning, keep growing!', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 13)),
                      SizedBox(height: 2),
                      Text('Complete your courses and earn your certificate.', style: TextStyle(color: AppColors.textLight, fontSize: 10)),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    side: const BorderSide(color: AppColors.primaryBlue),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    minimumSize: Size.zero,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Ensures it doesn't take full width
                    children: const [
                      Icon(Icons.workspace_premium, color: AppColors.primaryBlue, size: 14),
                      SizedBox(width: 4),
                      Text('View Certificates', style: TextStyle(color: AppColors.primaryBlue, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, String imagePath, String title, String subtitle, String badge, int progress, String time, String lessons, Color badgeColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CourseDetailsScreen()),
        );
      },
      child: Container(
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
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(12)),
                  child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.more_vert, size: 16, color: AppColors.textDark),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark, height: 1.2)),
                const SizedBox(height: 4),
                Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: AppColors.lightBlueBg,
                        valueColor: AlwaysStoppedAnimation(badgeColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('$progress%', style: TextStyle(fontSize: 10, color: badgeColor, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(color: AppColors.border),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, size: 10, color: AppColors.textLight),
                          const SizedBox(width: 2),
                          Flexible(child: Text(time, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: AppColors.textLight))),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 12, color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 4)),
                    Flexible(
                      child: Row(
                        children: [
                          const Icon(Icons.play_circle_outline, size: 10, color: AppColors.textLight),
                          const SizedBox(width: 2),
                          Flexible(child: Text(lessons, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: AppColors.textLight))),
                        ],
                      ),
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
}
