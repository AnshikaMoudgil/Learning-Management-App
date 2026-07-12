import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/logo_widget.dart';
import '../widgets/wave_background.dart';
import 'login_screen.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: WaveBackground(
        child: SafeArea(
          child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0, top: 8.0),
                child: TextButton(
                  onPressed: () {
                     context.push('/login');
                  },
                  child: const Text('Skip', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const LogoWidget(size: 70),
            const SizedBox(height: 16),
            const Text(
              'Welcome to',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textDark),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'MBT ',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                Text(
                  'Institute',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Your journey to skills, knowledge\nand success starts here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textLight, height: 1.5),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildFeatureCard('assets/1.png', 'Learn Anywhere', 'Access your courses anytime, anywhere on any device.'),
                  _buildFeatureCard('assets/2.png', 'Live Classes', 'Join live interactive classes and learn from expert instructors.'),
                  _buildFeatureCard('assets/3.png', 'Recorded Courses', 'Learn at your own pace with high-quality recorded courses.'),
                  _buildFeatureCard('assets/4.png', 'Secure Learning', 'Your data and progress are safe with enterprise-grade security.'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Get Started', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) => _buildDot(index == 0)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildFeatureCard(String imagePath, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.lightBlueBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(imagePath, width: 56, height: 56, fit: BoxFit.contain),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textLight, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.check_circle, color: AppColors.primaryBlue, size: 20),
        ],
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryBlue : AppColors.border,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
