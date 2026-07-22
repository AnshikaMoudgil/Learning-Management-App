import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../widgets/share_bottom_sheet.dart';
import '../services/my_course_service.dart';

class CourseProgressScreen extends StatefulWidget {
  final String? courseId;
  const CourseProgressScreen({Key? key, this.courseId}) : super(key: key);

  @override
  State<CourseProgressScreen> createState() => _CourseProgressScreenState();
}

class _CourseProgressScreenState extends State<CourseProgressScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Future<MyCourseContent>? _courseContentFuture;
  final _myCourseService = MyCourseService();
  final Set<String> _expandedSectionIds = {};
  
  // Filters
  String _liveFilter = 'All'; // All, Upcoming, Live, Completed
  String _recordingFilter = 'All'; // All, or Section ID
  String _resourceFilter = 'All'; // All, PDF, ZIP, Images, Documents, Slides

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _loadCourseContent();
  }

  void _loadCourseContent() {
    if (widget.courseId != null) {
      setState(() {
        _courseContentFuture = _myCourseService.getCourseContent(widget.courseId!);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _toggleLessonCompletion(String lessonId, bool currentStatus) async {
    if (widget.courseId == null) return;
    try {
      final res = await _myCourseService.toggleLessonProgress(
        widget.courseId!,
        lessonId,
        !currentStatus,
      );
      // Reload course content to update UI state
      _loadCourseContent();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(!currentStatus ? 'Lesson marked as completed!' : 'Lesson marked as incomplete'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update progress: $e')),
        );
      }
    }
  }

  Future<void> _launchUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.courseId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Course Progress')),
        body: const Center(child: Text('No Course ID provided')),
      );
    }

    return FutureBuilder<MyCourseContent>(
      future: _courseContentFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Failed to load course content: ${snapshot.error}', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _loadCourseContent, child: const Text('Retry')),
                ],
              ),
            ),
          );
        }
        final content = snapshot.data;
        if (content == null) {
          return const Scaffold(body: Center(child: Text('No data found')));
        }

        final progress = content.enrollment.progressPercent / 100.0;
        final totalLessons = content.sections.fold<int>(0, (sum, sec) => sum + sec.totalLessons);
        final completedLessons = content.sections.fold<int>(0, (sum, sec) => sum + sec.completedLessons);

        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              // Header Hero
              SliverAppBar(
                expandedHeight: 220,
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
                      courseName: content.title,
                      url: 'https://app.skilltech.com/courses/${content.courseId}',
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (content.thumbnailUrl != null)
                        NetworkImage(content.thumbnailUrl!) != null
                            ? Image.network(content.thumbnailUrl!, fit: BoxFit.cover)
                            : Image.asset('assets/iphone_hardware.png', fit: BoxFit.cover)
                      else
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
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(12)),
                              child: Text(content.enrollment.status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              content.title,
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
                      offset: const Offset(0, -10),
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
                                          value: progress,
                                          strokeWidth: 6,
                                          backgroundColor: Colors.grey.shade200,
                                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                                        ),
                                      ),
                                      Text('${content.enrollment.progressPercent}%', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                                    ],
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Course Progress', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 14)),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Text("You've completed ", style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                                            Text('$completedLessons of $totalLessons ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                                            const Text('lessons', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        LinearProgressIndicator(
                                          value: progress,
                                          backgroundColor: Colors.grey.shade200,
                                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                                          minHeight: 4,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ],
                                    ),
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
                      labelColor: AppColors.primaryBlue,
                      unselectedLabelColor: AppColors.textLight,
                      indicatorColor: AppColors.primaryBlue,
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                      tabs: const [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Icon(Icons.dashboard_outlined, size: 16), SizedBox(width: 4), Text('Modules')],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Icon(Icons.podcasts, size: 16), SizedBox(width: 4), Text('Live Classes')],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Icon(Icons.videocam_outlined, size: 16), SizedBox(width: 4), Text('Recordings')],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Icon(Icons.description_outlined, size: 16), SizedBox(width: 4), Text('Resources')],
                          ),
                        ),
                      ],
                    ),
                    
                    // Tab Content
                    _buildTabContent(content),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabContent(MyCourseContent content) {
    switch (_tabController.index) {
      case 0:
        return _buildModulesTab(content);
      case 1:
        return _buildLiveClassesTab(content);
      case 2:
        return _buildRecordingsTab(content);
      case 3:
        return _buildResourcesTab(content);
      default:
        return const SizedBox();
    }
  }

  // ─── Modules Tab ───────────────────────────────────────────────────────────
  Widget _buildModulesTab(MyCourseContent content) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Modules', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
              GestureDetector(
                onTap: () {
                  final unlockedIds = content.sections.where((s) => s.isUnlocked).map((s) => s.id).toSet();
                  setState(() {
                    if (_expandedSectionIds.length >= unlockedIds.length) {
                      _expandedSectionIds.clear();
                    } else {
                      _expandedSectionIds.addAll(unlockedIds);
                    }
                  });
                },
                child: Text(
                  _expandedSectionIds.length >= content.sections.where((s) => s.isUnlocked).length ? 'Collapse All' : 'Expand All',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryBlue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: content.sections.length,
            itemBuilder: (context, index) {
              final section = content.sections[index];
              final isExpanded = _expandedSectionIds.contains(section.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildModuleTile(
                  number: '${index + 1}',
                  section: section,
                  isExpanded: isExpanded,
                  onToggle: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedSectionIds.remove(section.id);
                      } else {
                        _expandedSectionIds.add(section.id);
                      }
                    });
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModuleTile({
    required String number,
    required MyCourseSection section,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    final isLocked = !section.isUnlocked;

    return Container(
      decoration: BoxDecoration(
        color: isLocked ? Colors.grey.withValues(alpha: 0.05) : (isExpanded ? Colors.blue.withValues(alpha: 0.03) : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLocked
              ? Colors.grey.shade300
              : (isExpanded ? Colors.blue.withValues(alpha: 0.15) : Colors.grey.shade200),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: isLocked ? null : onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isLocked ? Colors.grey : AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isLocked
                          ? const Icon(Icons.lock, color: Colors.white, size: 12)
                          : Text(number, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isLocked ? AppColors.textLight : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${section.totalLessons} Lessons • ${section.completedLessons} Completed',
                          style: TextStyle(fontSize: 10, color: isLocked ? Colors.grey.shade300 : AppColors.textLight),
                        ),
                      ],
                    ),
                  ),
                  if (isLocked)
                    const Icon(Icons.lock_outline, color: AppColors.textLight, size: 16)
                  else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('${section.progressPercent}%', style: const TextStyle(color: AppColors.primaryBlue, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.grey.shade600),
                  ],
                ],
              ),
            ),
          ),
          if (isExpanded && !isLocked) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (section.lessons.isEmpty && section.liveClasses.isEmpty && section.resources.isEmpty)
                    const Text('No content in this module', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                  ...section.lessons.map((lesson) => _buildLessonItem(lesson)),
                  ...section.liveClasses.map((liveClass) => _buildLiveClassModuleItem(liveClass)),
                  ...section.resources.map((resource) => _buildResourceModuleItem(resource)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLessonItem(MyCourseLesson lesson) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Checkbox(
            value: lesson.isCompleted,
            activeColor: Colors.green,
            onChanged: (val) => _toggleLessonCompletion(lesson.id, lesson.isCompleted),
          ),
          const Icon(Icons.play_circle_outline, color: AppColors.primaryBlue, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    decoration: lesson.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (lesson.videoDuration != null)
                  Text(lesson.videoDuration!, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow, color: AppColors.primaryBlue),
            onPressed: () => context.push('/recorded-player?lessonId=${lesson.id}&courseId=${widget.courseId}'),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveClassModuleItem(MyLiveClassItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 48),
          const Icon(Icons.podcasts, color: Colors.orange, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item.title} (Live Class)', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                Text(
                  '${item.startTime.day}/${item.startTime.month} • ${item.status.toUpperCase()}',
                  style: const TextStyle(fontSize: 10, color: AppColors.textLight),
                ),
              ],
            ),
          ),
          if (item.status == 'live' && item.joinUrl != null)
            ElevatedButton(
              onPressed: () => _launchUrl(item.joinUrl),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
              child: const Text('Join', style: TextStyle(color: Colors.white, fontSize: 11)),
            ),
        ],
      ),
    );
  }

  Widget _buildResourceModuleItem(MyResourceItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 48),
          const Icon(Icons.description_outlined, color: Colors.purple, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
                if (item.fileSize != null)
                  Text(item.fileSize!, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: AppColors.primaryBlue),
            onPressed: () => _launchUrl(item.fileUrl),
          ),
        ],
      ),
    );
  }

  // ─── Live Classes Tab ──────────────────────────────────────────────────────
  Widget _buildLiveClassesTab(MyCourseContent content) {
    final filtered = content.allLiveClasses.where((item) {
      if (_liveFilter == 'All') return true;
      if (_liveFilter == 'Upcoming') {
        return item.status == 'scheduled' && item.startTime.isAfter(DateTime.now());
      }
      return item.status.toLowerCase() == _liveFilter.toLowerCase();
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Upcoming', 'Live', 'Completed'].map((filter) {
                final isSelected = _liveFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _liveFilter = filter),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No Live Classes found for filter', style: TextStyle(color: AppColors.textLight))))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.sectionTitle != null)
                              Text(item.sectionTitle!, style: const TextStyle(fontSize: 10, color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                            Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.person_outline, size: 12, color: AppColors.textLight),
                                const SizedBox(width: 4),
                                Text(item.instructorName ?? 'MBT Faculty', style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 12, color: AppColors.textLight),
                                const SizedBox(width: 4),
                                Text('${item.startTime.day}/${item.startTime.month} at ${item.startTime.hour}:${item.startTime.minute.toString().padLeft(2, '0')} (${item.duration} mins)', style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: item.status == 'live' ? Colors.red.withValues(alpha: 0.1) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(item.status.toUpperCase(), style: TextStyle(color: item.status == 'live' ? Colors.red : AppColors.textLight, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          if (item.status == 'live' && item.joinUrl != null) ...[
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => _launchUrl(item.joinUrl),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                              child: const Text('Join', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                          ]
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ─── Recordings Tab ────────────────────────────────────────────────────────
  Widget _buildRecordingsTab(MyCourseContent content) {
    final filtered = content.allRecordings.where((item) {
      if (_recordingFilter == 'All') return true;
      return item.sectionId == _recordingFilter;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('All Modules'),
                    selected: _recordingFilter == 'All',
                    onSelected: (val) => setState(() => _recordingFilter = 'All'),
                  ),
                ),
                ...content.sections.map((section) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(section.title),
                      selected: _recordingFilter == section.id,
                      onSelected: (val) => setState(() => _recordingFilter = section.id),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No recordings found', style: TextStyle(color: AppColors.textLight))))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      // Thumbnail or Placeholder
                      Container(
                        width: 100,
                        height: 65,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: item.thumbnailUrl != null
                                ? NetworkImage(item.thumbnailUrl!) as ImageProvider
                                : const AssetImage('assets/android_hardware.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: item.duration != null
                            ? Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  margin: const EdgeInsets.all(4),
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(4)),
                                  child: Text('${(item.duration! / 60).toStringAsFixed(0)}m', style: const TextStyle(color: Colors.white, fontSize: 8)),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.sectionTitle != null)
                              Text(item.sectionTitle!, style: const TextStyle(fontSize: 10, color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                            Text(item.title ?? 'Class Recording', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text('Recorded: ${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}', style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.play_circle_outline, color: AppColors.primaryBlue, size: 28),
                        onPressed: () => context.push('/recorded-player?url=${Uri.encodeComponent(item.r2Url ?? "")}'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ─── Resources Tab ─────────────────────────────────────────────────────────
  Widget _buildResourcesTab(MyCourseContent content) {
    final filtered = content.allResources.where((item) {
      if (_resourceFilter == 'All') return true;
      final type = item.fileType?.toLowerCase() ?? '';
      if (_resourceFilter == 'PDF') return type.contains('pdf');
      if (_resourceFilter == 'ZIP') return type.contains('zip') || type.contains('rar');
      if (_resourceFilter == 'Images') return type.contains('png') || type.contains('jpg') || type.contains('jpeg');
      if (_resourceFilter == 'Documents') return type.contains('doc') || type.contains('txt');
      if (_resourceFilter == 'Slides') return type.contains('ppt') || type.contains('slide');
      return true;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'PDF', 'ZIP', 'Images', 'Documents', 'Slides'].map((filter) {
                final isSelected = _resourceFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _resourceFilter = filter),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No resources found matching filter', style: TextStyle(color: AppColors.textLight))))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                IconData typeIcon = Icons.insert_drive_file;
                Color typeColor = Colors.grey;

                final type = item.fileType?.toLowerCase() ?? '';
                if (type.contains('pdf')) {
                  typeIcon = Icons.picture_as_pdf;
                  typeColor = Colors.red;
                } else if (type.contains('zip') || type.contains('rar')) {
                  typeIcon = Icons.folder_zip;
                  typeColor = Colors.amber;
                } else if (type.contains('png') || type.contains('jpg') || type.contains('jpeg')) {
                  typeIcon = Icons.image;
                  typeColor = Colors.green;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: Icon(typeIcon, color: typeColor, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                            const SizedBox(height: 4),
                            Text(
                              item.fileSize ?? 'Unknown size',
                              style: const TextStyle(fontSize: 10, color: AppColors.textLight),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.file_download_outlined, color: AppColors.primaryBlue),
                        onPressed: () => _launchUrl(item.fileUrl),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
