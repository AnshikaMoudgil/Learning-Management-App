import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../widgets/logo_widget.dart';
import '../widgets/wave_background.dart';
import 'create_profile_screen.dart';
import 'dashboard_layout.dart';
import 'package:go_router/go_router.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({Key? key, required this.phone}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  bool _isLoading = false;
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _startTimer() {
    setState(() => _timerSeconds = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  int _timerSeconds = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  final AuthService _authService = AuthService();

  Future<void> _verifyOtp() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter all 6 digits')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _authService.verifyOtp(widget.phone, code);
      // Navigation is now handled globally in main.dart via onAuthStateChange
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_timerSeconds > 0) return;
    
    setState(() => _isLoading = true);
    try {
      await _authService.sendOtp(widget.phone);
      _startTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP Resent Successfully')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error resending OTP: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
      ),
      body: WaveBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
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
                
                const Text('Verify your phone number', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 12),
                const Text('Enter the 6-digit OTP sent to', style: TextStyle(color: AppColors.textLight, fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.phone, style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 8),
                    const Icon(Icons.edit, color: AppColors.primaryBlue, size: 16),
                  ],
                ),
                const SizedBox(height: 32),
                
                // OTP Boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) => _buildOtpBox(index)),
                ),
                const SizedBox(height: 24),
                
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_user_outlined, size: 16, color: AppColors.primaryBlue),
                    SizedBox(width: 8),
                    Text('OTP is valid for ', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                    Text('02:00', style: TextStyle(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                    Text(' minutes', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                  ],
                ),
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Verify & Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 40),
                
                const Text('Didn\'t receive the OTP?', style: TextStyle(color: AppColors.textLight, fontSize: 14)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.refresh, color: AppColors.primaryBlue, size: 18),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: _timerSeconds == 0 ? _resendOtp : null,
                      child: Text('Resend OTP', style: TextStyle(color: _timerSeconds == 0 ? AppColors.primaryBlue : AppColors.textLight, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '00:${_timerSeconds.toString().padLeft(2, '0')}', 
                      style: const TextStyle(color: AppColors.textLight, fontSize: 14)
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
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
                
                TextButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.phone_outlined, color: AppColors.primaryBlue, size: 18),
                  label: const Text('Change Phone Number', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 40),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_outline, size: 14, color: AppColors.primaryBlue),
                      SizedBox(width: 8),
                      Text('Your data is safe and secure with us.', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: index == 5 ? AppColors.primaryBlue : AppColors.border),
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
          ),
          onChanged: (val) => _onChanged(val, index),
        ),
      ),
    );
  }
}
