import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/api_client.dart';
import '../services/notification_service.dart';
import '../models/session.dart';
import 'home_dashboard.dart';
import 'my_learning_screen.dart';
import 'recent_recordings_screen.dart';
import 'profile_screen.dart';
import 'meeting_screen.dart';
import 'package:go_router/go_router.dart';

class LiveClassesScreen extends StatefulWidget {
  const LiveClassesScreen({Key? key}) : super(key: key);

  @override
  State<LiveClassesScreen> createState() => _LiveClassesScreenState();
}

class _LiveClassesScreenState extends State<LiveClassesScreen> {
  int _selectedTab = 0;
  final ApiClient _api = ApiClient();
  final NotificationService _notificationService = NotificationService();
  List<LiveSession> _sessions = [];
  bool _loading = true;
  String? _error;
  int _unreadNotifications = 0;
  DateTime _calendarMonth = DateTime(DateTime.now().year, DateTime.now().month);
  int? _selectedDay = DateTime.now().day;

  @override
  void initState() {
    super.initState();
    _fetchSessions();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final count = await _notificationService.getUnreadCount();
    if (mounted) setState(() => _unreadNotifications = count);
  }

  Future<void> _openNotifications() async {
    await context.push('/notifications');
    await _notificationService.markAllRead();
    _loadUnreadCount();
  }

  Future<void> _fetchSessions() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.get('/sessions/upcoming');
      final list = (data as List<dynamic>)
          .map((e) => LiveSession.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        _sessions = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _joinSession(LiveSession session) async {
    try {
      final joinData = await _api.post('/sessions/${session.id}/join');
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MeetingScreen(
            meetingNumber: joinData['meeting_number'],
            password: joinData['password'] ?? '',
            joinUrl: joinData['join_url'],
            signature: joinData['signature'],
            displayName: joinData['display_name'],
            zoomAppKey: joinData['zoom_app_key'],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  void _onNavTapped(int index) {
    if (index == 2) return;
    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = const HomeDashboard();
        break;
      case 1:
        nextScreen = const MyLearningScreen();
        break;
      case 3:
        nextScreen = const RecentRecordingsScreen();
        break;
      case 4:
        nextScreen = const ProfileScreen();
        break;
      default:
        return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Live Classes',
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Join live sessions, learn from experts in real-time',
              style: TextStyle(color: AppColors.textLight, fontSize: 10),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textDark),
            onPressed: () => context.push('/search'),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textDark,
                ),
                onPressed: _openNotifications,
              ),
              if (_unreadNotifications > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_unreadNotifications',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                _buildSegmentTab('Upcoming', 0),
                _buildSegmentTab('Calendar', 1),
              ],
            ),
          ),
          Expanded(
            child: _selectedTab == 0
                ? _buildUpcomingView()
                : _buildCalendarView(),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentTab(String label, int index) {
    bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
            border: isSelected
                ? Border.all(color: AppColors.primaryBlue, width: 1.5)
                : Border.all(color: Colors.transparent),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primaryBlue : AppColors.textLight,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.isNegative) return '0min';
    if (d.inDays > 0) return '${d.inDays}day ${d.inHours % 24}hour';
    if (d.inHours > 0) return '${d.inHours}hour ${d.inMinutes % 60}min';
    return '${d.inMinutes}min';
  }

  Color _startsInColor(Duration d) {
    if (d.isNegative) return Colors.grey;
    if (d.inMinutes < 60) return Colors.green;
    if (d.inHours < 24) return AppColors.primaryBlue;
    return AppColors.textDark;
  }

