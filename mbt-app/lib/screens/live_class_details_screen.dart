import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LiveClassDetailsScreen extends StatelessWidget {
  const LiveClassDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Very light grey background matching image
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Live Class Details', style: TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroImage(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildCountdownCard(),
                  const SizedBox(height: 16),
                  _buildScheduleCard(),
                  const SizedBox(height: 16),
                  _buildFacultyCard(),
                  const SizedBox(height: 16),
                  _buildAboutCard(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomReminderBar(),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      width: double.infinity,
      height: 240,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        image: DecorationImage(
          image: AssetImage('assets/iphone_hardware.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Dark gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2),
                  const Color(0xFF06152B).withOpacity(0.8),
                  const Color(0xFF06152B),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFFE53935), borderRadius: BorderRadius.circular(6)),
                      child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        children: const [
                          Icon(Icons.videocam, color: Colors.blue, size: 14),
                          SizedBox(width: 4),
                          Text('zoom', style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('iPhone Hardware Course', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Display Light\nProblem Diagnosis',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.2),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Learn how to identify and fix display\nlight issues in iPhone step by step.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    Icon(Icons.calendar_month_outlined, color: Colors.white70, size: 14),
                    SizedBox(width: 6),
                    Text('Today, 02 May 2025', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    SizedBox(width: 12),
                    Text('|', style: TextStyle(color: Colors.white54, fontSize: 14)),
                    SizedBox(width: 12),
                    Icon(Icons.access_time, color: Colors.white70, size: 14),
                    SizedBox(width: 6),
                    Text('07:00 PM (IST)', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Live class starts in', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTimeBlock('01', 'DAYS'),
                    const Text(':', style: TextStyle(color: AppColors.primaryBlue, fontSize: 24, fontWeight: FontWeight.bold)),
                    _buildTimeBlock('18', 'HOURS'),
                    const Text(':', style: TextStyle(color: AppColors.primaryBlue, fontSize: 24, fontWeight: FontWeight.bold)),
                    _buildTimeBlock('42', 'MINS'),
                    const Text(':', style: TextStyle(color: AppColors.primaryBlue, fontSize: 24, fontWeight: FontWeight.bold)),
                    _buildTimeBlock('35', 'SECS'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 5,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.videocam),
                    label: const Text('Join Live Class', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.info_outline, size: 10, color: AppColors.textLight),
                    SizedBox(width: 4),
                    Text('You\'ll be redirected to Zoom', style: TextStyle(fontSize: 9, color: AppColors.textLight)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBlock(String time, String label) {
    return Column(
      children: [
        Text(time, style: const TextStyle(color: AppColors.primaryBlue, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 8, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildScheduleCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: const [
                Icon(Icons.event_note, color: AppColors.primaryBlue, size: 18),
                SizedBox(width: 8),
                Text('Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildScheduleRow(Icons.calendar_month_outlined, 'Date', 'Today, 02 May 2025'),
          const Divider(height: 1, color: AppColors.border),
          _buildScheduleRow(Icons.access_time, 'Time', '07:00 PM - 08:00 PM (IST)'),
          const Divider(height: 1, color: AppColors.border),
          _buildScheduleRow(Icons.timer_outlined, 'Duration', '60 Minutes'),
          const Divider(height: 1, color: AppColors.border),
          _buildPlatformRow(),
        ],
      ),
    );
  }

  Widget _buildScheduleRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.lightBlueBg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppColors.primaryBlue, size: 16),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.lightBlueBg, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.videocam_outlined, color: AppColors.primaryBlue, size: 16),
          ),
          const SizedBox(width: 16),
          const SizedBox(
            width: 80,
            child: Text('Platform', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(12)),
            child: const Text('zoom', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Zoom Live Meeting', style: TextStyle(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildFacultyCard() {
    return Container(
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
            children: const [
              Icon(Icons.person_outline, color: AppColors.primaryBlue, size: 18),
              SizedBox(width: 8),
              Text('Faculty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage('assets/1.png'), // placeholder
                backgroundColor: AppColors.lightBlueBg,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text('Rahul Verma', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                        SizedBox(width: 4),
                        Icon(Icons.verified, color: Colors.blue, size: 14),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text('Hardware Expert', style: TextStyle(color: AppColors.primaryBlue, fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    const Text(
                      '8+ years of experience in iPhone repair & training. Specializes in advanced hardware diagnostics.',
                      style: TextStyle(color: AppColors.textLight, fontSize: 11, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.people_outline, size: 14, color: AppColors.textLight),
                        const SizedBox(width: 4),
                        const Text('12K+ Students', style: TextStyle(fontSize: 11, color: AppColors.textDark, fontWeight: FontWeight.w500)),
                        Container(
                          width: 1,
                          height: 12,
                          color: AppColors.border,
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        const Text('4.8 Rating', style: TextStyle(fontSize: 11, color: AppColors.textDark, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
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
            children: const [
              Icon(Icons.info_outline, color: AppColors.primaryBlue, size: 18),
              SizedBox(width: 8),
              Text('About this Live Class', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'In this session, you will learn how to diagnose and troubleshoot display light issues in iPhones. We will cover practical techniques, common faults, and real-time Q&A.',
            style: TextStyle(color: AppColors.textLight, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildAboutTag(Icons.question_answer_outlined, 'Live Q&A', Colors.orange),
              _buildAboutTag(Icons.chat_bubble_outline, 'Real-time Interaction', Colors.green),
              _buildAboutTag(Icons.radio_button_checked, 'Session will be Recorded', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTag(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textDark, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildBottomReminderBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF), // Very light blue matching image
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            const Icon(Icons.notifications_active_outlined, color: AppColors.primaryBlue, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Reminder On', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryBlue)),
                  SizedBox(height: 2),
                  Text('We will remind you 15 minutes before the class starts.', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none, size: 14, color: AppColors.primaryBlue),
              label: const Text('Manage Reminder', style: TextStyle(color: AppColors.primaryBlue, fontSize: 11, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryBlue),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
