import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class TermsOfServiceScreen extends StatefulWidget {
  final bool showAcceptance;

  const TermsOfServiceScreen({
    Key? key,
    this.showAcceptance = false,
  }) : super(key: key);

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
  bool _isAccepted = false;

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
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Terms of Service',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: widget.showAcceptance ? 120 : 40,
            ),
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
                                Text('1. Acceptance of Terms', style: TextStyle(color: AppColors.primaryBlue, fontSize: 13)),
                                SizedBox(height: 8),
                                Text('2. Eligibility & Account', style: TextStyle(color: AppColors.primaryBlue, fontSize: 13)),
                                SizedBox(height: 8),
                                Text('3. One-Device Policy', style: TextStyle(color: AppColors.primaryBlue, fontSize: 13)),
                                SizedBox(height: 8),
                                Text('4. Content Usage & Anti-Piracy', style: TextStyle(color: AppColors.primaryBlue, fontSize: 13)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('5. Payments & Refunds', style: TextStyle(color: AppColors.primaryBlue, fontSize: 13)),
                                SizedBox(height: 8),
                                Text('6. Course Validity & Access', style: TextStyle(color: AppColors.primaryBlue, fontSize: 13)),
                                SizedBox(height: 8),
                                Text('7. Termination', style: TextStyle(color: AppColors.primaryBlue, fontSize: 13)),
                                SizedBox(height: 8),
                                Text('8. Changes to Terms', style: TextStyle(color: AppColors.primaryBlue, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildSection('1. Acceptance of Terms', 'By accessing or using the MBT Institute app, website, or any of our services, you agree to be bound by these Terms of Service and our Privacy Policy. If you do not agree, please do not use our platform.'),
                _buildSection('2. Eligibility & Account', 'You must be at least 18 years old (or the age of majority in your jurisdiction) to create an account. You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.'),
                _buildSection('3. One-Device Policy', 'Your account is limited to use on one registered device at a time. Logging in on a new device will automatically log out the previous device. This policy helps us ensure the security of your account and prevent unauthorized access.'),
                _buildSection('4. Content Usage & Anti-Piracy', 'All courses, videos, materials, and other content on MBT Institute are protected by copyright and intellectual property laws. You agree not to download, copy, reproduce, distribute, share, or publicly display any content.\n\nScreen Recording & Screenshot Restriction: Screen recording, taking screenshots, or any form of content capture is strictly prohibited. Our platform uses advanced security measures to detect and prevent such activities. Violations may result in immediate account suspension or legal action.'),
                _buildSection('5. Payments & Refunds', 'Hardware Courses: Payments for hardware courses (e.g., physical kits) are non-refundable once the order is confirmed and shipped. Cancellations are only accepted before dispatch.\n\nSoftware Courses: Payments for software courses are generally non-refundable once access is granted. Refunds may be considered in case of duplicate payments or technical issues that prevent access, at our sole discretion.'),
                _buildSection('6. Course Validity & Access', 'Each course has a specific validity period as mentioned on the product page. Access will be granted immediately after successful payment and will remain active for the duration of the validity period. Once expired, access will be revoked.'),
                _buildSection('7. Termination', 'We reserve the right to suspend or terminate your account at any time for violations of these Terms, misuse of the platform, or any activity that may harm MBT Institute or other users.'),
                _buildSection('8. Changes to Terms', 'We may update these Terms of Service from time to time. Changes will be effective immediately upon posting. Continued use of our platform constitutes acceptance of the updated terms.'),
                
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Questions? Contact us at legal@mbtinstitute.com',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.showAcceptance)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, -4),
                      blurRadius: 12,
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _isAccepted,
                          activeColor: AppColors.primaryBlue,
                          onChanged: (value) {
                            setState(() {
                              _isAccepted = value ?? false;
                            });
                          },
                        ),
                        const Expanded(
                          child: Text(
                            'I have read and agree to the Terms of Service',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isAccepted ? AppColors.primaryBlue : Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _isAccepted
                            ? () {
                                context.pop(true);
                              }
                            : null,
                        child: const Text(
                          'Accept & Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
