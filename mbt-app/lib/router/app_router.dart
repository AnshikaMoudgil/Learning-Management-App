import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Screens
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/login_screen.dart';
import '../screens/otp_screen.dart';
import '../screens/create_profile_screen.dart';
import '../screens/dashboard_layout.dart';
import '../screens/home_dashboard.dart';
import '../screens/categories_screen.dart';
import '../screens/category_detail_screen.dart';
import '../screens/course_store_screen.dart';
import '../screens/course_details_screen.dart';
import '../screens/course_progress_screen.dart';
import '../screens/shopping_cart_screen.dart';
import '../screens/live_classes_screen.dart';
import '../screens/live_class_details_screen.dart';
import '../screens/live_class_player_screen.dart';
import '../screens/recorded_class_player_screen.dart';
import '../screens/recordings_screen.dart';
import '../screens/recent_recordings_screen.dart';
import '../screens/my_learning_screen.dart';
import '../screens/my_courses_screen.dart';
import '../screens/downloads_screen.dart';
import '../screens/certificates_screen.dart';
import '../screens/certificate_preview_screen.dart';
import '../screens/wishlist_screen.dart';
import '../screens/more_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/active_devices_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/notification_center_screen.dart';
import '../screens/notification_settings_screen.dart';
import '../screens/support_screen.dart';
import '../screens/help_center_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../screens/terms_of_service_screen.dart';
import '../screens/about_us_screen.dart';
import '../screens/device_blocked_screen.dart';
import '../screens/request_device_change_screen.dart';
import '../screens/my_subscriptions_screen.dart';
import '../screens/payment_success_screen.dart';
import '../screens/global_search_screen.dart';
import '../screens/popular_courses_screen.dart';
import '../screens/newly_added_courses_screen.dart';
import '../screens/continue_watching_screen.dart';
import '../screens/expiring_courses_screen.dart';
import '../screens/renew_course_screen.dart';
import '../screens/course_validity_screen.dart';
import '../screens/daily_schedule_screen.dart';
import '../screens/invoices_screen.dart';
import '../screens/invoice_detail_screen.dart';
import '../screens/class_details_screen.dart';
import '../screens/about_live_classes_screen.dart';

