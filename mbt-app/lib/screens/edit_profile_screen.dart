import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  Uint8List? _avatarBytes;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String? _existingAvatarUrl;

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      _nameController.text = user.userMetadata?['custom_full_name'] ?? user.userMetadata?['full_name'] ?? '';
      _phoneController.text = user.userMetadata?['custom_phone'] ?? user.phone ?? user.userMetadata?['phone'] ?? '';
      _existingAvatarUrl = user.userMetadata?['custom_avatar_url'] ?? user.userMetadata?['avatar_url'];
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => _avatarBytes = bytes);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      String? avatarUrl = _existingAvatarUrl;
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (_avatarBytes != null && userId != null) {
        final imagePath = '$userId/avatar.png';
        await Supabase.instance.client.storage.from('avatars').uploadBinary(
          imagePath,
          _avatarBytes!,
          fileOptions: const FileOptions(upsert: true, contentType: 'image/png'),
        );
        avatarUrl = Supabase.instance.client.storage.from('avatars').getPublicUrl(imagePath);
      }
      
      final Map<String, dynamic> data = {
        'full_name': _nameController.text,
        'custom_full_name': _nameController.text,
        'phone': _phoneController.text,
        'custom_phone': _phoneController.text,
      };
      if (avatarUrl != null) {
        data['avatar_url'] = avatarUrl;
        data['custom_avatar_url'] = avatarUrl;
      }
      if (_avatarBytes == null && _existingAvatarUrl == null) {
        data['avatar_url'] = null;
        data['custom_avatar_url'] = null;
      }

      await Supabase.instance.client.auth.updateUser(UserAttributes(
        data: data,
      ));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Edit Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 4),
            const Text('Update your personal information', style: TextStyle(fontSize: 14, color: AppColors.textLight)),
            const SizedBox(height: 32),
            
            const Text('Profile Photo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 16),
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primaryBlue,
                      backgroundImage: _avatarBytes != null
                          ? MemoryImage(_avatarBytes!)
                          : (_existingAvatarUrl != null ? NetworkImage(_existingAvatarUrl!) : null) as ImageProvider?,
                      child: (_avatarBytes == null && _existingAvatarUrl == null)
                          ? const Icon(Icons.person, color: Colors.white, size: 50)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: AppColors.lightBlueBg, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                          child: const Icon(Icons.camera_alt, color: AppColors.primaryBlue, size: 14),
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
                      const Text('Upload new photo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
                      const SizedBox(height: 4),
                      const Text('JPG, PNG or WEBP. Max size 2MB.\nRecommended size 400x400px.', style: TextStyle(fontSize: 11, color: AppColors.textLight, height: 1.4)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.file_upload_outlined, size: 16, color: AppColors.primaryBlue),
                            label: const Text('Change Photo', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primaryBlue),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                          ),
                          if (_avatarBytes != null || _existingAvatarUrl != null)
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _avatarBytes = null;
                                  _existingAvatarUrl = null;
                                });
                              },
                              icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                              label: const Text('Remove', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            const Text('Personal Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 16),
            
            _buildEditableField('Full Name', _nameController, icon: Icons.person_outline),
            const SizedBox(height: 16),
            _buildEditableField('Phone Number (Optional)', _phoneController, icon: Icons.phone_outlined),
            const SizedBox(height: 16),
            _buildEditableField('Bio', _bioController, maxLines: 3),
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, {IconData? icon, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, size: 18, color: AppColors.textLight) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryBlue)),
          ),
        ),
      ],
    );
  }
}
