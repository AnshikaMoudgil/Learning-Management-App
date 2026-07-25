import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import '../services/profile_service.dart';
import 'package:go_router/go_router.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  Uint8List? _avatarBytes;
  String? _avatarPath;
  final ImagePicker _picker = ImagePicker();
  final ProfileService _profileService = ProfileService();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _existingAvatarUrl;

  String? _nameError;
  String? _phoneError;
  String? _emailError;

  bool _phoneReadOnly = false;
  bool _emailReadOnly = false;
  String _countryCode = '+91';
  final List<String> _countryCodes = ['+20', '+91'];

  static const int _bioMaxChars = 1000;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileService.getProfile();
      final user = Supabase.instance.client.auth.currentUser;

      if (mounted) {
        setState(() {
          _nameController.text = profile.fullName ?? '';

          final hasAuthPhone = user?.phone != null && user!.phone!.isNotEmpty;
          final hasAuthEmail = user?.email != null && user!.email!.isNotEmpty;

          _phoneReadOnly = hasAuthPhone;
          _emailReadOnly = hasAuthEmail;

          final phoneSource =
              (profile.phone != null && profile.phone!.isNotEmpty)
              ? profile.phone!
              : (user?.phone ?? '');
          if (phoneSource.isNotEmpty) {
            for (final code in _countryCodes) {
              if (phoneSource.startsWith(code)) {
                _countryCode = code;
                _phoneController.text = phoneSource.substring(code.length);
                break;
              }
            }
            if (_phoneController.text.isEmpty) {
              _phoneController.text = phoneSource;
            }
          }

          final emailSource =
              (profile.email != null && profile.email!.isNotEmpty)
              ? profile.email!
              : (user?.email ?? '');
          _emailController.text = emailSource;

          _bioController.text = profile.about ?? '';
          _existingAvatarUrl = profile.avatarUrl;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _avatarBytes = bytes;
        _avatarPath = image.path;
      });
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final bio = _bioController.text.trim();

    setState(() {
      _nameError = null;
      _phoneError = null;
      _emailError = null;
    });

    bool hasError = false;

    if (name.isEmpty) {
      setState(() => _nameError = 'Full name is required');
      hasError = true;
    } else if (RegExp(r'[0-9]').hasMatch(name)) {
      setState(() => _nameError = 'Name must contain only letters');
      hasError = true;
    }

    if (!_phoneReadOnly) {
      if (phone.isEmpty) {
        setState(() => _phoneError = 'Phone number is required');
        hasError = true;
      } else if (!RegExp(r'^\d+$').hasMatch(phone)) {
        setState(() => _phoneError = 'Only numbers allowed');
        hasError = true;
      }
    }

    if (!_emailReadOnly) {
      if (email.isEmpty) {
        setState(() => _emailError = 'Email address is required');
        hasError = true;
      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
        setState(() => _emailError = 'Please enter a valid email address');
        hasError = true;
      }
    }

    if (bio.length > _bioMaxChars) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bio must not exceed 1000 characters')),
      );
      return;
    }

    if (hasError) return;

    setState(() => _isSaving = true);
    try {
      await _profileService.updateProfile(
        name,
        phone: !_phoneReadOnly && phone.isNotEmpty
            ? '$_countryCode$phone'
            : null,
        email: !_emailReadOnly && email.isNotEmpty ? email : null,
        about: _bioController.text.trim().isNotEmpty
            ? _bioController.text.trim()
            : null,
      );

      if (_avatarBytes != null && _avatarPath != null) {
        await _profileService.uploadAvatar(
          _avatarBytes!,
          _avatarPath!.split('/').last,
        );
      } else if (_avatarBytes == null &&
          _avatarPath == null &&
          _existingAvatarUrl == null) {
        await _profileService.deleteAvatar();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Update your personal information',
              style: TextStyle(fontSize: 14, color: AppColors.textLight),
            ),
            const SizedBox(height: 32),

            const Text(
              'Profile Photo',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primaryBlue,
                      child: _avatarBytes != null
                          ? ClipOval(
                              child: Image.memory(
                                _avatarBytes!,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                              ),
                            )
                          : _existingAvatarUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    _existingAvatarUrl!,
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 50,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 50,
                                ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.lightBlueBg,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: AppColors.primaryBlue,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Upload new photo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'JPG, PNG or WEBP. Max size 2MB.\nRecommended size 400x400px.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textLight,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(
                              Icons.file_upload_outlined,
                              size: 16,
                              color: AppColors.primaryBlue,
                            ),
                            label: const Text(
                              'Change Photo',
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppColors.primaryBlue,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                          if (_avatarBytes != null ||
                              _existingAvatarUrl != null)
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _avatarBytes = null;
                                  _avatarPath = null;
                                  _existingAvatarUrl = null;
                                });
                              },
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 16,
                                color: Colors.red,
                              ),
                              label: const Text(
                                'Remove',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),

            _buildEditableField(
              'Full Name',
              _nameController,
              icon: Icons.person_outline,
              required: true,
              errorText: _nameError,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
              ],
            ),
            const SizedBox(height: 16),

            _buildLabel('Phone Number', required: true),
            const SizedBox(height: 8),
            _buildPhoneField(errorText: _phoneError),
            const SizedBox(height: 16),

            _buildEditableField(
              'Email Address',
              _emailController,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              readOnly: _emailReadOnly,
              required: true,
              errorText: _emailError,
            ),
            const SizedBox(height: 16),

            _buildEditableField('Bio', _bioController, maxLines: 3, maxLength: _bioMaxChars),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => context.pop(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneField({String? errorText}) {
    final borderColor = errorText != null ? Colors.red : AppColors.border;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(8),
            color: _phoneReadOnly ? const Color(0xFFF5F5F5) : null,
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _countryCode,
                    items: _countryCodes
                        .map(
                          (code) => DropdownMenuItem(
                            value: code,
                            child: Text(
                              code,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: _phoneReadOnly
                        ? null
                        : (val) {
                            if (val != null) setState(() => _countryCode = val);
                          },
                    isDense: true,
                  ),
                ),
              ),
              Container(width: 1, height: 24, color: borderColor),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  readOnly: _phoneReadOnly,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    hintText: 'Enter your mobile number',
                    hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              errorText,
              style: const TextStyle(fontSize: 11, color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
          children: required
              ? [
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ]
              : null,
        ),
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller, {
    IconData? icon,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    bool readOnly = false,
    bool required = false,
    String? errorText,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, required: required),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          maxLengthEnforcement: maxLength != null
              ? MaxLengthEnforcement.enforced
              : MaxLengthEnforcement.none,
          keyboardType: keyboardType,
          readOnly: readOnly,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            prefixIcon: icon != null
                ? Icon(icon, size: 18, color: AppColors.textLight)
                : null,
            errorText: errorText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryBlue),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: readOnly,
            fillColor: readOnly ? const Color(0xFFF5F5F5) : null,
          ),
        ),
      ],
    );
  }
}
