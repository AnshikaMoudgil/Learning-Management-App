import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'home_dashboard.dart';
import 'my_learning_screen.dart';
import 'recent_recordings_screen.dart';
import 'profile_screen.dart';
import 'daily_schedule_screen.dart';
import 'class_details_screen.dart';
import 'package:go_router/go_router.dart';

class LiveClassesScreen extends StatefulWidget {
  const LiveClassesScreen({Key? key}) : super(key: key);

  @override
  State<LiveClassesScreen> createState() => _LiveClassesScreenState();
}

class _LiveClassesScreenState extends State<LiveClassesScreen> {
  int _selectedTab = 0; // 0 for Upcoming, 1 for Calendar

  void _onNavTapped(int index) {
    if (index == 2) return; // Already on Live Classes
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
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => nextScreen));
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
            Text('Live Classes', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 22)),
            SizedBox(height: 4),
            Text('Join live sessions, learn from experts in real-time', style: TextStyle(color: AppColors.textLight, fontSize: 10)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: AppColors.textDark), onPressed: () => context.push('/search')),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.textDark), onPressed: () => context.push('/notifications')),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center),
                ),
              )
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
            child: _selectedTab == 0 ? _buildUpcomingView() : _buildCalendarView(),
          )
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
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))] : [],
            border: isSelected ? Border.all(color: AppColors.primaryBlue, width: 1.5) : Border.all(color: Colors.transparent),
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

  Widget _buildUpcomingView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Upcoming Live Classes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              GestureDetector(
                onTap: () => setState(() => _selectedTab = 1), // switch to calendar
                child: Row(
                  children: const [
                    Icon(Icons.calendar_month, size: 14, color: AppColors.primaryBlue),
                    SizedBox(width: 4),
                    Text('Calendar View', style: TextStyle(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildDateSelector('Today', '2 May', true),
              _buildDateSelector('Sat', '3 May', false),
              _buildDateSelector('Sun', '4 May', false),
              _buildDateSelector('Mon', '5 May', false),
              _buildDateSelector('Tue', '6 May', false),
              _buildDateSelector('Wed', '7 May', false),
              _buildDateSelector('Thu', '8 May', false),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildUpcomingClassCard(
                image: 'assets/iphone_hardware.png',
                courseName: 'iPhone Hardware Course',
                title: 'Display Light Problem Diagnosis',
                author: 'Rahul Verma',
                date: 'Today, 07:00 PM',
                duration: '60 min',
                enrolled: '25',
                startsIn: 'Starts in\n1h 18m',
                startsInColor: Colors.green,
                isLiveNow: true,
              ),
              _buildUpcomingClassCard(
                image: 'assets/iphone_software.png',
                courseName: 'iPhone Hardware Course',
                title: 'Face ID Not Working - Deep Dive',
                author: 'Amit Sharma',
                date: 'Tomorrow, 11:00 AM',
                duration: '90 min',
                enrolled: '18',
                startsIn: 'Starts in\n15h 18m',
                startsInColor: AppColors.primaryBlue,
                isLiveNow: true, // actually it's upcoming, but we show LIVE badge in screenshot? Screenshot shows LIVE badge on all 4 cards! Let's put LIVE badge.
              ),
              _buildUpcomingClassCard(
                image: 'assets/android_hardware.png',
                courseName: 'Advanced Repair Course',
                title: 'Board Level Shorting Explained',
                author: 'Pankaj Singh',
                date: '3 May, 04:00 PM',
                duration: '75 min',
                enrolled: '32',
                startsIn: 'Starts in\n2d 6h',
                startsInColor: AppColors.textDark,
                isLiveNow: true,
              ),
              _buildUpcomingClassCard(
                image: 'assets/android_hardware.png',
                courseName: 'Android Hardware Course',
                title: 'Battery Replacement Best Practice',
                author: 'Neeraj Patel',
                date: '4 May, 07:00 PM',
                duration: '60 min',
                enrolled: '32',
                startsIn: 'Starts in\n3d 6h',
                startsInColor: AppColors.textDark,
                isLiveNow: true,
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, -2))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.lightBlueBg, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.event_busy, color: AppColors.primaryBlue, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Can\'t attend live?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    Text('All live classes are recorded. You can watch them anytime in the Recordings section.', style: TextStyle(fontSize: 9, color: AppColors.textLight)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 36),
                ),
                child: const Text('Go to Recordings', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        )
      ],
    );
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
          Text(dayStr, style: TextStyle(fontSize: 10, color: isSelected ? Colors.white : AppColors.textLight)),
          const SizedBox(height: 4),
          Text(dateStr.split(' ')[0], style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _buildUpcomingClassCard({
    required String image,
    required String courseName,
    required String title,
    required String author,
    required String date,
    required String duration,
    required String enrolled,
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
                    image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
                  ),
                ),
                if (isLiveNow)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                      child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(courseName, style: const TextStyle(fontSize: 9, color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark), maxLines: 2),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const CircleAvatar(radius: 8, backgroundImage: AssetImage('assets/1.png')),
                      const SizedBox(width: 4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(author, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                              const SizedBox(width: 2),
                              const Icon(Icons.verified, color: AppColors.primaryBlue, size: 10),
                            ],
                          ),
                          const Text('Hardware Expert', style: TextStyle(fontSize: 8, color: AppColors.textLight)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 10, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Text(date, style: const TextStyle(fontSize: 9, color: AppColors.textLight)),
                      const SizedBox(width: 12),
                      const Icon(Icons.access_time, size: 10, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Text(duration, style: const TextStyle(fontSize: 9, color: AppColors.textLight)),
                    ],
                  )
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(enrolled, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const Text('Enrolled', style: TextStyle(fontSize: 8, color: AppColors.textLight)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(60, 28),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    elevation: 0,
                  ),
                  child: const Text('Join\nClass', textAlign: TextAlign.center, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                Text(startsIn, textAlign: TextAlign.right, style: TextStyle(fontSize: 9, color: startsInColor, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {}),
            const Text('May 2025', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {}),
          ],
        ),
        const SizedBox(height: 16),
        // Mock Calendar Grid
        Table(
          children: [
            _buildCalendarRow(['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'], isHeader: true),
            _buildCalendarRow(['27', '28', '29', '30', '1', '2', '3'], selectedDay: '2', dots: {'1': 1, '2': 2, '3': 3}),
            _buildCalendarRow(['4', '5', '6', '7', '8', '9', '10'], dots: {'4': 1, '5': 1, '6': 1, '7': 2, '8': 1, '9': 1, '10': 3}),
            _buildCalendarRow(['11', '12', '13', '14', '15', '16', '17'], dots: {'11': 1, '14': 2, '15': 1, '16': 1, '17': 2}),
            _buildCalendarRow(['18', '19', '20', '21', '22', '23', '24'], dots: {'22': 2, '23': 3}),
            _buildCalendarRow(['25', '26', '27', '28', '29', '30', '31'], dots: {'26': 1, '28': 2, '29': 1, '31': 3}),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Friday, 2 May 2025', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const Text('2 Classes', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
          ],
        ),
        const SizedBox(height: 16),
        _buildCalendarClassItem('07:00 PM', '08:00 PM', 'assets/iphone_hardware.png', 'iPhone Hardware Course', 'Display Light Problem Diagnosis', 'Rahul Verma'),
        _buildCalendarClassItem('11:00 PM', '12:30 PM', 'assets/android_hardware.png', 'Android Hardware Course', 'Face ID Not Working - Deep Dive', 'Amit Sharma', isBlue: true),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            context.push('/daily-schedule');
          },
          icon: const Icon(Icons.calendar_today, size: 16, color: AppColors.primaryBlue),
          label: const Text('View Full Schedule for 2 May', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primaryBlue),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  TableRow _buildCalendarRow(List<String> days, {bool isHeader = false, String? selectedDay, Map<String, int>? dots}) {
    return TableRow(
      children: days.map((day) {
        bool isSelected = day == selectedDay;
        bool isFaded = isHeader ? false : (int.tryParse(day) == null || (day == '27' || day == '28' || day == '29' || day == '30') && !dots!.containsKey('30')); // simplistic check for prev month
        
        int numDots = dots != null && dots.containsKey(day) ? dots[day]! : 0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: isHeader ? 10 : 12,
                      fontWeight: isHeader || isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : (isFaded ? Colors.grey : AppColors.textDark),
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
                      color: numDots == 1 ? Colors.green : (numDots == 2 ? Colors.orange : Colors.red),
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              else if (!isHeader)
                const SizedBox(height: 8)
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
      ],
    );
  }

  Widget _buildCalendarClassItem(String startTime, String endTime, String image, String courseName, String title, String author, {bool isBlue = false}) {
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 80,
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
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Starts in', style: TextStyle(fontSize: 8, color: AppColors.textLight)),
                    Text(isBlue ? '15:18:45' : '01:18:45', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isBlue ? AppColors.primaryBlue : Colors.green)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {},
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
        ],
      ),
    );
  }
}
