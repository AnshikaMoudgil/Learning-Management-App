import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_colors.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // main.dart handles routing now
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _SplashBackgroundPainter(),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/mbt_logo.png',
                  width: 150,
                  height: 150,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.handyman, // Fallback icon
                      size: 150,
                      color: AppColors.primaryBlue,
                    );
                  },
                ),
                const SizedBox(height: 16),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      fontFamily: 'Roboto',
                    ),
                    children: [
                      TextSpan(
                        text: 'MBT ',
                        style: TextStyle(color: Color(0xFF111827)), // Dark color
                      ),
                      TextSpan(
                        text: 'Institute',
                        style: TextStyle(color: AppColors.primaryBlue),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 250,
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.primaryBlue.withOpacity(0.3),
                            AppColors.primaryBlue.withOpacity(0.8),
                            AppColors.primaryBlue.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withOpacity(0.6),
                            blurRadius: 6,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Learn Anywhere, Anytime',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF4B5563),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 64),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Loading your learning experience...',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Gradient paint for waves
    Paint getWavePaint(List<Color> colors) {
      return Paint()
        ..shader = LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill;
    }

    final paint1 = getWavePaint([
      AppColors.primaryBlue.withOpacity(0.05),
      AppColors.primaryBlue.withOpacity(0.1),
    ]);

    final paint2 = getWavePaint([
      AppColors.primaryBlue.withOpacity(0.1),
      AppColors.primaryBlue.withOpacity(0.15),
    ]);

    final paint3 = getWavePaint([
      AppColors.primaryBlue.withOpacity(0.15),
      AppColors.primaryBlue.withOpacity(0.3),
    ]);

    // Layer 1 (Back)
    final path1 = Path();
    path1.moveTo(0, size.height * 0.65);
    path1.quadraticBezierTo(size.width * 0.25, size.height * 0.85, size.width * 0.55, size.height * 0.65);
    path1.quadraticBezierTo(size.width * 0.85, size.height * 0.45, size.width, size.height * 0.75);
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, paint1);

    // Layer 2 (Middle)
    final path2 = Path();
    path2.moveTo(0, size.height * 0.75);
    path2.quadraticBezierTo(size.width * 0.2, size.height * 0.6, size.width * 0.5, size.height * 0.8);
    path2.quadraticBezierTo(size.width * 0.8, size.height * 1.0, size.width, size.height * 0.85);
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);

    // Layer 3 (Front)
    final path3 = Path();
    path3.moveTo(0, size.height * 0.85);
    path3.quadraticBezierTo(size.width * 0.3, size.height * 1.0, size.width * 0.7, size.height * 0.85);
    path3.quadraticBezierTo(size.width * 0.9, size.height * 0.75, size.width, size.height * 0.9);
    path3.lineTo(size.width, size.height);
    path3.lineTo(0, size.height);
    path3.close();
    canvas.drawPath(path3, paint3);

    // Dotted Pattern
    final dotPaint = Paint()
      ..color = AppColors.primaryBlue.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Top Right
    for (int i = 0; i < 6; i++) {
      for (int j = 0; j < 6; j++) {
        canvas.drawCircle(
          Offset(size.width * 0.75 + i * 15, size.height * 0.02 + j * 15),
          1.5,
          dotPaint,
        );
      }
    }

    // Bottom Left
    for (int i = 0; i < 6; i++) {
      for (int j = 0; j < 8; j++) {
        canvas.drawCircle(
          Offset(size.width * 0.05 + i * 15, size.height * 0.7 + j * 15),
          1.5,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
