import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'live_class_details_screen.dart';

class LiveClassesScreen extends StatelessWidget {
  const LiveClassesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Live Classes', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 22)),
            SizedBox(height: 2),
            Text('Join live sessions, learn from experts in real-time', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: AppColors.textDark), onPressed: () {}),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.textDark), onPressed: () {}),
              Positioned(
                right: 8,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ),
              )
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.primaryBlue, width: 2)),
                    ),
                    child: const Center(child: Text('Upcoming', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 14))),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
                    ),
                    child: const Center(child: Text('My Bookings', style: TextStyle(color: AppColors.textLight, fontSize: 14))),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Upcoming Live Classes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                    Row(
                      children: const [
                        Icon(Icons.calendar_month_outlined, size: 14, color: AppColors.primaryBlue),
                        SizedBox(width: 4),
                        Text('Calendar View', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryBlue)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Date Scroller
                SizedBox(
                  height: 60,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildDateCard('Today', '2 May', true),
                      _buildDateCard('Sat', '3 May', false),
                      _buildDateCard('Sun', '4 May', false),
                      _buildDateCard('Mon', '5 May', false),
                      _buildDateCard('Tue', '6 May', false),
                      _buildDateCard('Wed', '7 May', false),
                      _buildDateCard('Thu', '8 May', false),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Class Cards
                _buildLiveClassCard(
                  context,
                  'assets/iphone_hardware.png',
                  'iPhone Hardware Course',
                  'Display Light Problem Diagnosis',
                  'Rahul Verma',
                  'Hardware Expert',
                  'Today, 07:00 PM',
                  '60 min',
                  '25',
                  'Starts in 1h 18m',
                ),
                const SizedBox(height: 16),
                _buildLiveClassCard(
                  context,
                  'assets/iphone_hardware.png', // Placeholder
                  'iPhone Hardware Course',
                  'Face ID Not Working - Deep Dive',
                  'Amit Sharma',
                  'Hardware Expert',
                  'Tomorrow, 11:00 AM',
                  '90 min',
                  '18',
                  'Starts in 15h 18m',
                ),
                const SizedBox(height: 16),
                _buildLiveClassCard(
                  context,
                  'assets/iphone_hardware.png', // Placeholder
                  'Advanced Repair Course',
                  'Board Level Shorting Explained',
                  'Pankaj Singh',
                  'Board Level Specialist',
                  '3 May, 04:00 PM',
                  '75 min',
                  '32',
                  'Starts in 2d 6h',
                ),
                const SizedBox(height: 16),
                _buildLiveClassCard(
                  context,
                  'assets/iphone_hardware.png', // Placeholder
                  'Android Hardware Course',
                  'Battery Replacement Best Practices',
                  'Neeraj Patel',
                  'Android Expert',
                  '4 May, 07:00 PM',
                  '60 min',
                  '30',
                  'Starts in 3d 9h',
                ),
                
                const SizedBox(height: 24),
                
                // Bottom Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlueBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.event_busy, color: AppColors.primaryBlue),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Can\'t attend live?', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 13)),
                            SizedBox(height: 4),
                            Text('All live classes are recorded. You can watch them anytime in the Recordings section.', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryBlue),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: Size.zero,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.play_circle_outline, size: 14, color: AppColors.primaryBlue),
                              SizedBox(width: 4),
                              Text('Recordings', style: TextStyle(color: AppColors.primaryBlue, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDateCard(String day, String date, bool isSelected) {
    return Container(
      width: 60,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryBlue : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? AppColors.primaryBlue : AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(day, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.white : AppColors.textDark)),
          const SizedBox(height: 2),
          Text(date, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.textLight)),
        ],
      ),
    );
  }

  Widget _buildLiveClassCard(BuildContext context, String imagePath, String course, String title, String instructor, String instructorRole, String time, String duration, String enrolled, String startsIn) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LiveClassDetailsScreen()),
        );
      },
      child: Container(
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
        child: IntrinsicHeight(
          child: Row(
            children: [
          // Left Image
          Container(
            width: 100,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.all(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(color: const Color(0xFFE53935), borderRadius: BorderRadius.circular(4)), // Red LIVE badge
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.circle, color: Colors.white, size: 6),
                  SizedBox(width: 4),
                  Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          
          // Middle Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.lightBlueBg, borderRadius: BorderRadius.circular(12)),
                    child: Text(course, style: const TextStyle(color: AppColors.primaryBlue, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                  Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark, height: 1.2)),
                  Row(
                    children: [
                    const CircleAvatar(
                      radius: 12,
                      backgroundImage: AssetImage('assets/1.png'),
                      backgroundColor: AppColors.lightBlueBg,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(child: Text(instructor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textDark), overflow: TextOverflow.ellipsis)),
                              const SizedBox(width: 4),
                              const Icon(Icons.verified, color: Colors.blue, size: 10),
                            ],
                          ),
                          Text(instructorRole, style: const TextStyle(color: AppColors.primaryBlue, fontSize: 9, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],    ),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 10, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Text(time, style: const TextStyle(fontSize: 9, color: AppColors.textLight)),
                      const SizedBox(width: 6),
                      const Text('|', style: TextStyle(color: AppColors.border, fontSize: 10)),
                      const SizedBox(width: 6),
                      const Icon(Icons.access_time_outlined, size: 10, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Text(duration, style: const TextStyle(fontSize: 9, color: AppColors.textLight)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Right Action Button
          Container(
            width: 75,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(enrolled, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark)),
                const Text('Enrolled', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 0,
                    ),
                    child: const Text('Join\nClass', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, height: 1.2)),
                  ),
                ),
                const SizedBox(height: 12),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(fontSize: 9, color: AppColors.textLight),
                      children: [
                        TextSpan(text: '${startsIn.split(' ').take(2).join(' ')}\n'),
                        TextSpan(text: startsIn.split(' ').skip(2).join(' '), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 10)),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 2, // Live Classes is active
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
