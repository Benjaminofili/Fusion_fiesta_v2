import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/constants/app_roles.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../core/widgets/upload_picker.dart';
import '../../../../../data/repositories/user_repository.dart';

class RoleUpgradeScreen extends StatefulWidget {
  const RoleUpgradeScreen({super.key});

  @override
  State<RoleUpgradeScreen> createState() => _RoleUpgradeScreenState();
}

class _RoleUpgradeScreenState extends State<RoleUpgradeScreen> {
  final _formKey = GlobalKey<FormState>();

  // Dependencies
  final AuthService _authService = serviceLocator<AuthService>();
  final UserRepository _userRepository = serviceLocator<UserRepository>();

  // Controllers
  final _enrolmentController = TextEditingController();
  final _departmentController = TextEditingController();

  // State
  bool _isLoading = false;
  String? _collegeIdPath;
  String? _collegeIdName;

  @override
  void dispose() {
    _enrolmentController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _submitUpgrade() async {
    if (!_formKey.currentState!.validate()) return;

    if (_collegeIdPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your College ID Proof')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Get Current User
      final currentUser = _authService.currentUser;
      if (currentUser == null) throw Exception('User session not found');

      // 2. Create Updated User Object with Participant Role
      final updatedUser = currentUser.copyWith(
        role: AppRole.student, // Upgrade to Participant
        enrolmentNumber: _enrolmentController.text.trim(),
        department: _departmentController.text.trim(),
        collegeIdUrl: _collegeIdPath,
        profileCompleted: true,
        isApproved:
            true, // SRS implies verification is mocked/skipped or instant
      );

      // 3. Update Backend
      await _userRepository.updateUser(updatedUser);

      // 4. Update Local Session (AuthService & Storage)
      await _authService.updateUserSession(updatedUser);

      if (!mounted) return;

      // 5. Success & Navigate
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile Upgraded! You can now register for events.'),
          backgroundColor: AppColors.success,
        ),
      );

      // Navigate to Main Dashboard (now accessible as Student)
      context.go(AppRoutes.main);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upgrade Failed: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
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
        // If this is a forced redirect, we might not want a back button,
        // but providing one allows them to go back to "Visitor Mode" (Catalog)
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () =>
              context.go(AppRoutes.main), // Go back to limited view
        ),
        title: const Text('Complete Profile',
            style: TextStyle(color: AppColors.textPrimary)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header ---
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.verified_user_outlined,
                            size: 40.sp, color: AppColors.primary),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Become a Participant',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                'Unlocks Event Registration & Certificates',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),

                  Text(
                    'Academic Details',
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.h),

                  // --- Enrolment Number ---
                  TextFormField(
                    controller: _enrolmentController,
                    decoration: _inputDecoration(
                        'Enrolment Number', Icons.badge_outlined),
                    validator: (value) =>
                        (value?.isEmpty ?? true) ? 'Required' : null,
                  ),
                  SizedBox(height: 16.h),

                  // --- Department ---
                  TextFormField(
                    controller: _departmentController,
                    textCapitalization: TextCapitalization.words,
                    decoration:
                        _inputDecoration('Department', Icons.school_outlined),
                    validator: (value) =>
                        (value?.isEmpty ?? true) ? 'Required' : null,
                  ),
                  SizedBox(height: 32.h),

                  Text(
                    'Verification',
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.h),

                  // --- ID Proof Upload ---
                  UploadPicker(
                    label: 'Upload ID Proof',
                    allowedExtensions: const ['jpg', 'png', 'pdf'],
                    onFileSelected: (file) {
                      setState(() {
                        _collegeIdPath = file.path;
                        _collegeIdName = file.name;
                      });
                    },
                    customChild: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12.r),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: _collegeIdPath != null
                                  ? AppColors.success.withValues(alpha:0.1)
                                  : Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _collegeIdPath != null
                                  ? Icons.check
                                  : Icons.upload_file,
                              color: _collegeIdPath != null
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _collegeIdName ?? 'Upload College ID',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                    fontSize: 14.sp,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'PDF, JPG or PNG (Max 5MB)',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // --- Submit Button ---
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _submitUpgrade,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Upgrade to Participant',
                              style: TextStyle(
                                  fontSize: 16.sp, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
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
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}