class RouteNames {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const otp = '/otp';
  static const createProfile = '/create-profile';
  static const home = '/home';
  static const categories = '/categories';
  static const categoryDetail = '/category-detail';
  static const course = '/course';
  static const courseProgress = '/course-progress';
  static const live = '/live';
  static const liveClassDetails = '/live-class-details';
  static const livePlayer = '/live-player';
  static const recordings = '/recordings';
  static const recordedPlayer = '/recorded-player';
  static const myLearning = '/my-learning';
  static const downloads = '/downloads';
  static const certificates = '/certificates';
  static const wishlist = '/wishlist';
  static const more = '/more';
  static const profile = '/profile';
  static const editProfile = '/edit-profile';
  static const settings = '/settings';
  static const activeDevices = '/active-devices';
  static const notifications = '/notifications';
  static const notificationSettings = '/notification-settings';
  static const support = '/support';
  static const help = '/help';
  static const privacy = '/privacy';
  static const terms = '/terms';
  static const about = '/about';
  static const subscriptions = '/subscriptions';
  static const paymentSuccess = '/payment-success';
  static const search = '/search';
  static const popularCourses = '/popular-courses';
  static const newlyAddedCourses = '/newly-added-courses';
  static const continueWatching = '/continue-watching';
  static const expiringCourses = '/expiring-courses';
  static const renewCourse = '/renew-course';
  static const courseValidity = '/course-validity';
  static const dailySchedule = '/daily-schedule';
  static const classDetails = '/class-details';
  static const aboutLiveClasses = '/about-live-classes';
  static const myCourses = '/my-courses';
  static const recentRecordings = '/recent-recordings';
  static const deviceBlocked = '/device-blocked';
  static const requestDeviceChange = '/request-device-change';
  static const store = '/store';
  static const cart = '/cart';
  static const invoices = '/invoices';
  static const invoiceDetail = '/invoices';
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _myLearningNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _liveNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _storeNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _moreNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RouteNames.splash,
  redirect: (context, state) async {
    final session = Supabase.instance.client.auth.currentSession;
    final protectedRoutes = [
      RouteNames.myLearning,
      RouteNames.wishlist,
      RouteNames.downloads,
      RouteNames.certificates,
      RouteNames.profile,
      RouteNames.editProfile,
      RouteNames.settings,
      RouteNames.activeDevices,
      RouteNames.notifications,
      RouteNames.paymentSuccess,
      RouteNames.courseProgress,
      RouteNames.subscriptions,
      RouteNames.notificationSettings,
      RouteNames.deviceBlocked,
      RouteNames.requestDeviceChange,
      RouteNames.invoices,
    ];

    final isProtected = protectedRoutes.any((route) => state.uri.path.startsWith(route));

    if (session == null && isProtected) {
      // Redirect to login if trying to access a protected route while logged out
      return '${RouteNames.login}?returnUrl=${Uri.encodeComponent(state.uri.path)}';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RouteNames.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RouteNames.otp,
      builder: (context, state) {
        final phone = state.uri.queryParameters['phone'] ?? '';
        return OtpScreen(phone: phone);
      },
    ),
    GoRoute(
      path: RouteNames.createProfile,
      builder: (context, state) => const CreateProfileScreen(),
    ),

    // StatefulShellRoute for Bottom Navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return DashboardLayout(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(
              path: RouteNames.home,
              builder: (context, state) => const HomeDashboard(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _myLearningNavigatorKey,
          routes: [
            GoRoute(
              path: RouteNames.myLearning,
              builder: (context, state) => const MyLearningScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _liveNavigatorKey,
          routes: [
            GoRoute(
              path: RouteNames.live,
              builder: (context, state) => const LiveClassesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _storeNavigatorKey,
          routes: [
            GoRoute(
              path: RouteNames.store,
              builder: (context, state) => const CourseStoreScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _moreNavigatorKey,
          routes: [
            GoRoute(
              path: RouteNames.more,
              builder: (context, state) => const MoreScreen(),
            ),
          ],
        ),
      ],
    ),

    // Other screens
    GoRoute(
      path: RouteNames.categories,
      builder: (context, state) => const CategoriesScreen(),
    ),
    GoRoute(
      path: RouteNames.categoryDetail,
      builder: (context, state) => const CategoryDetailScreen(),
    ),
    GoRoute(
      path: RouteNames.course,
      builder: (context, state) => CourseDetailsScreen(
        courseId: state.uri.queryParameters['id'],
      ),
    ),
    GoRoute(
      path: RouteNames.courseProgress,
      builder: (context, state) => CourseProgressScreen(
        courseId: state.uri.queryParameters['id'],
      ),
    ),
    GoRoute(
      path: RouteNames.cart,
      builder: (context, state) => const ShoppingCartScreen(),
    ),
    GoRoute(
      path: RouteNames.liveClassDetails,
      builder: (context, state) => const LiveClassDetailsScreen(),
    ),
    GoRoute(
      path: RouteNames.livePlayer,
      builder: (context, state) => const LiveClassPlayerScreen(),
    ),
    GoRoute(
      path: RouteNames.recordings,
      builder: (context, state) => const RecordingsScreen(),
    ),
    GoRoute(
      path: RouteNames.recordedPlayer,
      builder: (context, state) => RecordedClassPlayerScreen(
        lessonId: state.uri.queryParameters['lessonId'],
        url: state.uri.queryParameters['url'],
        courseId: state.uri.queryParameters['courseId'],
      ),
    ),
    GoRoute(
      path: RouteNames.downloads,
      builder: (context, state) => const DownloadsScreen(),
    ),
    GoRoute(
      path: RouteNames.certificates,
      builder: (context, state) => const CertificatesScreen(),
    ),
    GoRoute(
      path: '/certificate-preview',
      builder: (context, state) => const CertificatePreviewScreen(),
    ),
    GoRoute(
      path: RouteNames.wishlist,
      builder: (context, state) => const WishlistScreen(),
    ),
    GoRoute(
      path: RouteNames.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: RouteNames.editProfile,
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: RouteNames.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: RouteNames.activeDevices,
      builder: (context, state) => const ActiveDevicesScreen(),
    ),
    GoRoute(
      path: RouteNames.notifications,
      builder: (context, state) => const NotificationCenterScreen(), 
    ),
    GoRoute(
      path: RouteNames.notificationSettings,
      builder: (context, state) => const NotificationSettingsScreen(),
    ),
    GoRoute(
      path: RouteNames.support,
      builder: (context, state) => const SupportScreen(),
    ),
    GoRoute(
      path: RouteNames.help,
      builder: (context, state) => const HelpCenterScreen(),
    ),
    GoRoute(
      path: RouteNames.privacy,
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: RouteNames.terms,
      builder: (context, state) => const TermsOfServiceScreen(),
    ),
    GoRoute(
      path: RouteNames.about,
      builder: (context, state) => const AboutUsScreen(),
    ),
    GoRoute(
      path: RouteNames.subscriptions,
      builder: (context, state) => const MySubscriptionsScreen(),
    ),
    GoRoute(
      path: RouteNames.paymentSuccess,
      builder: (context, state) => PaymentSuccessScreen(
        courseTitle: state.uri.queryParameters['courseTitle'],
        orderId: state.uri.queryParameters['orderId'],
        status: state.uri.queryParameters['status'],
      ),
    ),
    GoRoute(
      path: RouteNames.search,
      builder: (context, state) => const GlobalSearchScreen(),
    ),
    GoRoute(
      path: RouteNames.popularCourses,
      builder: (context, state) => const PopularCoursesScreen(),
    ),
    GoRoute(
      path: RouteNames.newlyAddedCourses,
      builder: (context, state) => const NewlyAddedCoursesScreen(),
    ),
    GoRoute(
      path: RouteNames.continueWatching,
      builder: (context, state) => const ContinueWatchingScreen(),
    ),
    GoRoute(
      path: RouteNames.expiringCourses,
      builder: (context, state) => const ExpiringCoursesScreen(),
    ),
    GoRoute(
      path: RouteNames.renewCourse,
      builder: (context, state) => const RenewCourseScreen(),
    ),
    GoRoute(
      path: RouteNames.courseValidity,
      builder: (context, state) => const CourseValidityScreen(),
    ),
    GoRoute(
      path: RouteNames.dailySchedule,
      builder: (context, state) => const DailyScheduleScreen(),
    ),
    GoRoute(
      path: RouteNames.classDetails,
      builder: (context, state) => const ClassDetailsScreen(),
    ),
    GoRoute(
      path: RouteNames.aboutLiveClasses,
      builder: (context, state) => const AboutLiveClassesScreen(),
    ),
    GoRoute(
      path: RouteNames.myCourses,
      builder: (context, state) => const MyCoursesScreen(),
    ),
    GoRoute(
      path: RouteNames.recentRecordings,
      builder: (context, state) => const RecentRecordingsScreen(),
    ),
    GoRoute(
      path: RouteNames.deviceBlocked,
      builder: (context, state) => const DeviceBlockedScreen(),
    ),
    GoRoute(
      path: RouteNames.requestDeviceChange,
      builder: (context, state) => const RequestDeviceChangeScreen(),
    ),
    GoRoute(
      path: RouteNames.invoices,
      builder: (context, state) => const InvoicesScreen(),
    ),
    GoRoute(
      path: '${RouteNames.invoiceDetail}/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return InvoiceDetailScreen(invoiceId: id);
      },
    ),
  ],
);
