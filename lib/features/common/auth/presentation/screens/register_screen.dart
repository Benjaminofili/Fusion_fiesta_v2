import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_roles.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../data/models/user.dart';
import '../../../../../core/widgets/upload_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = serviceLocator<AuthService>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _mobileController = TextEditingController();
  final _departmentController = TextEditingController();
  final _enrolmentController = TextEditingController();

  // State Variables
  AppRole _selectedRole = AppRole.visitor; // Default: Student Visitor
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // File Placeholders (In a real app, these would hold the picked file paths)
  String? _profilePicturePath;
  String? _collegeIdPath;
  String? _collegeIdName;


  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _mobileController.dispose();
    _departmentController.dispose();
    _enrolmentController.dispose();
    super.dispose();
  }

  // --- LOGIC HELPERS ---

  bool get _isStaff => _selectedRole == AppRole.organizer || _selectedRole == AppRole.admin;
  bool get _isStudentParticipant => _selectedRole == AppRole.student;

  void _onRoleChanged(AppRole? role) {
    if (role != null) {
      setState(() => _selectedRole = role);
    }
  }

  // --- REGISTRATION LOGIC ---

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    // Additional validation for file uploads
    if (_isStudentParticipant && _collegeIdPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your College ID Proof')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create User Object
      final newUser = User(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        role: _selectedRole,
        mobileNumber: _mobileController.text.trim(),
        department: _departmentController.text.trim(),
        enrolmentNumber: _isStudentParticipant ? _enrolmentController.text.trim() : null,
        profilePictureUrl: _profilePicturePath, // Mock path
        collegeIdUrl: _collegeIdPath, // Mock path

        // Logic: Staff needs approval (isApproved=false).
        // Student Participant is considered "verified" if they upload ID (isApproved=true/pending verification logic).
        // Student Visitor is fully approved immediately.
        isApproved: !_isStaff,
        profileCompleted: true, // We collected all details now
      );

      await _authService.signUp(newUser, _passwordController.text);

      if (!mounted) return;

      // Routing Logic
      if (_isStaff) {
        // Staff must wait for approval
        _showStaffApprovalDialog();
      } else {
        // Students go to dashboard
        context.go(AppRoutes.main);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration Failed: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showStaffApprovalDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Registration Pending'),
        content: const Text(
          'Your Staff account has been created but requires System Admin approval before you can manage events.\n\nYou will be notified via email once approved.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.go(AppRoutes.login); // Go to login
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Create Account', style: TextStyle(color: AppColors.textPrimary)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:  EdgeInsets.all(24.w),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- 1. PROFILE PICTURE (Common) ---
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.surface,
                            backgroundImage: _profilePicturePath != null
                                ? FileImage(File(_profilePicturePath!))
                                : null,
                            child: _profilePicturePath == null
                                ? const Icon(Icons.person, size: 50, color: AppColors.textSecondary)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: UploadPicker(
                              label: 'Profile',
                              allowedExtensions: const ['jpg', 'png', 'jpeg'],
                              onFileSelected: (file) {
                                setState(() {
                                  _profilePicturePath = file.path;
                                });
                              },
                              // CUSTOM CHILD: The Camera Icon Button
                              customChild: CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.primary,
                                child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                     SizedBox(height: 24.h),

                    // --- 2. ROLE SELECTION (FIXED OVERFLOW) ---
                    DropdownButtonFormField<AppRole>(
                      value: _selectedRole,
                      isExpanded: true, // <--- THIS FIXES THE OVERFLOW
                      decoration: _inputDecoration('Select Account Type', Icons.category),
                      items: const [
                        DropdownMenuItem(
                          value: AppRole.visitor,
                          child: Text('Student Visitor (Browse Only)'),
                        ),
                        DropdownMenuItem(
                          value: AppRole.student,
                          // Use FittedBox to scale text down if it's too long
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text('Student Participant (Register for Events)'),
                          ),
                        ),
                        DropdownMenuItem(
                          value: AppRole.organizer,
                          child: Text('Staff (Organizer)'),
                        ),
                      ],
                      onChanged: _onRoleChanged,
                    ),
                    if (_isStaff)
                      Padding(
                        padding:  EdgeInsets.only(top: 8.0, left: 12),
                        child: Text(
                          '⚠️ Staff accounts require Admin approval.',
                          style: TextStyle(color: AppColors.warning, fontSize: 12.sp),
                        ),
                      ),
                     SizedBox(height: 24.h),

                    // --- 3. COMMON FIELDS ---
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration('Full Name', Icons.person_outline),
                      validator: (value) => (value?.length ?? 0) > 2 ? null : 'Name too short',
                    ),
                     SizedBox(height: 16.h),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration('Email Address', Icons.email_outlined),
                      validator: (value) {
                        if (value == null || !value.contains('@')) return 'Invalid email';
                        // Staff Institutional Email Check
                        if (_isStaff && !value.endsWith('.edu')) { // Mock check
                          return 'Staff must use institutional email (.edu)';
                        }
                        return null;
                      },
                    ),
                     SizedBox(height: 16.h),

                    TextFormField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration('Mobile Number', Icons.phone_android),
                      validator: (value) => (value?.length ?? 0) > 9 ? null : 'Invalid mobile number',
                    ),
                     SizedBox(height: 16.h),

                    TextFormField(
                      controller: _departmentController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration('Department', Icons.business),
                      validator: (value) => (value?.length ?? 0) > 1 ? null : 'Required',
                    ),
                     SizedBox(height: 16.h),

                    // --- 4. ROLE SPECIFIC FIELDS ---

                    // A. STUDENT PARTICIPANT FIELDS
                    if (_isStudentParticipant) ...[
                      const Divider(height: 40),
                      Text('Participant Verification', style: Theme.of(context).textTheme.titleMedium),
                       SizedBox(height: 16.h),

                      TextFormField(
                        controller: _enrolmentController,
                        decoration: _inputDecoration('Enrolment Number', Icons.badge),
                        validator: (value) => _isStudentParticipant && (value?.isEmpty ?? true)
                            ? 'Enrolment Number is required'
                            : null,
                      ),
                       SizedBox(height: 16.h),

                      // Mock File Picker for ID Proof
                      UploadPicker(
                        label: 'ID Proof',
                        allowedExtensions: const ['pdf', 'jpg', 'png'],
                        onFileSelected: (file) {
                          setState(() {
                            _collegeIdPath = file.path;
                            _collegeIdName = file.name;
                          });
                        },
                        // CUSTOM CHILD: The styled container
                        customChild: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.upload_file, color: AppColors.primary),
                            title: Text(_collegeIdPath != null
                                ? _collegeIdName ?? 'File Selected'
                                : 'Upload College ID Proof'),
                            subtitle: const Text('Required for event registration'),
                            trailing: _collegeIdPath != null
                                ? const Icon(Icons.check_circle, color: AppColors.success)
                                : null,
                          ),
                        ),
                      ),
                    ],

                     SizedBox(height: 24.h),

                    // --- 5. PASSWORD FIELDS ---
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: _passwordDecoration('Password', _isPasswordVisible, () {
                        setState(() => _isPasswordVisible = !_isPasswordVisible);
                      }),
                      validator: (value) => (value?.length ?? 0) > 5 ? null : 'Min 6 characters',
                    ),
                     SizedBox(height: 16.h),

                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      decoration: _passwordDecoration('Confirm Password', _isConfirmPasswordVisible, () {
                        setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                      }),
                      validator: (value) {
                        if (value != _passwordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),

                     SizedBox(height: 40.h),

                    // --- 6. SUBMIT BUTTON ---
                    SizedBox(
                      height: 56.h,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _register,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: _isLoading
                            ?  CircularProgressIndicator(color: Colors.white)
                            :  Text(
                          'Create Account',
                          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                     SizedBox(height: 24.h),
                     // ----Back to Login ------
                    Center(
                      child: GestureDetector(
                        onTap: () => context.pop(), // Go back to Login
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 14.sp,
                            ),
                            children: [
                              const TextSpan(text: "Already have an account? "),
                              TextSpan(
                                text: 'Login',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h), // Bottom padding
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- STYLE HELPERS ---

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  InputDecoration _passwordDecoration(String label, bool visible, VoidCallback onToggle) {
    return _inputDecoration(label, Icons.lock_outline).copyWith(
      suffixIcon: IconButton(
        icon: Icon(visible ? Icons.visibility : Icons.visibility_off, color: AppColors.textSecondary),
        onPressed: onToggle,
      ),
    );
  }
}