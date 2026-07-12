import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart'; // keeping for fallback if needed, but not necessary
import 'router/app_router.dart';

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
          appRouter.go(RouteNames.login);
        }
        return;
      }

      if (event == AuthChangeEvent.initialSession || event == AuthChangeEvent.signedIn) {
        if (event == AuthChangeEvent.initialSession) {
          await Future.delayed(const Duration(milliseconds: 2500));
        }

        if (session != null) {
          try {
            final profile = await profileService.validateSession(session);

            if (profile == null) {
              final prefs = await SharedPreferences.getInstance();
              final isSignupFlow = prefs.getBool('is_signup_flow') ?? false;

              if (!isSignupFlow) {
                _showErrorAndLogout('No account is linked with this app. Please sign up first.');
                return;
              }
              _navigateTo(RouteNames.createProfile);
            } else if (!profile.onboardingCompleted) {
              _navigateTo(RouteNames.createProfile);
            } else {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('is_signup_flow', false);
              await profileService.updateLoginDetails(session.user.id);
              await profileService.bindDevice(session.user.id);
              _navigateTo(RouteNames.home);
            }
          } catch (e) {
            _showErrorAndLogout(e.toString());
          }
        } else {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            _navigateTo(RouteNames.onboarding);
          }
        }
      }
    });
  }

  void _navigateTo(String route) {
    if (mounted) {
      appRouter.go(route);
    }
  }

  Future<void> _showErrorAndLogout(String message) async {
    final context = navigatorKey.currentContext ?? appRouter.routerDelegate.navigatorKey.currentContext;
    if (mounted && context != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
    await authService.signOut();
    if (mounted) {
      appRouter.go(RouteNames.login);
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
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
    );
  }
}
