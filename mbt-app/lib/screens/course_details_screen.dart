import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CourseDetailsScreen extends StatefulWidget {
  const CourseDetailsScreen({Key? key}) : super(key: key);

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlueBg, // using light blue as base background for the list
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    _buildProgressCard(),
                    _buildCertificateCard(),
                    _buildTabs(),
                    Container(height: 8, color: AppColors.lightBlueBg),
                    if (_selectedTabIndex == 0) _buildModulesList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: const Color(0xFF0D1B2A), // Dark blue matching image
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.ios_share, color: Colors.white),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image (assuming asset exists, fallback to color for safety)
            Image.asset(
              'assets/iphone_hardware.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF0F172A)),
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    const Color(0xFF06152B).withOpacity(0.9),
                    const Color(0xFF06152B),
                  ],
                ),
              ),
            ),
            // Content
            Positioned(
              bottom: 40, // Space for the overlapping card
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'In Progress',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'iPhone Hardware\nComplete Course',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Master iPhone hardware repair from\nbasics to advanced level.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const CircleAvatar(radius: 10, backgroundColor: Colors.white, child: Icon(Icons.person, size: 14)), // Placeholder for MBT Faculty icon
                      const SizedBox(width: 8),
                      const Text('MBT Faculty', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, color: AppColors.primaryBlue, size: 14),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Icon(Icons.star, color: Colors.amber, size: 14),
                      SizedBox(width: 4),
                      Text('4.8 (2.4K students)', style: TextStyle(color: Colors.white70, fontSize: 12)),
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

  Widget _buildProgressCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Your Progress', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
              Row(
                children: const [
                  Text('View Learning Analytics', style: TextStyle(color: AppColors.primaryBlue, fontSize: 10, fontWeight: FontWeight.bold)),
                  SizedBox(width: 4),
                  Icon(Icons.bar_chart, color: AppColors.primaryBlue, size: 14),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Circular Progress
              SizedBox(
                height: 60,
                width: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: 0.65,
                      strokeWidth: 6,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primaryBlue),
                    ),
                    const Text('65%', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Course Progress', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark)),
                    const SizedBox(height: 4),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 11, color: AppColors.textLight),
                        children: [
                          TextSpan(text: 'You\'ve completed '),
                          TextSpan(text: '28 of 43', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                          TextSpan(text: ' lessons'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: 0.65,
                            backgroundColor: AppColors.border,
                            valueColor: const AlwaysStoppedAnimation(AppColors.primaryBlue),
                            minHeight: 4,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('42h 30m / 65h', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
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

  Widget _buildCertificateCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2FBF5), // Light green tint
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2F5E9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.workspace_premium_outlined, color: Colors.green, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Certificate Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark)),
                SizedBox(height: 2),
                Text('Complete all lessons and assessments to earn your certificate.', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.green),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                Icon(Icons.hourglass_empty, color: Colors.green, size: 12),
                SizedBox(width: 4),
                Text('Not Earned', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = [
      {'icon': Icons.grid_view, 'label': 'Modules'},
      {'icon': Icons.sensors, 'label': 'Live Classes'},
      {'icon': Icons.videocam_outlined, 'label': 'Recordings'},
      {'icon': Icons.description_outlined, 'label': 'Resources'},
    ];

    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = _selectedTabIndex == index;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      tabs[index]['icon'] as IconData,
                      size: 16,
                      color: isSelected ? AppColors.primaryBlue : AppColors.textLight,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tabs[index]['label'] as String,
                      style: TextStyle(
                        color: isSelected ? AppColors.primaryBlue : AppColors.textLight,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildModulesList() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Course Curriculum', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
              Text('Expand All', style: TextStyle(color: AppColors.primaryBlue, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          _buildModuleCard(
            number: '1',
            title: 'Introduction to iPhone Hardware',
            subtitle: '5 Lessons • 1h 20m',
            statusWidget: _buildCompletedBadge(),
            isExpanded: false,
          ),
          const SizedBox(height: 12),
          _buildModuleCard(
            number: '2',
            title: 'iPhone Disassembly & Assembly',
            subtitle: '7 Lessons • 2h 10m',
            statusWidget: _buildCompletedBadge(),
            isExpanded: false,
          ),
          const SizedBox(height: 12),
          _buildModuleCard(
            number: '3',
            title: 'Display Unit Repair',
            subtitle: '10 Lessons • 6h 30m',
            statusWidget: const Text('70%', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
            isExpanded: true,
            isHighlighted: true,
            children: [
              _buildLessonItem(title: '3.1 Introduction to Display Unit', time: '08:45', status: LessonStatus.completed, isFirst: true),
              _buildLessonItem(title: '3.2 Display Light Problem Diagnosis', time: '18:20', status: LessonStatus.completed),
              _buildLessonItem(title: '3.3 Display Replacement Process', time: '22:15', status: LessonStatus.playing, isHighlighted: true),
              _buildLessonItem(title: '3.4 True Tone & Display IC', time: '16:40', status: LessonStatus.locked),
              _buildLessonItem(title: '3.5 Practical: Display Repair', time: '45:30', status: LessonStatus.locked, isLast: true),
            ],
          ),
          const SizedBox(height: 12),
          _buildModuleCard(
            number: '4',
            title: 'Battery & Charging System',
            subtitle: '6 Lessons • 3h 40m',
            statusWidget: const Text('40%', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
            isExpanded: false,
          ),
          const SizedBox(height: 12),
          _buildModuleCard(
            number: '5',
            title: 'Board Level Troubleshooting',
            subtitle: '15 Lessons • 12h 50m',
            statusWidget: const Text('0%', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
            isExpanded: false,
          ),
          const SizedBox(height: 12),
          _buildModuleCard(
            number: '6',
            title: 'Final Assessment & Certification',
            subtitle: '3 Lessons • 1h 00m',
            statusWidget: _buildLockedBadge(),
            isExpanded: false,
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFE2F5E9), borderRadius: BorderRadius.circular(4)),
      child: const Text('Completed', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
  
  Widget _buildLockedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: AppColors.lightBlueBg, borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text('Locked', style: TextStyle(color: AppColors.textLight, fontSize: 10, fontWeight: FontWeight.bold)),
          SizedBox(width: 4),
          Icon(Icons.lock_outline, size: 12, color: AppColors.textLight),
        ],
      ),
    );
  }

  Widget _buildModuleCard({
    required String number,
    required String title,
    required String subtitle,
    required Widget statusWidget,
    required bool isExpanded,
    bool isHighlighted = false,
    List<Widget> children = const [],
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.lightBlueBg.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isHighlighted ? AppColors.primaryBlue.withOpacity(0.3) : AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primaryBlue,
                  child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                    ],
                  ),
                ),
                statusWidget,
                const SizedBox(width: 8),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppColors.textLight,
                  size: 20,
                ),
              ],
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 16, bottom: 16),
              child: Column(children: children),
            ),
        ],
      ),
    );
  }

  Widget _buildLessonItem({
    required String title,
    required String time,
    required LessonStatus status,
    bool isHighlighted = false,
    bool isFirst = false,
    bool isLast = false,
  }) {
    IconData trailingIcon;
    Color iconColor;
    Widget leadingWidget;

    switch (status) {
      case LessonStatus.completed:
        trailingIcon = Icons.check_circle;
        iconColor = Colors.green;
        leadingWidget = const Icon(Icons.check_circle, color: Colors.green, size: 16);
        break;
      case LessonStatus.playing:
        trailingIcon = Icons.play_circle_outline;
        iconColor = AppColors.primaryBlue;
        leadingWidget = const Icon(Icons.play_circle, color: AppColors.primaryBlue, size: 16);
        break;
      case LessonStatus.locked:
        trailingIcon = Icons.lock_outline;
        iconColor = AppColors.textLight;
        leadingWidget = Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.border, width: 2)),
        );
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline connector
          SizedBox(
            width: 16,
            child: Column(
              children: [
                if (!isFirst) Expanded(child: Container(width: 1, color: AppColors.border)),
                if (isFirst) const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: leadingWidget,
                ),
                if (!isLast) Expanded(child: Container(width: 1, color: AppColors.border)),
                if (isLast) const SizedBox(height: 12),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                        color: isHighlighted ? AppColors.primaryBlue : AppColors.textDark,
                      ),
                    ),
                  ),
                  Text(time, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                  const SizedBox(width: 12),
                  Icon(trailingIcon, size: 16, color: iconColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 1, // My Learning is active
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: AppColors.textLight,
      selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontSize: 10),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), activeIcon: Icon(Icons.menu_book), label: 'My Learning'),
        BottomNavigationBarItem(icon: Icon(Icons.videocam_outlined), activeIcon: Icon(Icons.videocam), label: 'Live Classes'),
        BottomNavigationBarItem(icon: Icon(Icons.play_circle_outline), activeIcon: Icon(Icons.play_circle), label: 'Recordings'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}

enum LessonStatus { completed, playing, locked }
