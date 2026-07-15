import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'renew_course_screen.dart';
import 'package:go_router/go_router.dart';
import '../widgets/cart_badge.dart';

class CourseValidityScreen extends StatelessWidget {
  const CourseValidityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Course Validity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            Text('Manage and extend your course access', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
          ],
        ),
        actions: [
          const CartBadge(),
          const SizedBox(width: 8),
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.lightBlueBg, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.notifications_outlined, color: AppColors.textDark, size: 18),
              ),
              Positioned(
                right: 0, top: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFE0B2), Color(0xFFFFCC80)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.access_time, color: Colors.deepOrange, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Courses Expiring Soon', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        SizedBox(height: 2),
                        Text('Renew your courses to continue learning\nwithout interruption.', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.visibility_outlined, size: 14, color: AppColors.textDark),
                    label: const Text('View All Courses', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.textDark),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Expiring Soon
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Expiring Soon', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            ),
            const SizedBox(height: 12),
            _buildExpiringCourse(
              context,
              'React JS - Complete Guide',
              'By Coding Academy',
              '75% Completed',
              'Valid till: 15 Jun 2024',
              '07',
              const Color(0xFFE53935),
              true,
              'React\nJS',
              const Color(0xFF61DAFB),
              0.75,
            ),
            _buildExpiringCourse(
              context,
              'Spring Boot Development',
              'By Tech Learn',
              '60% Completed',
              'Valid till: 22 Jun 2024',
              '14',
              const Color(0xFFFF9800),
              true,
              'Spring\nBoot',
              const Color(0xFF66BB6A),
              0.60,
            ),
            _buildExpiringCourse(
              context,
              'Java Programming Masterclass',
              'By CodeWorld',
              '40% Completed',
              'Valid till: 05 Jul 2024',
              '27',
              const Color(0xFFFF9800),
              true,
              'JAVA',
              Colors.white,
              0.40,
            ),
            const SizedBox(height: 24),

            // Expiring in 30+ Days
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Expiring in 30+ Days', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            ),
            const SizedBox(height: 12),
            _buildLaterCourse('Python for Data Science', 'By DataCamp', 'Valid till: 28 Jul 2024', '50', const Color(0xFF3776AB)),
            _buildLaterCourse('Node.js Backend Development', 'By Dev Academy', 'Valid till: 16 Aug 2024', '69', const Color(0xFF8BC34A)),
            const SizedBox(height: 16),

            // Why Renew Early
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.lightBlueBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, size: 18, color: AppColors.primaryBlue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Why renew early?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        SizedBox(height: 2),
                        Text('Renewing early ensures uninterrupted access, progress retention, and access to new updates.', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textLight, size: 18),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Renew Now Banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFC8E6C9)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFF43A047).withOpacity(0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.card_giftcard, color: Color(0xFF43A047), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Renew Now & Get More!', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        SizedBox(height: 2),
                        Text('Renew any course before expiry and get 10% OFF\non your next course.', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF43A047)),
                    ),
                    child: const Text('10% OFF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF43A047))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // View All Courses Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.primaryBlue),
                  label: const Text('View All My Courses', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryBlue),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiringCourse(BuildContext context, String title, String author, String progress, String validTill, String days, Color daysColor, bool showRenew, String iconText, Color iconTextColor, double progressValue) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(iconText, textAlign: TextAlign.center, style: TextStyle(color: iconTextColor, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(author, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: LinearProgressIndicator(
                        value: progressValue,
                        backgroundColor: AppColors.lightBlueBg,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primaryBlue),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(progress, style: const TextStyle(fontSize: 9, color: AppColors.primaryBlue, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 10, color: AppColors.textLight),
                    const SizedBox(width: 4),
                    Text(validTill, style: const TextStyle(fontSize: 9, color: AppColors.textLight)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: daysColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text('Expires in', style: TextStyle(fontSize: 8, color: daysColor)),
                    Text(days, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: daysColor)),
                    Text('Days', style: TextStyle(fontSize: 8, color: daysColor)),
                  ],
                ),
              ),
              if (showRenew) ...[
                const SizedBox(height: 6),
                SizedBox(
                  height: 28,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/renew-course');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: daysColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      elevation: 0,
                    ),
                    child: const Text('Renew Now', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLaterCourse(String title, String author, String validTill, String days, Color iconColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.code, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(author, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 10, color: AppColors.textLight),
                    const SizedBox(width: 4),
                    Text(validTill, style: const TextStyle(fontSize: 9, color: AppColors.textLight)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text('Expires in', style: TextStyle(fontSize: 8, color: Colors.grey[600])),
              Text(days, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              Text('Days', style: TextStyle(fontSize: 8, color: Colors.grey[600])),
            ],
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: AppColors.textLight, size: 18),
        ],
      ),
    );
  }
}
