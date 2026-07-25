import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import '../services/profile_service.dart';
import '../services/auth_service.dart';
import '../models/profile.dart';
import 'home_dashboard.dart';
import 'my_learning_screen.dart';
import 'live_classes_screen.dart';
import 'course_store_screen.dart';
import 'edit_profile_screen.dart';
import 'profile_courses_screen.dart';
// import 'my_subscriptions_screen.dart';
import 'certificates_screen.dart';
import 'active_devices_screen.dart';
import 'notification_settings_screen.dart';
import 'help_center_screen.dart';
import 'support_screen.dart';
import 'about_us_screen.dart';
import 'login_screen.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();
  Profile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _profileService.profileUpdateNotifier.addListener(_onProfileUpdated);
  }

  @override
  void dispose() {
    _profileService.profileUpdateNotifier.removeListener(_onProfileUpdated);
    super.dispose();
  }

  void _onProfileUpdated() {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileService.getProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
      }
    }
  }

  void _onNavTapped(BuildContext context, int index) {
    if (index == 4) return;
    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = const HomeDashboard();
        break;
      case 1:
        nextScreen = const MyLearningScreen();
        break;
      case 2:
        nextScreen = const LiveClassesScreen();
        break;
      case 3:
        nextScreen = const CourseStoreScreen();
        break;
      default:
        return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _profile?.fullName ?? 'Loading...';
    final email =
        _profile?.email ??
        Supabase.instance.client.auth.currentUser?.email ??
        '';
    final avatarUrl = _profile?.avatarUrl;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textDark,
                ),
                onPressed: () => context.push('/notifications'),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundImage: avatarUrl != null
                              ? NetworkImage(avatarUrl)
                              : const AssetImage('assets/1.png')
                                    as ImageProvider,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textLight,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  context.push('/edit-profile');
                                },
                                child: const Text(
                                  'View Profile',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _buildMenuItem(
                    context,
                    Icons.video_library_outlined,
                    'My Courses',
                    const ProfileCoursesScreen(),
                    iconColor: AppColors.primaryBlue,
                  ),
                  // _buildMenuItem(
                  //   context,
                  //   Icons.subscriptions_outlined,
                  //   'My Subscriptions',
                  //   const MySubscriptionsScreen(),
                  // ),
                  _buildMenuItem(
                    context,
                    Icons.workspace_premium_outlined,
                    'Certificates',
                    const CertificatesScreen(),
                  ),
                  _buildMenuItem(
                    context,
                    Icons.devices,
                    'Active Devices',
                    const ActiveDevicesScreen(),
                  ),
                  _buildMenuItem(
                    context,
                    Icons.notifications_none,
                    'Notification Settings',
                    const NotificationSettingsScreen(),
                  ),
                  _buildMenuItem(
                    context,
                    Icons.help_outline,
                    'Help Center',
                    const HelpCenterScreen(),
                  ),
                  _buildMenuItem(
                    context,
                    Icons.support_agent,
                    'Support',
                    const SupportScreen(),
                  ),
                  _buildMenuItem(
                    context,
                    Icons.info_outline,
                    'About Us',
                    const AboutUsScreen(),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                    onTap: _logout,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    Widget destination, {
    Color iconColor = AppColors.textLight,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 4,
          ),
          leading: Icon(icon, color: iconColor),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textLight),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => destination),
          ),
        ),
        const Divider(height: 1, color: AppColors.border, indent: 64),
      ],
    );
  }
}
