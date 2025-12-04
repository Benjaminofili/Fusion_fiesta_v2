import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../core/widgets/upload_picker.dart';
import '../../../../../data/models/user.dart';
import '../../../../../data/repositories/user_repository.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = serviceLocator<AuthService>();
  final UserRepository _userRepository = serviceLocator<UserRepository>();

  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  late TextEditingController _deptController; // Read-only for students usually, but editable here for demo
  String? _profilePicPath;

  bool _isLoading = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _mobileController = TextEditingController();
    _deptController = TextEditingController();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.currentUser;
    if (user != null) {
      setState(() {
        _currentUser = user;
        _nameController.text = user.name;
        _mobileController.text = user.mobileNumber ?? '';
        _deptController.text = user.department ?? '';
        _profilePicPath = user.profilePictureUrl;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _deptController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      final updatedUser = _currentUser!.copyWith(
        name: _nameController.text.trim(),
        mobileNumber: _mobileController.text.trim(),
        department: _deptController.text.trim(),
        profilePictureUrl: _profilePicPath,
      );

      // 1. Update Backend
      await _userRepository.updateUser(updatedUser);

      // 2. Update Local Session
      await _authService.updateUserSession(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: AppColors.success),
        );
        context.pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- Profile Pic ---
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      backgroundImage: _profilePicPath != null ? NetworkImage(_profilePicPath!) : null, // In real app, handle FileImage vs NetworkImage
                      child: _profilePicPath == null
                          ? const Icon(Icons.person, size: 50, color: AppColors.primary)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: UploadPicker(
                        label: 'Edit',
                        allowedExtensions: const ['jpg', 'png'],
                        onFileSelected: (file) => setState(() => _profilePicPath = file.path), // Mocking path usage
                        customChild: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- Fields ---
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Full Name', Icons.person_outline),
                validator: (v) => v!.isEmpty ? 'Name cannot be empty' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration('Mobile Number', Icons.phone_android),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _deptController,
                decoration: _inputDecoration('Department', Icons.school_outlined),
              ),
              const SizedBox(height: 16),

              // Email is typically read-only
              TextFormField(
                initialValue: _currentUser!.email,
                readOnly: true,
                decoration: _inputDecoration('Email', Icons.email_outlined).copyWith(
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}