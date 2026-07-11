import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.calendar_today, size: 16, color: AppColors.textLight),
                SizedBox(width: 8),
                Text(
                  'Last updated: May 20, 2025',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.list_alt, size: 18, color: AppColors.primaryBlue),
                      SizedBox(width: 8),
                      Text(
                        'In this document',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('1. Introduction', style: TextStyle(color: AppColors.primaryBlue, fontSize: 13)),
                            SizedBox(height: 8),
                            Text('2. Information We Collect', style: TextStyle(color: AppColors.primaryBlue, fontSize: 13)),
                            SizedBox(height: 8),
                            Text('3. How We Use Your Information', style: TextStyle(color: AppColors.primaryBlue, fontSize: 13)),
                            SizedBox(height: 8),
                            Text('4. How We Store & Protect', style: TextStyle(color: AppColors.primaryBlue, fontSize: 13)),
                            SizedBox(height: 8),
                            Text('5. Data Retention', style: TextStyle(color: AppColors.primaryBlue, fontSize: 13)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('6. Third-Party Services', style: TextStyle(color: AppColors.primaryBlue, fontSize: 13)),
                            SizedBox(height: 8),
                            Text('7. Your Rights & Choices', style: TextStyle(color: AppColors.primaryBlue, fontSize: 13)),
                            SizedBox(height: 8),
                            Text('8. Children\'s Privacy', style: TextStyle(color: AppColors.primaryBlue, fontSize: 13)),
                            SizedBox(height: 8),
                            Text('9. Changes to This Policy', style: TextStyle(color: AppColors.primaryBlue, fontSize: 13)),
                            SizedBox(height: 8),
                            Text('10. Contact Us', style: TextStyle(color: AppColors.primaryBlue, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildSection('1. Introduction', 'MBT Institute ("we", "our", "us") respects your privacy. This Privacy Policy explains how we collect, use, store, and protect your personal information when you use our app, website, and services.'),
            _buildSection('2. Information We Collect', 'We collect the following information to provide a secure and personalized learning experience:\n\n• Personal Information: Mobile number, email address, live photo (for identity verification).\n• Payment Information: Payment metadata including transaction ID, amount, payment status, and billing details (processed securely via Razorpay). We do not store your full card details.\n• Device & Usage Information: Device fingerprint, device type, OS, IP address, app usage, login logs, and other analytics (used for security, fraud prevention, and improving our services).\n• Live Class Information: Information related to your participation in live classes via Zoom.\n• Content Interaction: Your preferences for subtitles/dubbing and related interaction data.'),
            _buildSection('3. How We Use Your Information', 'We use your information to:\n• Create and manage your account\n• Provide and improve our courses and services\n• Process payments and prevent fraud\n• Verify your identity and enforce our one-device policy\n• Communicate important updates, offers, and support\n• Comply with legal obligations'),
            _buildSection('4. How We Store & Protect Your Information', 'We use industry-standard measures to protect your data, including encryption at rest and in transit, secure servers, and strict access controls. Your data is stored securely and accessed only by authorized personnel.'),
            _buildSection('5. Data Retention & Deletion', 'We retain your personal information for as long as your account is active or as needed to provide our services. After account deletion, we retain certain data for up to 180 days for legal and security purposes, after which it is securely deleted or anonymized.'),
            _buildSection('6. Third-Party Services We Use', 'We may share your information with trusted third parties only for the purposes described in this policy.\n\n• Razorpay: For processing payments, issuing refunds, and managing transactions.\n• Zoom: For conducting live classes and managing seminar sessions.'),
            _buildSection('7. Your Rights & Choices', 'You have the right to:\n• Access: View the personal information we hold about you.\n• Update: Request correction of inaccurate information.\n• Delete: Request deletion of your personal information.\n• Export: Request a copy of your data.\n\nTo exercise any of these rights, contact us at privacy@mbtinstitute.com.'),
            _buildSection('8. Children\'s Privacy', 'Our services are not intended for individuals under 18. We do not knowingly collect information from children.'),
            _buildSection('9. Changes to This Policy', 'We may update this Privacy Policy from time to time. Changes will be effective immediately upon posting. Please review this page periodically.'),
            _buildSection('10. Contact Us', 'For any privacy-related questions or requests, please contact:\n\nMBT Institute - Privacy Team\nprivacy@mbtinstitute.com\n+91 87900 12345'),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