  Widget _buildUpcomingView() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error: $_error', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchSessions,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final todaySessions = _sessions
        .where(
          (s) =>
              s.startTime.day == DateTime.now().day &&
              s.startTime.month == DateTime.now().month &&
              s.startTime.year == DateTime.now().year,
        )
        .toList();
    final upcomingSessions = _sessions
        .where((s) => s.status == 'live' || s.startTime.isAfter(DateTime.now()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Upcoming Live Classes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _selectedTab = 1),
                child: Row(
                  children: const [
                    Icon(
                      Icons.calendar_month,
                      size: 14,
                      color: AppColors.primaryBlue,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Calendar View',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (todaySessions.isNotEmpty)
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildDateSelector(
                  'Today',
                  '${DateTime.now().day} ${_monthAbbr(DateTime.now().month)}',
                  true,
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        if (upcomingSessions.isEmpty)
          const Expanded(
            child: Center(
              child: Text(
                'No upcoming live classes.',
                style: TextStyle(color: AppColors.textLight),
              ),
            ),
          )
        else
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: upcomingSessions.map((session) {
                final diff = session.startTime.difference(DateTime.now());
                final isLive = session.status == 'live';
                final startsIn = isLive
                    ? 'LIVE'
                    : diff.isNegative
                    ? 'Starting soon'
                    : 'Starts in\n${_formatDuration(diff)}';
                final startsInColor = isLive
                    ? Colors.red
                    : _startsInColor(diff);

                return _buildUpcomingClassCard(
                  session: session,
                  startsIn: startsIn,
                  startsInColor: startsInColor,
                  isLiveNow: isLive,
                );
              }).toList(),
            ),
          ),
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.lightBlueBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.event_busy,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Can\'t attend live?',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      'All live classes are recorded. You can watch them anytime in the Recordings section.',
                      style: TextStyle(fontSize: 9, color: AppColors.textLight),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  context.pushReplacement('/recent-recordings');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(color: AppColors.primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 36),
                ),
                child: const Text(
                  'Go to Recordings',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _monthAbbr(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[m - 1];
  }

  Widget _buildDateSelector(String dayStr, String dateStr, bool isSelected) {
    return Container(
      width: 50,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryBlue : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? null : Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dayStr,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? Colors.white : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateStr.split(' ')[0],
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingClassCard({
    required LiveSession session,
    required String startsIn,
    required Color startsInColor,
    required bool isLiveNow,
  }) {
    return GestureDetector(
      onTap: () {
        context.push('/class-details');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: 90,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.lightBlueBg,
                    image: session.courseImageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(session.courseImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: session.courseImageUrl == null
                      ? const Center(
                          child: Icon(
                            Icons.videocam,
                            color: AppColors.primaryBlue,
                            size: 28,
                          ),
                        )
                      : null,
                ),
                if (isLiveNow)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.courseName ?? 'Course',
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session.title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 8,
                        backgroundImage: session.instructorAvatar != null
                            ? NetworkImage(session.instructorAvatar!)
                            : const AssetImage('assets/1.png') as ImageProvider,
                      ),
                      const SizedBox(width: 4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                session.instructorName ?? 'Instructor',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.verified,
                                color: AppColors.primaryBlue,
                                size: 10,
                              ),
                            ],
                          ),
                          const Text(
                            'Hardware Expert',
                            style: TextStyle(
                              fontSize: 8,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 10,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${session.startTime.day} ${_monthAbbr(session.startTime.month)}, ${session.startTime.hour.toString().padLeft(2, '0')}:${session.startTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.access_time,
                        size: 10,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${session.duration} min',
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${session.duration}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const Text(
                  'min',
                  style: TextStyle(fontSize: 8, color: AppColors.textLight),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _joinSession(session),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(60, 28),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Join\nClass',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  startsIn,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 9,
                    color: startsInColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final sessionsInMonth = _sessions
        .where(
          (s) =>
              s.startTime.year == _calendarMonth.year &&
              s.startTime.month == _calendarMonth.month,
        )
        .toList();

    final sessionsByDay = <int, List<LiveSession>>{};
    for (final s in sessionsInMonth) {
      final d = s.startTime.day;
      sessionsByDay.putIfAbsent(d, () => []).add(s);
    }

    final monthStr =
        '${_monthAbbr(_calendarMonth.month)} ${_calendarMonth.year}';
    final firstDay = DateTime(_calendarMonth.year, _calendarMonth.month, 1);
    final lastDay = DateTime(_calendarMonth.year, _calendarMonth.month + 1, 0);
    final startWeekday = firstDay.weekday % 7;

    final weeks = <List<String?>>[];
    var row = List<String?>.filled(7, null);
    var day = 1;
    var col = startWeekday;
    while (day <= lastDay.day) {
      row[col] = day.toString();
      col++;
      if (col == 7) {
        weeks.add(row);
        row = List<String?>.filled(7, null);
        col = 0;
      }
      day++;
    }
    if (row.any((d) => d != null)) {
      weeks.add(row);
    }

    final now = DateTime.now();
    final isCurrentMonth =
        now.month == _calendarMonth.month && now.year == _calendarMonth.year;
    final detailDay = _selectedDay ?? (isCurrentMonth ? now.day : null);
    final detailSessions = detailDay != null
        ? (sessionsByDay[detailDay] ?? [])
        : [];
    final detailDate = detailDay != null
        ? DateTime(_calendarMonth.year, _calendarMonth.month, detailDay)
        : null;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => setState(() {
                _calendarMonth = DateTime(
                  _calendarMonth.year,
                  _calendarMonth.month - 1,
                );
                final now = DateTime.now();
                _selectedDay =
                    (now.month == _calendarMonth.month &&
                        now.year == _calendarMonth.year)
                    ? now.day
                    : 1;
              }),
            ),
            Text(
              monthStr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => setState(() {
                _calendarMonth = DateTime(
                  _calendarMonth.year,
                  _calendarMonth.month + 1,
                );
                final now = DateTime.now();
                _selectedDay =
                    (now.month == _calendarMonth.month &&
                        now.year == _calendarMonth.year)
                    ? now.day
                    : 1;
              }),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Table(
          children: [
            _buildCalendarRow([
              'SUN',
              'MON',
              'TUE',
              'WED',
              'THU',
              'FRI',
              'SAT',
            ], isHeader: true),
            ...weeks.map(
              (w) => _buildCalendarRow(
                w.map((d) => d ?? '').toList(),
                dots: Map.fromEntries(
                  sessionsByDay.entries
                      .where((e) => w.any((d) => d == e.key.toString()))
                      .map((e) => MapEntry(e.key.toString(), e.value.length)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLegend(Colors.green, '1 Class'),
            _buildLegend(Colors.orange, '2 Classes'),
            _buildLegend(Colors.red, '3+ Classes'),
          ],
        ),
        const SizedBox(height: 32),
        if (detailDay != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                detailDate != null &&
                        detailDate == DateTime(now.year, now.month, now.day)
                    ? '${_weekdayName(now.weekday)}, ${now.day} ${monthStr}'
                    : '${detailDate?.day ?? ''} ${monthStr}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                '${detailSessions.length} Classes',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (detailSessions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No classes on this day.',
                  style: const TextStyle(color: AppColors.textLight),
                ),
              ),
            )
          else
            ...detailSessions.map((s) => _buildCalendarClassItem(s)),
        ],
      ],
    );
  }

  String _weekdayName(int w) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[w - 1];
  }

  TableRow _buildCalendarRow(
    List<String> days, {
    bool isHeader = false,
    Map<String, int>? dots,
  }) {
    return TableRow(
      children: days.map((day) {
        final dayNum = day.isNotEmpty ? int.tryParse(day) : null;
        bool isSelected = dayNum != null && dayNum == _selectedDay;
        bool isFaded = isHeader ? false : day.isEmpty;
        int numDots = dots != null && dots.containsKey(day) ? dots[day]! : 0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: GestureDetector(
            onTap: dayNum != null
                ? () => setState(
                    () => _selectedDay = _selectedDay == dayNum ? null : dayNum,
                  )
                : null,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: isHeader ? 10 : 12,
                        fontWeight: isHeader || isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : (isFaded ? Colors.grey : AppColors.textDark),
                      ),
                    ),
                  ),
                ),
                if (!isHeader && numDots > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: numDots == 1
                            ? Colors.green
                            : (numDots == 2 ? Colors.orange : Colors.red),
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                else if (!isHeader)
                  const SizedBox(height: 8),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 10, color: AppColors.textLight),
        ),
      ],
    );
  }

  Widget _buildCalendarClassItem(LiveSession session) {
    final startStr =
        '${session.startTime.hour.toString().padLeft(2, '0')}:${session.startTime.minute.toString().padLeft(2, '0')}';
    final endStr =
        '${session.startTime.add(Duration(minutes: session.duration)).hour.toString().padLeft(2, '0')}:${session.startTime.add(Duration(minutes: session.duration)).minute.toString().padLeft(2, '0')}';
    final diff = session.startTime.difference(DateTime.now());
    final isWithin5h = diff.inHours < 5 && !diff.isNegative;

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
                Text(
                  startStr,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  endStr,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.lightBlueBg,
                    image: session.courseImageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(session.courseImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: session.courseImageUrl == null
                      ? const Center(
                          child: Icon(
                            Icons.videocam,
                            color: AppColors.primaryBlue,
                            size: 20,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.courseName ?? 'Course',
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        session.title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 8,
                            backgroundImage: session.instructorAvatar != null
                                ? NetworkImage(session.instructorAvatar!)
                                : const AssetImage('assets/1.png')
                                      as ImageProvider,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            session.instructorName ?? 'Instructor',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.verified,
                            color: AppColors.primaryBlue,
                            size: 10,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Starts in',
                      style: TextStyle(fontSize: 8, color: AppColors.textLight),
                    ),
                    Text(
                      _formatDuration(diff),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isWithin5h
                            ? AppColors.primaryBlue
                            : Colors.green,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _joinSession(session),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(60, 28),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Join Class',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
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
