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
import '../../../../../core/constants/app_roles.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../data/models/user.dart';
import '../../../../../core/widgets/upload_picker.dart';
import '../../../../../core/widgets/app_text_field.dart';


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

  // File Placeholders
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

  // FIX: Department is required for Participants AND Staff, but NOT for Visitors
  bool get _isDepartmentRequired => _isStudentParticipant || _isStaff;

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

        // FIX: Send null for Department if user is a Visitor
        department: _isDepartmentRequired ? _departmentController.text.trim() : null,

        enrolmentNumber: _isStudentParticipant ? _enrolmentController.text.trim() : null,
        profilePictureUrl: _profilePicturePath,
        collegeIdUrl: _collegeIdPath,

        // Logic: Staff needs approval.
        // Students (Visitor OR Participant) are approved to enter the system immediately.
        // Participants are "verified" by providing the extra details.
        isApproved: !_isStaff,
        profileCompleted: true,
      );

      await _authService.signUp(newUser, _passwordController.text);

      if (!mounted) return;

      // Routing Logic
      if (_isStaff) {
        _showStaffApprovalDialog();
      } else {
        // Both Visitor and Participant go to dashboard
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
              context.pop();
              context.go(AppRoutes.login);
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
            padding: EdgeInsets.all(24.w),
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

                    // --- 2. ROLE SELECTION ---
                    DropdownButtonFormField<AppRole>(
                      value: _selectedRole,
                      isExpanded: true,
                      decoration: _inputDecoration('Select Account Type', Icons.category),
                      items: const [
                        DropdownMenuItem(
                          value: AppRole.visitor,
                          child: Text('Student Visitor (Browse Only)'),
                        ),
                        DropdownMenuItem(
                          value: AppRole.student,
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
                        padding: const EdgeInsets.only(top: 8.0, left: 12),
                        child: Text(
                          '⚠️ Staff accounts require Admin approval.',
                          style: TextStyle(color: AppColors.warning, fontSize: 12.sp),
                        ),
                      ),
                    SizedBox(height: 24.h),

                    // --- 3. COMMON FIELDS (Name, Email, Mobile) ---
                    AppTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      prefixIcon: Icons.person_outline,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) => (value?.length ?? 0) > 2 ? null : 'Name too short',
                    ),
                    SizedBox(height: 16.h),

                    AppTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || !value.contains('@')) return 'Invalid email';
                        if (_isStaff && !value.endsWith('.edu')) return 'Staff must use .edu email';
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    AppTextField(
                      controller: _mobileController,
                      label: 'Mobile Number',
                      prefixIcon: Icons.phone_android,
                      keyboardType: TextInputType.phone,
                      validator: (value) => (value?.length ?? 0) > 9 ? null : 'Invalid mobile number',
                    ),
                    SizedBox(height: 16.h),

                    // --- 4. ROLE SPECIFIC FIELDS ---
                    // FIX: Moved Department here. It is only visible for Participants & Staff.

                    if (_isDepartmentRequired) ...[
                      AppTextField(
                        controller: _departmentController,
                        label: 'Department',
                        prefixIcon: Icons.business,
                        textCapitalization: TextCapitalization.words,
                        validator: (value) => _isDepartmentRequired && (value?.length ?? 0) < 2
                            ? 'Department is required'
                            : null,
                      ),
                      SizedBox(height: 16.h),
                    ],

                    if (_isStudentParticipant) ...[
                      const Divider(height: 40),
                      Text('Participant Verification', style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: 16.h),

                      AppTextField(
                        controller: _enrolmentController,
                        label: 'Enrolment Number',
                        prefixIcon: Icons.badge,
                        validator: (value) => _isStudentParticipant && (value?.isEmpty ?? true)
                            ? 'Required'
                            : null,
                      ),
                      SizedBox(height: 16.h),

                      UploadPicker(
                        label: 'ID Proof',
                        allowedExtensions: const ['pdf', 'jpg', 'png'],
                        onFileSelected: (file) {
                          setState(() {
                            _collegeIdPath = file.path;
                            _collegeIdName = file.name;
                          });
                        },
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
                    AppTextField(
                      controller: _passwordController,
                      label: 'Password',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      validator: (value) => (value?.length ?? 0) > 5 ? null : 'Min 6 characters',
                    ),
                    SizedBox(height: 16.h),

                    AppTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
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
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                          'Create Account',
                          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    Center(
                      child: GestureDetector(
                        onTap: () => context.pop(),
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
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20.sp), // Added size
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w), // Added .h .w
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r), // Added .r
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r), // Added .r
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r), // Added .r
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

}