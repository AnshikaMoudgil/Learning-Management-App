import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'class_details_screen.dart';
import 'recent_recordings_screen.dart';
import 'package:go_router/go_router.dart';

class DailyScheduleScreen extends StatefulWidget {
  const DailyScheduleScreen({Key? key}) : super(key: key);

  @override
  State<DailyScheduleScreen> createState() => _DailyScheduleScreenState();
}

class _DailyScheduleScreenState extends State<DailyScheduleScreen> {
  String _selectedDate = '2 May';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark), onPressed: () => context.pop()),
        title: const Text('2 May 2025', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.calendar_month, color: AppColors.textDark), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildDatePicker('Wed', '30 Apr', false),
                _buildDatePicker('Thu', '1 May', false),
                _buildDatePicker('Fri', '2 May', true),
                _buildDatePicker('Sat', '3 May', false),
                _buildDatePicker('Sun', '4 May', false),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Friday, 2 May 2025', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    Text('2 Classes', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                  ],
                ),
                const SizedBox(height: 24),
                _buildTimelineClassItem(
                  startTime: '07:00 PM',
                  endTime: '08:00 PM',
                  image: 'assets/iphone_hardware.png',
                  courseName: 'iPhone Hardware Course',
                  title: 'Display Light Problem Diagnosis',
                  author: 'Rahul Verma',
                  startsIn: '01:18:45',
                  isGreen: true,
                ),
                _buildTimelineClassItem(
                  startTime: '11:00 PM',
                  endTime: '12:30 PM',
                  image: 'assets/android_hardware.png',
                  courseName: 'Android Hardware Course',
                  title: 'Face ID Not Working - Deep Dive',
                  author: 'Amit Sharma',
                  startsIn: '15:18:45',
                  isGreen: false,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlueBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.calendar_today, color: AppColors.primaryBlue, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Can\'t attend live?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                            Text('Watch the recording anytime after the class ends.', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () {
                          context.pushReplacement('/recent-recordings');
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primaryBlue,
                          side: const BorderSide(color: AppColors.primaryBlue),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          minimumSize: const Size(0, 36),
                        ),
                        child: const Text('Go to Recordings', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDatePicker(String dayStr, String dateStr, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedDate = dateStr),
      child: Container(
        width: 60,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? null : Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(dayStr, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : AppColors.textLight)),
            const SizedBox(height: 4),
            Text(dateStr, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.textDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineClassItem({
    required String startTime,
    required String endTime,
    required String image,
    required String courseName,
    required String title,
    required String author,
    required String startsIn,
    required bool isGreen,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(startTime, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text(endTime, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 70,
                        height: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(courseName, style: const TextStyle(fontSize: 9, color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark), maxLines: 2),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const CircleAvatar(radius: 8, backgroundImage: AssetImage('assets/1.png')),
                                const SizedBox(width: 4),
                                Text(author, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                                const SizedBox(width: 2),
                                const Icon(Icons.verified, color: AppColors.primaryBlue, size: 10),
                              ],
                            ),
                            const Text('Hardware Expert', style: TextStyle(fontSize: 8, color: AppColors.textLight)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Starts in', style: TextStyle(fontSize: 8, color: AppColors.textLight)),
                          Text(startsIn, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isGreen ? Colors.green : AppColors.primaryBlue)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              context.push('/class-details');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(60, 28),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              elevation: 0,
                            ),
                            child: const Text('Join Class', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.calendar_today, size: 14, color: AppColors.primaryBlue),
                        label: const Text('Add to Calendar', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryBlue,
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          minimumSize: const Size(0, 36),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_active_outlined, size: 14, color: AppColors.primaryBlue),
                        label: const Text('Set Reminder', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryBlue,
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          minimumSize: const Size(0, 36),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
