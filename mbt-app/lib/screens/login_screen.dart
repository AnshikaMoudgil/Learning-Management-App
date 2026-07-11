import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../widgets/logo_widget.dart';
import '../widgets/wave_background.dart';
import 'create_profile_screen.dart';
import 'dashboard_layout.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  String _countryCode = '+91';
  final List<String> _countryCodes = ['+20', '+91'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); // Trigger rebuild to update text dynamically
      }
    });
    
    // onAuthStateChange listener is now handled globally in main.dart
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  final AuthService _authService = AuthService();

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_signup_flow', _tabController.index == 1);
      
      await _authService.signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your phone number')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_signup_flow', _tabController.index == 1);

      await _authService.sendOtp('$_countryCode$phone');
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => OtpScreen(phone: '$_countryCode$phone')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final isLogin = _tabController.index == 0;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: WaveBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
            children: [
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 8),
              const LogoWidget(size: 80),
              const SizedBox(height: 24),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('MBT ', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  Text('Institute', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Learn Today, Lead Tomorrow', style: TextStyle(color: AppColors.textLight, fontSize: 14)),
              const SizedBox(height: 40),
              
              // Dynamic Text based on Tab
              Text(isLogin ? 'Welcome back!' : 'Create an Account', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 8),
              Text(isLogin ? 'Login to continue your learning journey' : 'Sign up to start your learning journey', style: const TextStyle(color: AppColors.textLight, fontSize: 14)),
              const SizedBox(height: 32),
              
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primaryBlue,
                unselectedLabelColor: AppColors.textLight,
                indicatorColor: AppColors.primaryBlue,
                indicatorWeight: 3,
                onTap: (index) {
                  setState(() {}); // Ensure it updates on tap too
                },
                tabs: const [
                  Tab(text: 'Login'),
                  Tab(text: 'Sign Up'),
                ],
              ),
              const SizedBox(height: 32),
              
              _buildOutlinedButton(
                iconWidget: Image.asset('assets/google.png', width: 24, height: 24),
                text: 'Continue with Google',
                onPressed: _isLoading ? () {} : _signInWithGoogle,
              ),
              const SizedBox(height: 24),
              
              const Row(
                children: [
                  Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: AppColors.border)),
                ],
              ),
              const SizedBox(height: 24),
              
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _countryCode,
                          items: _countryCodes.map((code) => DropdownMenuItem(
                            value: code,
                            child: Text(code, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                          )).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _countryCode = val);
                          },
                          isDense: true,
                        ),
                      ),
                    ),
                    Container(width: 1, height: 24, color: AppColors.border),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: 'Enter Phone Number',
                          hintStyle: TextStyle(color: AppColors.textLight, fontSize: 15),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user_outlined, size: 16, color: AppColors.primaryBlue),
                  SizedBox(width: 8),
                  Text('We\'ll send you a OTP to verify your number', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Send OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('By continuing, you agree to our', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Terms of Service', style: TextStyle(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                  Text(' and ', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                  Text('Privacy Policy', style: TextStyle(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildOutlinedButton({
    required Widget iconWidget,
    required String text,
    required VoidCallback onPressed,
    bool showArrow = false,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            iconWidget,
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark),
              ),
            ),
            if (showArrow) const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primaryBlue) else const SizedBox(width: 24),
          ],
        ),
      ),
    );
  }
}
