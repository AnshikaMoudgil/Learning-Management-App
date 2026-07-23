import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../services/enrollments_service.dart';
import '../services/notification_service.dart';

class CourseFilters {
  final List<String> statuses;
  final List<String> instructors;
  final List<String> expiries;

  CourseFilters({
    this.statuses = const [],
    this.instructors = const [],
    this.expiries = const [],
  });
}

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({Key? key}) : super(key: key);

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final EnrollmentsService _enrollmentsService = EnrollmentsService();
  final NotificationService _notificationService = NotificationService();
  
  List<EnrollmentItem> _allEnrollments = [];
  bool _isLoading = true;
  String _sortBy = 'Recently Accessed';
  int _unreadNotifications = 0;
  
  CourseFilters? _filtersState;
  CourseFilters get _currentFilters => _filtersState ??= CourseFilters();

  final List<String> _sortOptions = [
    'Recently Accessed',
    'Recently Enrolled',
    'Course Name (A-Z)',
    'Course Name (Z-A)',
    'Progress (Highest First)',
    'Progress (Lowest First)',
    'Newest Added',
    'Oldest Added',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); // trigger rebuild for filtering
      }
    });
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final enrollments = await _enrollmentsService.getMyEnrollments();
      final unreadCount = await _notificationService.getUnreadCount();
      if (mounted) {
        setState(() {
          _allEnrollments = enrollments;
          _unreadNotifications = unreadCount;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int get _inProgressCount => _allEnrollments.where((item) => item.progressPercent > 0 && item.progressPercent < 100).length;
  int get _completedCount => _allEnrollments.where((item) => item.progressPercent == 100).length;
  int get _expiredCount => _allEnrollments.where((item) => item.validityEndAt != null && item.validityEndAt!.isBefore(DateTime.now())).length;

  List<EnrollmentItem> get _filteredAndSortedCourses {
    // 1. Filter by Tab
    List<EnrollmentItem> filtered = _allEnrollments.where((item) {
      if (_tabController.index == 0) return true; // All
      if (_tabController.index == 1) return item.progressPercent > 0 && item.progressPercent < 100; // In Progress
      if (_tabController.index == 2) return item.progressPercent == 100; // Completed
      if (_tabController.index == 3) {
        // Expired
        return item.validityEndAt != null && item.validityEndAt!.isBefore(DateTime.now());
      }
      return true;
    }).toList();

    // 2. Filter by Advanced Filters (Bottom Sheet)
    filtered = filtered.where((item) {
      // Status
      if (_currentFilters.statuses.isNotEmpty && !_currentFilters.statuses.contains('All')) {
        bool matchesStatus = false;
        if (_currentFilters.statuses.contains('Completed') && item.progressPercent == 100) matchesStatus = true;
        if (_currentFilters.statuses.contains('In Progress') && item.progressPercent > 0 && item.progressPercent < 100) matchesStatus = true;
        if (_currentFilters.statuses.contains('Not Started') && item.progressPercent == 0) matchesStatus = true;
        if (_currentFilters.statuses.contains('Expired') && item.validityEndAt != null && item.validityEndAt!.isBefore(DateTime.now())) matchesStatus = true;
        if (!matchesStatus) return false;
      }
      
      // Instructor
      if (_currentFilters.instructors.isNotEmpty) {
        if (!(_currentFilters.instructors.contains(item.instructorName) || (_currentFilters.instructors.contains('Unknown') && item.instructorName == null))) {
          return false;
        }
      }

      // Expiry
      if (_currentFilters.expiries.isNotEmpty) {
        bool matchesExpiry = false;
        final now = DateTime.now();
        if (_currentFilters.expiries.contains('Expired') && item.validityEndAt != null && item.validityEndAt!.isBefore(now)) matchesExpiry = true;
        if (_currentFilters.expiries.contains('Expiring Soon') && item.validityEndAt != null && item.validityEndAt!.isAfter(now) && item.validityEndAt!.difference(now).inDays <= 30) matchesExpiry = true;
        if (_currentFilters.expiries.contains('Active Courses') && (item.validityEndAt == null || item.validityEndAt!.isAfter(now))) matchesExpiry = true;
        if (!matchesExpiry) return false;
      }
      
      return true;
    }).toList();

    // 3. Sort
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'Recently Accessed':
          // TODO: Replace with actual lastAccessedAt when backend supports it
          return b.enrolledAt.compareTo(a.enrolledAt);
        case 'Recently Enrolled':
          return b.enrolledAt.compareTo(a.enrolledAt);
        case 'Course Name (A-Z)':
          return (a.title ?? '').compareTo(b.title ?? '');
        case 'Course Name (Z-A)':
          return (b.title ?? '').compareTo(a.title ?? '');
        case 'Progress (Highest First)':
          return b.progressPercent.compareTo(a.progressPercent);
        case 'Progress (Lowest First)':
          return a.progressPercent.compareTo(b.progressPercent);
        case 'Newest Added':
          // TODO: Replace with courseCreatedAt when backend supports it
          return b.enrolledAt.compareTo(a.enrolledAt);
        case 'Oldest Added':
          // TODO: Replace with courseCreatedAt when backend supports it
          return a.enrolledAt.compareTo(b.enrolledAt);
        default:
          return 0;
      }
    });

    return filtered;
  }

  void _showFilterBottomSheet() {
    final allInstructors = _allEnrollments.map((e) => e.instructorName ?? 'Unknown').toSet().toList();
    allInstructors.sort();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            List<String> tempStatuses = List.from(_currentFilters.statuses);
            List<String> tempInstructors = List.from(_currentFilters.instructors);
            List<String> tempExpiries = List.from(_currentFilters.expiries);

            Widget buildSectionHeader(String title) {
              return Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 12),
                child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              );
            }

            Widget buildCheckboxTile(String title, bool value, ValueChanged<bool?>? onChanged, {bool disabled = false}) {
              return Theme(
                data: ThemeData(unselectedWidgetColor: AppColors.textLight),
                child: CheckboxListTile(
                  title: Row(
                    children: [
                      Text(title, style: TextStyle(color: disabled ? AppColors.textLight : AppColors.textDark, fontSize: 14)),
                      if (disabled) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
                          child: const Text('Coming Soon', style: TextStyle(fontSize: 10, color: AppColors.textLight, fontWeight: FontWeight.bold)),
                        ),
                      ]
                    ],
                  ),
                  value: value,
                  onChanged: disabled ? null : onChanged,
                  activeColor: AppColors.primaryBlue,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                ),
              );
            }

            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              maxChildSize: 0.9,
              minChildSize: 0.5,
              expand: false,
              builder: (_, controller) {
                return Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: AppColors.border)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Filter Courses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    // Scrollable content
                    Expanded(
                      child: ListView(
                        controller: controller,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        children: [
                          buildSectionHeader('1. Course Status'),
                          ...['All', 'In Progress', 'Not Started', 'Completed', 'Expired'].map((status) {
                            return buildCheckboxTile(
                              status,
                              tempStatuses.contains(status),
                              (val) {
                                setModalState(() {
                                  if (val == true) {
                                    if (status == 'All') {
                                      tempStatuses = ['All'];
                                    } else {
                                      tempStatuses.remove('All');
                                      tempStatuses.add(status);
                                    }
                                  } else {
                                    tempStatuses.remove(status);
                                  }
                                });
                              },
                            );
                          }),

                          buildSectionHeader('2. Course Type'),
                          ...['Recorded Courses', 'Live Classes', 'Hybrid Courses'].map((type) => buildCheckboxTile(type, false, null, disabled: true)),

                          if (allInstructors.isNotEmpty) ...[
                            buildSectionHeader('3. Instructor'),
                            ...allInstructors.map((inst) {
                              return buildCheckboxTile(
                                inst,
                                tempInstructors.contains(inst),
                                (val) {
                                  setModalState(() {
                                    if (val == true) {
                                      tempInstructors.add(inst);
                                    } else {
                                      tempInstructors.remove(inst);
                                    }
                                  });
                                },
                              );
                            }),
                          ],

                          buildSectionHeader('4. Category'),
                          ...['Mobile Repair', 'Laptop Repair', 'Hardware', 'Software', 'Networking', 'Electronics'].map((cat) => buildCheckboxTile(cat, false, null, disabled: true)),

                          buildSectionHeader('5. Duration'),
                          ...['Less than 5 hours', '5–10 hours', 'More than 10 hours'].map((dur) => buildCheckboxTile(dur, false, null, disabled: true)),

                          buildSectionHeader('6. Certificates'),
                          ...['Certificate Available', 'Certificate Earned'].map((cert) => buildCheckboxTile(cert, false, null, disabled: true)),

                          buildSectionHeader('7. Language'),
                          ...['English', 'Hindi', 'Punjabi'].map((lang) => buildCheckboxTile(lang, false, null, disabled: true)),

                          buildSectionHeader('8. Expiry'),
                          ...['Active Courses', 'Expiring Soon', 'Expired'].map((exp) {
                            return buildCheckboxTile(
                              exp,
                              tempExpiries.contains(exp),
                              (val) {
                                setModalState(() {
                                  if (val == true) {
                                    tempExpiries.add(exp);
                                  } else {
                                    tempExpiries.remove(exp);
                                  }
                                });
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                    // Footer Actions
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                side: const BorderSide(color: AppColors.primaryBlue),
                              ),
                              onPressed: () {
                              setState(() {
                                _filtersState = CourseFilters();
                              });
                                Navigator.pop(context);
                              },
                              child: const Text('Reset Filters', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                              ),
                              onPressed: () {
                              setState(() {
                                _filtersState = CourseFilters(
                                  statuses: tempStatuses,
                                  instructors: tempInstructors,
                                  expiries: tempExpiries,
                                );
                              });
                                Navigator.pop(context);
                              },
                              child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showCourseActionMenu(EnrollmentItem course) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
              ListTile(
                leading: const Icon(Icons.play_circle_outline, color: AppColors.primaryBlue),
                title: const Text('Continue Learning'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/course-progress?id=${course.courseId}');
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: AppColors.textDark),
                title: const Text('View Course Details'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/course?id=${course.courseId}');
                },
              ),
              ListTile(
                leading: const Icon(Icons.download_outlined, color: AppColors.textDark),
                title: const Text('Download Resources'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading resources...')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined, color: AppColors.textDark),
                title: const Text('Share Course'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Course link copied to clipboard')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: Colors.red),
                title: const Text('Report an Issue', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Issue reported to support')));
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Courses',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textDark),
            onPressed: () => context.push('/search'),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: AppColors.textDark),
                onPressed: () async {
                  await context.push('/notifications');
                  await _notificationService.markAllRead();
                  _loadData();
                },
              ),
              if (_unreadNotifications > 0)
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text('$_unreadNotifications', style: const TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center),
                  ),
                ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.textDark,
          indicatorColor: Colors.transparent,
          dividerColor: Colors.transparent,
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryBlue),
            color: Colors.white,
          ),
          tabs: [
            _buildTab('All (${_allEnrollments.length})'),
            _buildTab('In Progress ($_inProgressCount)'),
            _buildTab('Completed ($_completedCount)'),
            _buildTab('Expired ($_expiredCount)'),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_allEnrollments.isEmpty) {
      return _buildEmptyState();
    }

    return _buildPopulatedState();
  }

  Widget _buildTab(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: const BoxDecoration(
                color: AppColors.lightBlueBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inventory_2_outlined, size: 80, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 24),
            const Text(
              "You haven't purchased any courses yet",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 12),
            const Text(
              'Explore our courses and start your\nlearning journey today.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textLight, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                label: const Text('Explore Store', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                onPressed: () => context.push('/store'),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.push('/store'),
              child: const Text('Browse Free Content', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopulatedState() {
    final coursesToDisplay = _filteredAndSortedCourses;
    
    return Column(
      children: [
        // Sort and Filter Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Text('Sort by: ', style: TextStyle(color: AppColors.textLight, fontSize: 13)),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _sortBy,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textDark),
                        elevation: 16,
                        style: const TextStyle(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.bold),
                        underline: const SizedBox(),
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() => _sortBy = value);
                          }
                        },
                        items: _sortOptions.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(value: value, child: Text(value, overflow: TextOverflow.ellipsis));
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.tune, color: AppColors.textDark, size: 20),
                    onPressed: _showFilterBottomSheet,
                  ),
                  if (_currentFilters.statuses.isNotEmpty || _currentFilters.instructors.isNotEmpty || _currentFilters.expiries.isNotEmpty)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                      ),
                    )
                ],
              ),
            ],
          ),
        ),
        const Divider(color: AppColors.border, height: 1),
        // List of Courses
        Expanded(
          child: coursesToDisplay.isEmpty
              ? const Center(child: Text('No courses found for this filter.', style: TextStyle(color: AppColors.textLight)))
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: coursesToDisplay.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _buildCourseCard(coursesToDisplay[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCourseCard(EnrollmentItem course) {
    bool isCompleted = course.progressPercent == 100;
    
    String? daysLeftText;
    bool isUrgent = false;
    
    if (course.validityEndAt != null) {
      final daysLeft = course.validityEndAt!.difference(DateTime.now()).inDays;
      if (daysLeft >= 0) {
        daysLeftText = '$daysLeft days left';
        isUrgent = daysLeft < 20;
      } else {
        daysLeftText = 'Expired';
        isUrgent = true;
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Container(
            width: 140,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade900,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: course.thumbnailUrl != null
                      ? Image.network(course.thumbnailUrl!, fit: BoxFit.cover)
                      : Image.asset('assets/iphone_hardware.png', fit: BoxFit.cover),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2), // slight darkening
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.green : AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isCompleted ? 'Completed' : 'In Progress',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Content on the right
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        course.title ?? 'Course Title',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark, height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.more_vert, color: AppColors.textLight, size: 20),
                      onPressed: () => _showCourseActionMenu(course),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${course.totalLessons} Lessons',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textLight),
                ),
                const SizedBox(height: 12),
                // Progress
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: course.progressPercent / 100.0,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(isCompleted ? Colors.green : AppColors.primaryBlue),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${course.progressPercent}%',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Validity
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textLight),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          isCompleted
                              ? 'Completed' 
                              : (course.validityEndAt != null ? 'Valid until ${course.validityEndAt!.day}/${course.validityEndAt!.month}/${course.validityEndAt!.year}' : 'Lifetime Access'),
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isCompleted ? Colors.green : AppColors.textLight),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (!isCompleted && daysLeftText != null)
                        Text(
                          daysLeftText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isUrgent ? Colors.red : Colors.green,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: isCompleted
                        ? OutlinedButton.icon(
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Review Again', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryBlue,
                              side: const BorderSide(color: AppColors.primaryBlue),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => context.push('/course-progress?id=${course.courseId}'),
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => context.push('/course-progress?id=${course.courseId}'),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text('Continue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Spacer(),
                                Icon(Icons.play_arrow_outlined, size: 18),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
