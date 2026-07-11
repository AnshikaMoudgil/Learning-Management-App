import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'home_dashboard.dart';
import 'my_courses_screen.dart';
import 'live_classes_screen.dart';
import 'downloads_screen.dart';
import 'more_screen.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({Key? key}) : super(key: key);

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTab = 0;
  bool _hasSearched = false;

  void _onNavTapped(int index) {
    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = const HomeDashboard();
        break;
      case 1:
        nextScreen = const MyCoursesScreen();
        break;
      case 2:
        nextScreen = const LiveClassesScreen();
        break;
      case 3:
        nextScreen = const DownloadsScreen();
        break;
      case 4:
        nextScreen = const MoreScreen();
        break;
      default:
        return;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => nextScreen));
  }

  @override
  Widget build(BuildContext context) {
    bool isQueryEmpty = _searchController.text.isEmpty;
    bool isQuantum = _searchController.text.toLowerCase().contains('quantum');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage('assets/1.png'),
            ),
            const Spacer(),
            IconButton(icon: const Icon(Icons.search, color: AppColors.textDark), onPressed: () {}),
            Stack(
              children: [
                IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.textDark), onPressed: () {}),
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
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.primaryBlue),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _hasSearched = val.isNotEmpty;
                        });
                      },
                      decoration: InputDecoration(
                        icon: const Icon(Icons.search, color: AppColors.textLight),
                        hintText: 'Search for courses, recordings, teachers...',
                        hintStyle: const TextStyle(fontSize: 12, color: AppColors.textLight),
                        border: InputBorder.none,
                        suffixIcon: _hasSearched
                            ? IconButton(
                                icon: const Icon(Icons.close, size: 16, color: AppColors.textLight),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _hasSearched = false;
                                  });
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() {
                      _hasSearched = false;
                    });
                  },
                  child: const Text('Cancel', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 14)),
                )
              ],
            ),
          ),
          
          Expanded(
            child: !isQueryEmpty 
                ? (isQuantum ? _buildEmptyState() : _buildResultsState())
                : _buildRecentSearches(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Since it's global search, none might be purely active, but we can set 0 or keep styling unselected
        onTap: _onNavTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.textLight,
        unselectedItemColor: AppColors.textLight,
        selectedLabelStyle: const TextStyle(fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.video_library_outlined), label: 'My Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.sensors), label: 'Live Classes'),
          BottomNavigationBarItem(icon: Icon(Icons.download_outlined), label: 'Downloads'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'More'),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Searches', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              TextButton(onPressed: () {}, child: const Text('Clear All', style: TextStyle(color: AppColors.primaryBlue, fontSize: 12, fontWeight: FontWeight.bold))),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildRecentSearchChip('Mobile repairing'),
              _buildRecentSearchChip('Soldering basics'),
              _buildRecentSearchChip('Power IC repair'),
              _buildRecentSearchChip('Android troubleshooting'),
              _buildRecentSearchChip('Rahul Verma'),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: const [
              Icon(Icons.trending_up, color: AppColors.primaryBlue, size: 20),
              SizedBox(width: 8),
              Text('Trending Searches', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            ],
          ),
          const SizedBox(height: 16),
          _buildTrendingItem('Mobile IC Repair'),
          _buildTrendingItem('Android Repair'),
          _buildTrendingItem('Soldering Techniques'),
          _buildTrendingItem('Laptop Repair'),
          _buildTrendingItem('Fault Finding'),
          _buildTrendingItem('Multimeter Basics'),
          _buildTrendingItem('Power Supply Repair'),
          _buildTrendingItem('iPhone Repair'),
        ],
      ),
    );
  }

  Widget _buildRecentSearchChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time, size: 14, color: AppColors.textLight),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textDark)),
          const SizedBox(width: 6),
          const Icon(Icons.close, size: 14, color: AppColors.textLight),
        ],
      ),
    );
  }

  Widget _buildTrendingItem(String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.primaryBlue, fontWeight: FontWeight.w500)),
          const Icon(Icons.call_made, size: 16, color: AppColors.primaryBlue),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        // Tabs with 0 count
        Row(
          children: [
            _buildTab('Courses (0)', 0),
            _buildTab('Recordings (0)', 1),
            _buildTab('Teachers (0)', 2),
          ],
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/search_empty.png',
                    width: 200,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.search_off, size: 100, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(height: 24),
                  const Text('No results found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  const Text('We couldn\'t find anything for "quantum computing".\nTry a different keyword or check your spelling.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _hasSearched = false;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: const BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Try Different Keyword'),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildTab('Courses (24)', 0),
            _buildTab('Recordings (156)', 1),
            _buildTab('Teachers (12)', 2),
          ],
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Courses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  Text('See All', style: TextStyle(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              _buildCourseResultCard('Mobile Repairing\nComplete Course', 'Mr. Ankit Verma', '4.8 (1.2k)', true),
              const SizedBox(height: 12),
              _buildCourseResultCard('Advance Mobile Hardware\nRepair', 'Mr. Rahul Sharma', '4.7 (842)', true),
              const SizedBox(height: 12),
              _buildCourseResultCard('Android Phone\nRepair Mastery', 'Mr. Sonu Singh', '4.6 (621)', false),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Recordings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  Text('See All', style: TextStyle(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              _buildRecordingResultCard(),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Teachers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  Text('See All', style: TextStyle(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              _buildTeacherResultCard(),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildTab(String label, int index) {
    bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: isSelected ? AppColors.primaryBlue : AppColors.border, width: isSelected ? 2 : 1)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? AppColors.primaryBlue : AppColors.textLight),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseResultCard(String title, String author, String rating, bool isPremium) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: const DecorationImage(image: AssetImage('assets/iphone_hardware.png'), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text('By $author', style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 12),
                    const SizedBox(width: 4),
                    Text(rating, style: const TextStyle(fontSize: 10, color: AppColors.textDark, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPremium ? Colors.blue.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(isPremium ? 'Premium' : 'Free', style: TextStyle(color: isPremium ? AppColors.primaryBlue : Colors.green, fontSize: 8, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingResultCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: const DecorationImage(image: AssetImage('assets/iphone_software.png'), fit: BoxFit.cover),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(4)),
                  child: const Text('32:45', style: TextStyle(color: Colors.white, fontSize: 8)),
                ),
              ),
              const Positioned.fill(child: Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 24))),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Mobile Charging Problem - Live Session', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                SizedBox(height: 4),
                Text('By Mr. Ankit Verma', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                SizedBox(height: 4),
                Text('2 days ago • 1.2K views', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherResultCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 24, backgroundImage: AssetImage('assets/1.png')),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mr. Ankit Verma', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const Text('Mobile Repair Expert', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Icon(Icons.star, color: Colors.orange, size: 12),
                    SizedBox(width: 4),
                    Text('4.9 (2.1k students)', style: TextStyle(fontSize: 10, color: AppColors.textDark, fontWeight: FontWeight.bold)),
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
