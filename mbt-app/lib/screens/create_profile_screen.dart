import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../widgets/logo_widget.dart';
import '../widgets/wave_background.dart';
import '../services/profile_service.dart';
import 'home_dashboard.dart';
import 'package:go_router/go_router.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({Key? key}) : super(key: key);

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  Uint8List? _avatarBytes;
  String? _avatarPath;
  final ImagePicker _picker = ImagePicker();
  final ProfileService _profileService = ProfileService();
  String _countryCode = '+91';
  final List<String> _countryCodes = ['+20', '+91'];

  @override
  void initState() {
    super.initState();
    final phone = Supabase.instance.client.auth.currentUser?.phone ?? '';
    for (final code in _countryCodes) {
      if (phone.startsWith(code)) {
        _countryCode = code;
        _phoneController.text = phone.substring(code.length);
        return;
      }
    }
    if (phone.startsWith('+')) {
      _phoneController.text = phone.substring(3);
    } else {
      _phoneController.text = phone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your name')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _profileService.createProfile(name);

      if (_avatarBytes != null && _avatarPath != null) {
        try {
          await _profileService.uploadAvatar(_avatarBytes!, _avatarPath!.split('/').last);
        } catch (e) {
          debugPrint('Avatar upload failed: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Avatar upload failed: $e')),
            );
          }
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_signup_flow', false);
      await _profileService.bindDevice(Supabase.instance.client.auth.currentUser!.id);

      if (mounted) {
        context.go('/home');
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStepCircle('1', true),
            _buildStepLine(),
            _buildStepCircle('2', false),
            _buildStepLine(),
            _buildStepCircle('3', false),
          ],
        ),
        centerTitle: true,
      ),
      body: WaveBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
          children: [
            const SizedBox(height: 20),
            const LogoWidget(size: 70),
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Create Your ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                Text('Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Let\'s set up your profile to personalize\nyour learning experience',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textLight, height: 1.4, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 32),

            _buildLabel('Your Name'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter your full name',
                hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
                prefixIcon: const Icon(Icons.person_outline, color: AppColors.primaryBlue),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBlue)),
              ),
            ),
            const SizedBox(height: 24),

            _buildLabel('Upload Photo'),
            const SizedBox(height: 4),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Upload a clear photo of yourself', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.lightBlueBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3), style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  if (_avatarBytes != null)
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: MemoryImage(_avatarBytes!),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                      ),
                      child: const Icon(Icons.cloud_upload_outlined, color: AppColors.primaryBlue, size: 32),
                    ),
                  const SizedBox(height: 16),
                  const Text('Upload your photo', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  const Text('JPG, PNG up to 5MB', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        final bytes = await image.readAsBytes();
                        setState(() {
                          _avatarBytes = bytes;
                          _avatarPath = image.path;
                        });
                      }
                    },
                    icon: const Icon(Icons.image_outlined, size: 18),
                    label: const Text('Choose from Gallery'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: const BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildLabel('Mobile Number'),
            const SizedBox(height: 8),
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(code == '+91' ? '🇮🇳' : '🇪🇬', style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Text(code, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
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
                      decoration: const InputDecoration(
                        hintText: 'Enter your mobile number',
                        hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      keyboardType: TextInputType.phone,
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
                Text('We\'ll use this number to keep your account secure', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
              ],
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
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
                          Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('You can edit these details later from your profile', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
            const SizedBox(height: 32),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 14)),
    );
  }

  Widget _buildStepCircle(String step, bool isActive) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryBlue : Colors.white,
        shape: BoxShape.circle,
        border: isActive ? null : Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Text(step, style: TextStyle(color: isActive ? Colors.white : AppColors.textLight, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStepLine() {
    return Container(
      width: 30,
      height: 1,
      color: AppColors.border,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
