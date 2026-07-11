import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/onboarding_screen.dart';
import 'screens/dashboard_layout.dart';
import 'screens/create_profile_screen.dart';
import 'screens/login_screen.dart';
import 'services/profile_service.dart';
import 'services/auth_service.dart';
import 'theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final ProfileService profileService = ProfileService();
final AuthService authService = AuthService();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final StreamSubscription<AuthState> _authSubscription;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      final event = data.event;

      if (event == AuthChangeEvent.signedOut) {
        if (mounted) {
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
        return;
      }

      // Only perform routing on initial startup or explicit sign in.
      // We ignore userUpdated to prevent interrupting CreateProfileScreen.
      if (event == AuthChangeEvent.initialSession || event == AuthChangeEvent.signedIn) {
        if (session != null) {
          try {
            // Perform backend profile validation
            final profile = await profileService.validateSession(session);
            
            if (profile == null) {
              final prefs = await SharedPreferences.getInstance();
              final isSignupFlow = prefs.getBool('is_signup_flow') ?? false;

              if (!isSignupFlow) {
                // User tried to login, but has no account
                _showErrorAndLogout('No account is linked with this app. Please sign up first.');
                return;
              }
              // New user from Signup tab, go to CreateProfileScreen
              _navigateTo(const CreateProfileScreen());
            } else if (!profile.onboardingCompleted) {
              // Auth user exists, but the learner profile still needs app details.
              _navigateTo(const CreateProfileScreen());
            } else {
              // Valid and completed onboarding
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('is_signup_flow', false);
              await profileService.updateLoginDetails(session.user.id);
              _navigateTo(DashboardLayout());
            }
          } catch (e) {
            // If magic string or regular error
            if (e.toString().contains('DEVICE_MISMATCH')) {
               _showErrorAndLogout('Device mismatch. You can only use one active device.');
            } else {
               _showErrorAndLogout(e.toString());
            }
          }
        } else {
          // No session
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            // Initial app load with no session goes to Onboarding Screen (Get Started)
            _navigateTo(const OnboardingScreen());
          }
        }
      }
    });
  }

  void _navigateTo(Widget screen) {
    if (mounted) {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => screen),
        (route) => false,
      );
    }
  }

  Future<void> _showErrorAndLogout(String message) async {
    if (mounted && navigatorKey.currentContext != null) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(SnackBar(content: Text(message)));
    }
    await authService.signOut();
    if (mounted) {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'MBT LMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryBlue),
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.textDark),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      ),
    );
  }
}
