import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'screens/splash_screen.dart';
import 'router/app_router.dart';

import 'services/profile_service.dart';
import 'services/auth_service.dart';
import 'services/fcm_service.dart';
import 'theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyA9AvLo32W2D0-JpGdO7-4yd-rjyKjMQ34',
        appId: '1:1080778754825:web:0794c073915cd6a6c861d8',
        messagingSenderId: '1080778754825',
        projectId: 'mbt-app-9576b',
        storageBucket: 'mbt-app-9576b.firebasestorage.app',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

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
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) async {
      final session = data.session;
      final event = data.event;

      if (event == AuthChangeEvent.signedOut) {
        FcmService().disposeToken();
        if (mounted) {
          appRouter.go(RouteNames.login);
        }
        return;
      }

      if (event == AuthChangeEvent.initialSession ||
          event == AuthChangeEvent.signedIn) {
        if (event == AuthChangeEvent.initialSession) {
          if (session == null) {
            // No active session on startup — show onboarding after splash delay
            await Future.delayed(const Duration(milliseconds: 2500));
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              _navigateTo(RouteNames.onboarding);
            }
            return;
          }
          // Has a session on startup — small delay for splash screen visibility
          await Future.delayed(const Duration(milliseconds: 2500));
        }
        // signedIn fires immediately (e.g. after Google login) — no delay needed

        if (session != null) {
          try {
            final profile = await profileService.validateSession(session);

            if (profile == null) {
              _navigateTo(RouteNames.createProfile);
            } else if (!profile.onboardingCompleted) {
              _navigateTo(RouteNames.createProfile);
            } else {
              // Navigate to home immediately so user isn't stuck on onboarding
              _navigateTo(RouteNames.home);
              // Run device binding, FCM init, and login details update in background
              try {
                await Future.wait([
                  profileService.bindDevice(session.user.id),
                  FcmService().init(session.user.id),
                ]);
              } catch (e) {
                if (e.toString().contains('bound to another device')) {
                  _navigateTo(RouteNames.deviceBlocked);
                  return;
                }
              }
              try {
                await profileService.updateLoginDetails(session.user.id);
              } catch (_) {}
            }
          } catch (e) {
            _showErrorAndLogout(e.toString());
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
    final context =
        navigatorKey.currentContext ??
        appRouter.routerDelegate.navigatorKey.currentContext;
    if (mounted && context != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
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
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
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
