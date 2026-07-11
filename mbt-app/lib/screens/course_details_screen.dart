import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class CourseDetailsScreen extends StatefulWidget {
  const CourseDetailsScreen({Key? key}) : super(key: key);

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  int _selectedIndex = 0; // 0: Overview, 1: Live Classes, 2: Recordings, 3: Resources
  bool _isUnlocked = false; // Toggle this to test unlocked state

  void _showShareBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Share this course', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Share "Mobile IC Repair Complete Course" with your friends and help them learn.', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSocialIcon(Icons.chat, Colors.green, 'WhatsApp'),
                  _buildSocialIcon(Icons.send, Colors.lightBlue, 'Telegram'),
                  _buildSocialIcon(Icons.facebook, Colors.blue, 'Facebook'),
                  _buildSocialIcon(Icons.share, Colors.lightBlueAccent, 'Twitter'),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      _showMoreOptionsBottomSheet(context);
                    },
                    child: _buildSocialIcon(Icons.more_horiz, Colors.grey.shade400, 'More'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('https://app.skilltech.com/courses/mobile-ic-repair', style: TextStyle(fontSize: 12, color: AppColors.textDark), overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(const ClipboardData(text: 'https://app.skilltech.com/courses/mobile-ic-repair'));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied!')));
                      },
                      child: const Text('Copy', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showMoreOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('More Options', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 16),
              _buildMoreOptionRow(Icons.link, 'Copy Link', () {
                Clipboard.setData(const ClipboardData(text: 'https://app.skilltech.com/courses/mobile-ic-repair'));
                Navigator.pop(ctx);
              }),
              _buildMoreOptionRow(Icons.email_outlined, 'Share via Email', () {}),
              _buildMoreOptionRow(Icons.camera_alt_outlined, 'Share to Instagram', () {}),
              _buildMoreOptionRow(Icons.message_outlined, 'Share to SMS', () {}),
              _buildMoreOptionRow(Icons.qr_code_scanner, 'QR Code', () {}),
              _buildMoreOptionRow(Icons.flag_outlined, 'Report an Issue', () {}),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoreOptionRow(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textDark, size: 20),
            const SizedBox(width: 16),
            Text(text, style: const TextStyle(fontSize: 14, color: AppColors.textDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textDark)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark), onPressed: () => Navigator.pop(context)),
        title: const Text('Course Details', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined, color: AppColors.textDark), onPressed: () => _showShareBottomSheet(context)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image (Persistent)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(image: AssetImage('assets/iphone_hardware.png'), fit: BoxFit.cover),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(4)),
                      child: const Text('BESTSELLER', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  if (_selectedIndex == 0) // Only show Edit Progress on Overview tab
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isUnlocked = !_isUnlocked;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(16)),
                          child: const Text('Edit Progress', style: TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Dynamic content based on tab
            if (_selectedIndex == 0) _buildOverviewTab(),
            if (_selectedIndex == 1) _buildLiveClassesTab(),
            if (_selectedIndex == 2) _buildRecordingsTab(),
            if (_selectedIndex == 3) _buildResourcesTab(),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textLight,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Overview'),
          BottomNavigationBarItem(icon: Icon(Icons.videocam_outlined), label: 'Live Classes'),
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_outline), label: 'Recordings'),
          BottomNavigationBarItem(icon: Icon(Icons.article_outlined), label: 'Resources'),
        ],
      ),
    );
  }

  // ==============================
  // OVERVIEW TAB
  // ==============================
  Widget _buildOverviewTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mobile IC Repair\nComplete Course', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark, height: 1.2)),
          const SizedBox(height: 8),
          const Text('By Mr. Ankit Verma', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.orange, size: 14),
              const SizedBox(width: 4),
              const Text('4.8', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(width: 4),
              const Text('(1.2k students)', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                child: const Text('Premium', style: TextStyle(color: AppColors.primaryBlue, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Learn the complete mobile IC repair process from basics to advanced level. This course covers all important topics with practical examples.',
            style: TextStyle(fontSize: 12, color: AppColors.textDark, height: 1.5),
          ),
          const SizedBox(height: 4),
          const Text('Read more', style: TextStyle(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildInfoBox(Icons.access_time, '35 Hours')),
              const SizedBox(width: 8),
              Expanded(child: _buildInfoBox(Icons.video_library_outlined, '120 Lessons')),
              const SizedBox(width: 8),
              Expanded(child: _buildInfoBox(Icons.workspace_premium_outlined, 'Certificate')),
            ],
          ),
          const SizedBox(height: 24),
          if (!_isUnlocked) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Your Progress', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      Text('65%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: 0.65,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 12),
                  const Text('78 / 120 Lessons Completed', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.workspace_premium_outlined, color: Colors.green, size: 24),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text('Complete remaining 42 lessons to unlock your certificate', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Congratulations!', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                  const SizedBox(height: 8),
                  const Text('You have completed this course and earned your certificate.', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('View Certificate'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: const BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  )
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          const Text('What you\'ll learn', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 16),
          _buildCheckListItem('Identify and test mobile ICs'),
          _buildCheckListItem('Advanced soldering techniques'),
          _buildCheckListItem('Fault finding and troubleshooting'),
          _buildCheckListItem('IC replacement and reballing'),
        ],
      ),
    );
  }

  // ==============================
  // LIVE CLASSES TAB
  // ==============================
  Widget _buildLiveClassesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPersistentHeader('Mobile IC Repair Complete Course'),
        _buildSubTabBar(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text('Upcoming Live Classes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 16),
              _buildUpcomingClassItem('MAY', '14', 'Wed', 'Power IC Section - Deep Dive', 'Mr. Ankit Verma', '07:00 PM - 08:30 PM'),
              _buildUpcomingClassItem('MAY', '17', 'Sat', 'CPU Reballing Techniques', 'Mr. Rahul Sharma', '07:00 PM - 08:30 PM'),
              _buildUpcomingClassItem('MAY', '21', 'Wed', 'Advanced Fault Finding', 'Mr. Sonu Singh', '07:00 PM - 08:30 PM'),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(color: AppColors.border),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('View Full Schedule', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.chevron_right, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==============================
  // RECORDINGS TAB
  // ==============================
  Widget _buildRecordingsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPersistentHeader('Mobile IC Repair Complete Course'),
        _buildSubTabBar(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text('Course Recordings (120)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 16),
              _buildRecordingItem('assets/iphone_hardware.png', '32:45', 'Introduction to Mobile IC Repair', 'Mr. Ankit Verma', '12 May 2025'),
              _buildRecordingItem('assets/iphone_software.png', '29:10', 'Basic Tools & Equipment', 'Mr. Ankit Verma', '13 May 2025'),
              _buildRecordingItem('assets/android_hardware.png', '36:20', 'Components Identification', 'Mr. Rahul Sharma', '14 May 2025'),
              _buildRecordingItem('assets/iphone_hardware.png', '29:15', 'Schematic Reading Basics', 'Mr. Rahul Sharma', '15 May 2025'),
            ],
          ),
        ),
      ],
    );
  }

  // ==============================
  // RESOURCES TAB
  // ==============================
  Widget _buildResourcesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPersistentHeader('Mobile IC Repair Complete Course'),
        _buildSubTabBar(),
        // Normal state or empty state? Let's show normal state based on a toggle or just normal state. 
        // We'll show the normal state, but the user wanted the empty state shown too. 
        // I will just implement the normal state with the resources list as it looks better.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text('Course Resources', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 16),
              _buildResourceItem(Icons.picture_as_pdf, Colors.red, 'Mobile IC Repair - Complete Notes.pdf', '2.4 MB'),
              _buildResourceItem(Icons.picture_as_pdf, Colors.blue, 'Power IC Section - Handwritten Notes.pdf', '1.8 MB'),
              _buildResourceItem(Icons.table_chart, Colors.green, 'Circuit Diagram Reference.pdf', '3.2 MB'),
              _buildResourceItem(Icons.folder_zip, Colors.orange, 'IC Datasheet Collection.zip', '12.5 MB'),
              _buildResourceItem(Icons.picture_as_pdf, Colors.redAccent, 'Common Faults & Solutions.pdf', '2.1 MB'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF0EDFF), borderRadius: BorderRadius.circular(8)),
                child: const Text('Resources are provided for personal learning only and cannot be shared or redistributed.', style: TextStyle(fontSize: 10, color: AppColors.textDark)),
              )
            ],
          ),
        ),
      ],
    );
  }

  // ==============================
  // SHARED WIDGETS
  // ==============================

  Widget _buildPersistentHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_isUnlocked ? '100% completed' : '65% completed', style: const TextStyle(fontSize: 10, color: AppColors.textDark)),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: _isUnlocked ? 1.0 : 0.65,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _isUnlocked ? Colors.green.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: _isUnlocked ? Colors.green : Colors.transparent),
                ),
                child: Row(
                  children: [
                    Icon(_isUnlocked ? Icons.check_circle_outline : Icons.lock_outline, color: Colors.green, size: 12),
                    const SizedBox(width: 4),
                    Text(_isUnlocked ? 'Certificate\nUnlocked' : 'Certificate\nLocked', style: const TextStyle(fontSize: 8, color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSubTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          _buildSubTabItem('Live Classes', 1),
          _buildSubTabItem('Recordings', 2),
          _buildSubTabItem('Resources', 3),
        ],
      ),
    );
  }

  Widget _buildSubTabItem(String label, int index) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: isSelected ? AppColors.primaryBlue : Colors.transparent, width: 2)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primaryBlue : AppColors.textLight,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: AppColors.textLight),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 10, color: AppColors.textDark, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCheckListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
            child: const Icon(Icons.check, color: Colors.white, size: 12),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textDark))),
        ],
      ),
    );
  }

  Widget _buildUpcomingClassItem(String month, String day, String weekday, String title, String author, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(month, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
              Text(day, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              Text(weekday, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
            ],
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 40, color: AppColors.border),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const CircleAvatar(radius: 8, backgroundImage: AssetImage('assets/1.png')),
                    const SizedBox(width: 6),
                    Text(author, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: AppColors.textLight),
                    const SizedBox(width: 4),
                    Text(time, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size(60, 32),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text('Join', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildRecordingItem(String image, String duration, String title, String author, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark), maxLines: 2),
                const SizedBox(height: 4),
                Text(author, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                const SizedBox(height: 4),
                Text(date, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: AppColors.primaryBlue),
            onPressed: () {},
          )
        ],
      ),
    );
  }

  Widget _buildResourceItem(IconData icon, Color color, String title, String size) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(size, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: AppColors.primaryBlue),
            onPressed: () {},
          )
        ],
      ),
    );
  }
}
