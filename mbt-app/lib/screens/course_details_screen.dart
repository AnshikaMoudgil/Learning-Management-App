import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../widgets/share_bottom_sheet.dart';
import '../models/course.dart';
import '../models/payment.dart';
import '../services/course_service.dart';
import '../services/payment_service.dart';

class CourseDetailsScreen extends StatefulWidget {
  final String? courseId;

  const CourseDetailsScreen({Key? key, this.courseId}) : super(key: key);

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final Future<Course>? _courseFuture;
  final _courseService = CourseService();
  final _paymentService = PaymentService();
  final _couponController = TextEditingController();
  bool _isCheckingOut = false;
  String? _checkoutMessage;

  @override
  void initState() {
    super.initState();
    _courseFuture = widget.courseId == null ? null : _courseService.getCourseDetails(widget.courseId!);
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Course Details', style: TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share, color: AppColors.textDark),
            onPressed: () => ShareUtils.showShareBottomSheet(
              context,
              courseName: 'Mobile IC Repair Complete Course',
              url: 'https://app.skilltech.com/courses/mobile-ic-repair',
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: widget.courseId == null
          ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            // Header Image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage('assets/iphone_software.png'), // Placeholder
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.blue.shade700, borderRadius: BorderRadius.circular(4)),
                        child: const Text('BESTSELLER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(20)),
                        child: const Text('Edit Progress', style: TextStyle(fontSize: 10, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Details Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mobile IC Repair Complete Course', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  
                  // Progress and Certificate status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('65% completed', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                            const SizedBox(height: 8),
                            Stack(
                              children: [
                                Container(height: 6, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(3))),
                                Container(height: 6, width: 200, decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(3))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.lock_outline, color: Colors.green.shade700, size: 16),
                            const SizedBox(width: 4),
                            Text('Certificate\nLocked', style: TextStyle(fontSize: 10, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Tabs
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primaryBlue,
              unselectedLabelColor: AppColors.textLight,
              indicatorColor: AppColors.primaryBlue,
              indicatorWeight: 3,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Live Classes'),
                Tab(text: 'Recordings'),
                Tab(text: 'Resources'),
              ],
            ),
            const SizedBox(height: 24),

            // Tab Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildCurrentTabContent(),
            ),
            const SizedBox(height: 40),
                ],
              ),
            )
          : FutureBuilder<Course>(
              future: _courseFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(snapshot.error.toString(), textAlign: TextAlign.center),
                    ),
                  );
                }
                return _buildDynamicCourseBody(snapshot.data!);
              },
            ),
    );
  }

  Widget _buildDynamicCourseBody(Course course) {
    final enrolled = course.enrollment?.isEnrolled ?? false;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: course.thumbnailUrl == null
                    ? const AssetImage('assets/iphone_software.png')
                    : NetworkImage(course.thumbnailUrl!) as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(course.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 8),
          Text(course.shortDescription ?? course.description ?? '', style: const TextStyle(fontSize: 14, color: AppColors.textLight, height: 1.5)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCourseBadge(Icons.access_time, course.estimatedDuration ?? 'Self paced'),
              _buildCourseBadge(Icons.play_lesson_outlined, '${course.totalLessons} Lessons'),
            ],
          ),
          const SizedBox(height: 20),
          if (course.learningOutcomes.isNotEmpty) ...[
            const Text('What you\'ll learn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 12),
            ...course.learningOutcomes.map(_buildCheckListItem),
            const SizedBox(height: 20),
          ],
          const Text('Course Content', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 12),
          ...course.sections.map(_buildSectionExpansion),
          const SizedBox(height: 24),
          if (!enrolled) _buildCheckoutPanel(course) else _buildResumePanel(course),
        ],
      ),
    );
  }

  Widget _buildSectionExpansion(CourseSection section) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ExpansionTile(
        title: Text(section.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        children: section.lessons.map((lesson) {
          final locked = lesson.videoUrl == null && !lesson.isFreePreview;
          return ListTile(
            dense: true,
            leading: Icon(locked ? Icons.lock_outline : Icons.play_circle_outline, color: locked ? Colors.grey : AppColors.primaryBlue),
            title: Text(lesson.title, style: const TextStyle(fontSize: 13)),
            subtitle: lesson.videoDuration == null ? null : Text(lesson.videoDuration!, style: const TextStyle(fontSize: 11)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCheckoutPanel(Course course) {
    final price = course.effectivePrice;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Course price', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
              Text('₹${price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark)),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _couponController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Coupon code',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          if (_checkoutMessage != null) ...[
            const SizedBox(height: 10),
            Text(_checkoutMessage!, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isCheckingOut ? null : () => _checkout(course),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isCheckingOut
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Buy Course', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumePanel(Course course) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => context.push('/course-progress'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Resume Learning', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _checkout(Course course) async {
    setState(() {
      _isCheckingOut = true;
      _checkoutMessage = null;
    });
    try {
      final result = await _paymentService.checkoutCourse(
        courseId: course.id,
        courseTitle: course.title,
        couponCode: _couponController.text,
      );
      if (!mounted) return;
      context.push(
        '/payment-success?courseTitle=${Uri.encodeComponent(course.title)}&orderId=${Uri.encodeComponent(result.order.orderId)}',
      );
    } on PaymentPendingException catch (error) {
      if (!mounted) return;
      context.push(
        '/payment-success?status=pending&courseTitle=${Uri.encodeComponent(course.title)}&orderId=${Uri.encodeComponent(error.order.orderId)}',
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _checkoutMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingOut = false;
        });
      }
    }
  }

  Widget _buildCurrentTabContent() {
    switch (_tabController.index) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildLiveClassesTab();
      case 2:
        return _buildRecordingsTab();
      case 3:
        return _buildResourcesTab();
      default:
        return const SizedBox();
    }
  }

  Widget _buildOverviewTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('About this course', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        const SizedBox(height: 12),
        const Text(
          'Learn the complete mobile IC repair process from basics to advanced level. This course covers all important topics with practical examples.',
          style: TextStyle(fontSize: 14, color: AppColors.textLight, height: 1.5),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {},
          child: const Text('Read more', style: TextStyle(color: AppColors.primaryBlue, fontSize: 14, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 24),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCourseBadge(Icons.access_time, '35 Hours'),
            _buildCourseBadge(Icons.play_lesson_outlined, '120 Lessons'),
            _buildCourseBadge(Icons.workspace_premium_outlined, 'Certificate'),
          ],
        ),
        const SizedBox(height: 24),
        
        // Progress Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade100),
          ),
          child: Row(
            children: [
              Icon(Icons.military_tech_outlined, color: Colors.green.shade600, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Complete remaining 42 lessons to unlock your certificate', style: TextStyle(fontSize: 12, color: Colors.green.shade800)),
              )
            ],
          ),
        ),
        const SizedBox(height: 24),

        const Text('What you\'ll learn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        const SizedBox(height: 12),
        _buildCheckListItem('Identify and test mobile ICs'),
        _buildCheckListItem('Advanced soldering techniques'),
        _buildCheckListItem('Fault finding and troubleshooting'),
        _buildCheckListItem('IC replacement and reballing'),
      ],
    );
  }

  Widget _buildLiveClassesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Upcoming Live Classes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        const SizedBox(height: 16),
        _buildLiveClassCard('14', 'Wed', 'Power IC Section - Deep Dive', 'Mr. Ankit Verma', '07:00 PM - 08:30 PM'),
        _buildLiveClassCard('17', 'Sat', 'CPU Reballing Techniques', 'Mr. Rahul Sharma', '07:00 PM - 08:30 PM'),
        _buildLiveClassCard('21', 'Wed', 'Advanced Fault Finding', 'Mr. Sonu Singh', '07:00 PM - 08:30 PM'),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('View Full Schedule', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                SizedBox(width: 4),
                Icon(Icons.chevron_right, color: AppColors.primaryBlue, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveClassCard(String date, String day, String title, String instructor, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date box
          Column(
            children: [
              Text('MAY', style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
              Text(date, style: const TextStyle(fontSize: 20, color: AppColors.textDark, fontWeight: FontWeight.bold)),
              Text(day, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
            ],
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 60, color: Colors.grey.shade200),
          const SizedBox(width: 16),
          // Details
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
                    Text(instructor, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
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
          // Join Button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () => context.push('/live-player'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: const Size(60, 36),
                padding: EdgeInsets.zero,
              ),
              child: const Text('Join', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Course Recordings (120)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        const SizedBox(height: 16),
        _buildRecordingCard('Introduction to Mobile IC Repair', '32:45', 'Mr. Ankit Verma', '12 May 2025'),
        _buildRecordingCard('Basic Tools & Equipment', '26:10', 'Mr. Ankit Verma', '13 May 2025'),
        _buildRecordingCard('Components Identification', '36:20', 'Mr. Rahul Sharma', '14 May 2025'),
        _buildRecordingCard('Schematic Reading Basics', '29:15', 'Mr. Rahul Sharma', '15 May 2025'),
      ],
    );
  }

  Widget _buildRecordingCard(String title, String duration, String instructor, String date) {
    return GestureDetector(
      onTap: () => context.push('/recorded-player'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 100,
              height: 65,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: const DecorationImage(
                  image: AssetImage('assets/android_hardware.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(4)),
                  child: Text(duration, style: const TextStyle(color: Colors.white, fontSize: 8)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(instructor, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                  const SizedBox(height: 2),
                  Text(date, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.file_download_outlined, color: AppColors.primaryBlue),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourcesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Course Resources', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        const SizedBox(height: 16),
        _buildResourceCard('Mobile IC Repair - Complete Notes.pdf', '2.4 MB', Icons.picture_as_pdf, Colors.red),
        _buildResourceCard('Power IC Section - Handwritten Notes.pdf', '1.8 MB', Icons.picture_as_pdf, Colors.blue),
        _buildResourceCard('Circuit Diagram Reference.pdf', '3.2 MB', Icons.grid_on, Colors.green),
        _buildResourceCard('IC Datasheet Collection.zip', '12.5 MB', Icons.folder_zip, Colors.amber),
        _buildResourceCard('Common Faults & Solutions.pdf', '2.1 MB', Icons.picture_as_pdf, Colors.red),
        
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(8)),
          child: const Text(
            'Resources are provided for personal learning only and cannot be shared or redistributed.',
            style: TextStyle(fontSize: 10, color: Colors.indigo),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildResourceCard(String title, String size, IconData icon, Color iconColor) {
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
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text(size, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: AppColors.primaryBlue),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCourseBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textDark),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textDark, fontWeight: FontWeight.bold)),
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
          const Icon(Icons.check_circle, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: AppColors.textDark))),
        ],
      ),
    );
  }
}
