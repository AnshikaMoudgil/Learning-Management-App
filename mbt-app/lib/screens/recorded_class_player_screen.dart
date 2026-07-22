import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../widgets/watermarked_video_player.dart';
import '../services/my_course_service.dart';

class RecordedClassPlayerScreen extends StatefulWidget {
  final String? lessonId;
  final String? url;
  final String? courseId;
  const RecordedClassPlayerScreen({Key? key, this.lessonId, this.url, this.courseId}) : super(key: key);

  @override
  State<RecordedClassPlayerScreen> createState() => _RecordedClassPlayerScreenState();
}

class _RecordedClassPlayerScreenState extends State<RecordedClassPlayerScreen> {
  final MyCourseService _courseService = MyCourseService();
  List<MyCourseLesson> _allLessons = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    if (widget.courseId == null || widget.lessonId == null) return;
    try {
      final content = await _courseService.getCourseContent(widget.courseId!);
      final flat = <MyCourseLesson>[];
      for (final sec in content.sections) {
        flat.addAll(sec.lessons);
      }
      final idx = flat.indexWhere((l) => l.id == widget.lessonId);
      if (!mounted) return;
      setState(() {
        _allLessons = flat;
        _currentIndex = idx >= 0 ? idx : 0;
      });
    } catch (_) {}
  }

  MyCourseLesson? get _currentLesson =>
      _allLessons.isNotEmpty ? _allLessons[_currentIndex] : null;

  Future<void> _markComplete() async {
    final lesson = _currentLesson;
    if (lesson == null || widget.courseId == null) return;
    try {
      await _courseService.toggleLessonProgress(
        widget.courseId!, lesson.id, !lesson.isCompleted,
      );
      if (!mounted) return;
      setState(() {
        _allLessons[_currentIndex] = MyCourseLesson(
          id: lesson.id, sectionId: lesson.sectionId,
          title: lesson.title, description: lesson.description,
          videoUrl: lesson.videoUrl, videoDuration: lesson.videoDuration,
          isFreePreview: lesson.isFreePreview, sortOrder: lesson.sortOrder,
          isCompleted: !lesson.isCompleted, watchedSeconds: lesson.watchedSeconds,
        );
      });
    } catch (_) {}
  }

  void _goPrevious() {
    if (_currentIndex > 0) {
      final prev = _allLessons[_currentIndex - 1];
      context.pushReplacement('/recorded-player?lessonId=${prev.id}&courseId=${widget.courseId}');
    }
  }

  void _goNext() {
    if (_currentIndex < _allLessons.length - 1) {
      final next = _allLessons[_currentIndex + 1];
      context.pushReplacement('/recorded-player?lessonId=${next.id}&courseId=${widget.courseId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildVideoPlayer(context),
            _buildVideoSettingsRow(context),
            const Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomControls(),
    );
  }

  Widget _buildVideoPlayer(BuildContext context) {
    if (widget.lessonId != null) {
      return SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.width * 9 / 16,
        child: WatermarkedVideoPlayer(lessonId: widget.lessonId!),
      );
    }

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
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Display Light Problem Diagnosis', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, overflow: TextOverflow.ellipsis)),
                      const Text('iPhone Hardware Course', style: TextStyle(color: Colors.white70, fontSize: 10)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                            child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)),
                            child: const Text('RECORDED', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.notes, color: Colors.white, size: 20),
                    SizedBox(height: 2),
                    Text('Notes', style: TextStyle(color: Colors.white, fontSize: 10)),
                  ],
                ),
                const SizedBox(width: 16),
                const Icon(Icons.more_vert, color: Colors.white, size: 20),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  height: 3,
                  width: double.infinity,
                  color: Colors.white24,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 150,
                    color: Colors.red,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.pause, color: Colors.white, size: 20),
                      const SizedBox(width: 16),
                      const Icon(Icons.replay_10, color: Colors.white, size: 20),
                      const SizedBox(width: 16),
                      const Icon(Icons.forward_10, color: Colors.white, size: 20),
                      const SizedBox(width: 16),
                      const Text('18:42 / 58:24', style: TextStyle(color: Colors.white, fontSize: 11)),
                      const Spacer(),
                      const Icon(Icons.volume_up_outlined, color: Colors.white, size: 20),
                      const SizedBox(width: 16),
                      const Icon(Icons.closed_caption_outlined, color: Colors.white, size: 20),
                      const SizedBox(width: 16),
                      const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
                      const SizedBox(width: 16),
                      const Icon(Icons.fullscreen, color: Colors.white, size: 20),
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

  Widget _buildVideoSettingsRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(child: _buildSettingButton(Icons.translate, 'Language', 'English', () => _showLanguageModal(context))),
          Container(width: 1, height: 30, color: AppColors.border),
          Expanded(child: _buildSettingButton(Icons.closed_caption_outlined, 'Subtitles', 'English', () => _showSubtitlesModal(context))),
          Container(width: 1, height: 30, color: AppColors.border),
          Expanded(child: _buildSettingButton(Icons.speed, 'Playback Speed', '1.25x', () {})),
        ],
      ),
    );
  }

  Widget _buildSettingButton(IconData icon, String title, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.textLight),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textDark, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Text(value, style: const TextStyle(fontSize: 10, color: AppColors.primaryBlue, fontWeight: FontWeight.w500)),
                    const Icon(Icons.keyboard_arrow_down, size: 12, color: AppColors.primaryBlue),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child:               OutlinedButton.icon(
                onPressed: _currentIndex > 0 ? _goPrevious : null,
                icon: const Icon(Icons.chevron_left, size: 16, color: AppColors.primaryBlue),
                label: const Text('Previous Lesson', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _currentLesson != null ? _markComplete : null,
                icon: Icon(
                  _currentLesson?.isCompleted == true
                      ? Icons.check_circle
                      : Icons.check_circle_outline,
                  size: 16, color: AppColors.primaryBlue,
                ),
                label: Text(
                  _currentLesson?.isCompleted == true
                      ? 'Completed'
                      : 'Mark as Complete',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: _currentIndex < _allLessons.length - 1 ? _goNext : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Next Lesson', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    SizedBox(width: 4),
                    Icon(Icons.chevron_right, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildLanguageBottomSheet(),
    );
  }

  Widget _buildLanguageBottomSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 8),
          const Text('Choose your preferred audio language', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
          const SizedBox(height: 24),
          _buildLanguageOption('Original (English)', 'Original Audio', 'Audio in the original language', true),
          _buildLanguageOption('Hindi', 'Dubbed', 'हिंदी में डब किया गया ऑडियो', false),
          _buildLanguageOption('English', 'Dubbed', 'Audio in English', false),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.lightBlueBg, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: const [
                Icon(Icons.info_outline, size: 16, color: AppColors.textDark),
                SizedBox(width: 8),
                Expanded(child: Text('Subtitles will change automatically based on the selected language.', style: TextStyle(fontSize: 11, color: AppColors.textDark))),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String title, String badge, String subtitle, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? AppColors.border : Colors.transparent),
        boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))] : [],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
                      child: Text(badge, style: const TextStyle(fontSize: 9, color: AppColors.textLight)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
              ],
            ),
          ),
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: isSelected ? AppColors.primaryBlue : AppColors.border,
            size: 20,
          ),
        ],
      ),
    );
  }

  void _showSubtitlesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSubtitlesBottomSheet(),
    );
  }

  Widget _buildSubtitlesBottomSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Subtitles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 24),
          _buildSubtitleOption(Icons.closed_caption, 'English', 'Default', 'Original language subtitles', true, Colors.blue),
          _buildSubtitleOption(Icons.translate, 'Hindi', '', 'हिंदी उपशीर्षक', false, Colors.green),
          _buildSubtitleOption(Icons.closed_caption, 'English (SDH)', '', 'English subtitles for the deaf and hard of hearing', false, Colors.purple),
          _buildSubtitleOption(Icons.translate, 'Hindi (SDH)', '', 'हिंदी उपशीर्षक (बधिर और सुनने में कठिनाई वाले लोगों के लिए)', false, Colors.orange),
          _buildSubtitleOption(Icons.cancel_outlined, 'Off', '', 'Turn off subtitles', false, Colors.grey),
          
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Subtitle Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark)),
                    SizedBox(height: 4),
                    Text('Customize subtitle appearance', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                  ],
                ),
                const Icon(Icons.chevron_right, color: AppColors.textDark),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.lightBlueBg, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: const [
                Icon(Icons.info_outline, size: 16, color: AppColors.textDark),
                SizedBox(width: 8),
                Expanded(child: Text('Subtitles may not be available for some languages in this video.', style: TextStyle(fontSize: 11, color: AppColors.textDark))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.close, size: 16, color: AppColors.textDark),
              label: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSubtitleOption(IconData icon, String title, String badge, String subtitle, bool isSelected, Color iconBgColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconBgColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconBgColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
                    if (badge.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.lightBlueBg, borderRadius: BorderRadius.circular(12)),
                        child: Text(badge, style: const TextStyle(fontSize: 9, color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
              ],
            ),
          ),
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: isSelected ? AppColors.primaryBlue : AppColors.border,
            size: 20,
          ),
        ],
      ),
    );
  }
}
