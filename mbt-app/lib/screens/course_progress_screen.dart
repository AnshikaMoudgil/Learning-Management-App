import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../widgets/share_bottom_sheet.dart';

class CourseProgressScreen extends StatefulWidget {
  const CourseProgressScreen({Key? key}) : super(key: key);

  @override
  State<CourseProgressScreen> createState() => _CourseProgressScreenState();
}

class _CourseProgressScreenState extends State<CourseProgressScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Header Hero
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            leading: IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.ios_share, color: Colors.white),
                onPressed: () => ShareUtils.showShareBottomSheet(
                  context,
                  courseName: 'iPhone Hardware Complete Course',
                  url: 'https://app.skilltech.com/courses/iphone-hardware',
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/iphone_hardware.png', fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(12)),
                          child: const Text('In Progress', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'iPhone Hardware Complete Course',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Master iPhone hardware repair from basics to advanced level.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.account_circle, color: Colors.white70, size: 16),
                            const SizedBox(width: 4),
                            const Text('MBT Faculty', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, color: Colors.blue, size: 14),
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
          ),
          
          // Body Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Cards overlapping the header slightly
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Progress Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Row(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: CircularProgressIndicator(
                                      value: 0.65,
                                      strokeWidth: 6,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                                    ),
                                  ),
                                  const Text('65%', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                                ],
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Course Progress', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 14)),
                                        GestureDetector(
                                          onTap: () {},
                                          child: Row(
                                            children: const [
                                              Text('View Learning Analytics', style: TextStyle(color: AppColors.primaryBlue, fontSize: 10, fontWeight: FontWeight.bold)),
                                              SizedBox(width: 4),
                                              Icon(Icons.bar_chart, color: AppColors.primaryBlue, size: 12),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: const [
                                        Text("You've completed ", style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                                        Text('28 of 43 ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                                        Text('lessons', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    LinearProgressIndicator(
                                      value: 0.65,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                                      minHeight: 4,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    const SizedBox(height: 8),
                                    const Align(
                                      alignment: Alignment.centerRight,
                                      child: Text('42h 30m / 65h', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Certificate Status
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: const Icon(Icons.workspace_premium, color: Colors.green, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('Certificate Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
                                    SizedBox(height: 4),
                                    Text('Complete all lessons and assessments to earn your certificate.', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.green.shade300),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('Not Earned', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Tabs
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: AppColors.primaryBlue,
                  unselectedLabelColor: AppColors.textLight,
                  indicatorColor: AppColors.primaryBlue,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [Icon(Icons.dashboard_outlined, size: 16), SizedBox(width: 4), Text('Modules')],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [Icon(Icons.podcasts, size: 16), SizedBox(width: 4), Text('Live Classes')],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [Icon(Icons.videocam_outlined, size: 16), SizedBox(width: 4), Text('Recordings')],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [Icon(Icons.description_outlined, size: 16), SizedBox(width: 4), Text('Resources')],
                      ),
                    ),
                  ],
                ),
                
                // Tab Content
                IndexedStack(
                  index: _tabController.index,
                  children: [
                    _buildModulesTab(),
                    _buildLiveClassesTab(),
                    _buildRecordingsTab(),
                    _buildResourcesTab(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModulesTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Modules', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
              Text('Expand All', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryBlue)),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildModuleTile(
            number: '1',
            title: 'Introduction to iPhone Hardware',
            subtitle: '5 Lessons • 1h 20m',
            status: 'Completed',
            statusColor: Colors.green,
            isExpanded: false,
            children: [],
          ),
          const SizedBox(height: 12),
          _buildModuleTile(
            number: '2',
            title: 'iPhone Disassembly & Assembly',
            subtitle: '7 Lessons • 2h 10m',
            status: 'Completed',
            statusColor: Colors.green,
            isExpanded: false,
            children: [],
          ),
          const SizedBox(height: 12),
          _buildModuleTile(
            number: '3',
            title: 'Display Unit Repair',
            subtitle: '10 Lessons • 6h 30m',
            status: '70%',
            statusColor: AppColors.primaryBlue,
            isExpanded: true,
            children: [
              _buildLessonItem('3.1 Introduction to Display Unit', '08:45', true, false),
              _buildLessonItem('3.2 Display Light Problem Diagnosis', '18:20', true, false),
              _buildLessonItem('3.3 Display Replacement Process', '22:15', true, true), // Active
              _buildLessonItem('3.4 True Tone & Display IC', '16:40', false, false), // Locked
              _buildLessonItem('3.5 Practical: Display Repair', '45:30', false, false), // Locked
            ],
          ),
          const SizedBox(height: 12),
          _buildModuleTile(
            number: '4',
            title: 'Battery & Charging System',
            subtitle: '6 Lessons • 3h 40m',
            status: '40%',
            statusColor: AppColors.primaryBlue,
            isExpanded: false,
            children: [],
          ),
          const SizedBox(height: 12),
          _buildModuleTile(
            number: '5',
            title: 'Board Level Troubleshooting',
            subtitle: '15 Lessons • 12h 50m',
            status: '0%',
            statusColor: AppColors.primaryBlue,
            isExpanded: false,
            children: [],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildLiveClassesTab() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: const [
            Icon(Icons.podcasts, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('No live classes scheduled for this course.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingsTab() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: const [
            Icon(Icons.videocam_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('No recordings available.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildResourcesTab() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: const [
            Icon(Icons.description_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('No resources uploaded yet.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleTile({
    required String number,
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
    required bool isExpanded,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isExpanded ? Colors.blue.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isExpanded ? Colors.blue.withValues(alpha: 0.2) : Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                  child: Center(child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.grey.shade600),
              ],
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 32, right: 16, bottom: 16),
              child: Column(children: children),
            ),
        ],
      ),
    );
  }

  Widget _buildLessonItem(String title, String duration, bool isUnlocked, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isUnlocked ? (isActive ? Icons.play_circle_fill : Icons.check_circle_outline) : Icons.radio_button_unchecked,
            color: isActive ? AppColors.primaryBlue : (isUnlocked ? Colors.green : Colors.grey.shade300),
            size: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? AppColors.primaryBlue : (isUnlocked ? AppColors.textDark : AppColors.textLight),
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(duration, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
          const SizedBox(width: 12),
          Icon(
            isUnlocked ? Icons.play_circle_outline : Icons.lock_outline,
            color: isActive ? AppColors.primaryBlue : Colors.grey.shade400,
            size: 16,
          ),
        ],
      ),
    );
  }
}
