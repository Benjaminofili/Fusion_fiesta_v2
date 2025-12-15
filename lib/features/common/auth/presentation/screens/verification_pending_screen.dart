import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/constants/app_roles.dart'; // Make sure this is imported
import '../../../../../core/services/auth_service.dart';
import '../../../../../data/models/user.dart';
import '../../../../../data/repositories/user_repository.dart';

class VerificationPendingScreen extends StatefulWidget {
  const VerificationPendingScreen({super.key});

  @override
  State<VerificationPendingScreen> createState() => _VerificationPendingScreenState();
}

class _VerificationPendingScreenState extends State<VerificationPendingScreen> {
  final _userRepo = serviceLocator<UserRepository>();
  final _authService = serviceLocator<AuthService>();

  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final user = await _authService.currentUser;
    if (mounted) setState(() => _currentUserId = user?.id);
  }

  Future<void> _handleApproval(User approvedUser) async {
    // 1. Update Local Session with new status
    await _authService.updateUserSession(approvedUser);

    if (!mounted) return;

    // 2. Notify User
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account Approved! Logging you in...'),
        backgroundColor: AppColors.success,
      ),
    );

    // 3. Auto-Navigate to Dashboard
    context.go(AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<List<User>>(
        // Listen to the Live Database Stream
        stream: _userRepo.getUsersStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          // Find 'me' in the database
          final me = snapshot.data!.firstWhere(
                (u) => u.id == _currentUserId,
            // ✅ FIX: Use a static default instead of await
            orElse: () => const User(
                id: '',
                name: '',
                email: '',
                role: AppRole.organizer, // Default safe assumption for this screen
                isApproved: false
            ),
          );

          // CHECK: Are we approved yet?
          if (me.isApproved && me.id.isNotEmpty) {
            // Trigger navigation safely after build
            WidgetsBinding.instance.addPostFrameCallback((_) => _handleApproval(me));
          }

          return Padding(
            padding: EdgeInsets.all(32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Visual Indicator
                Icon(Icons.hourglass_top_rounded, size: 80.sp, color: Colors.orange),
                SizedBox(height: 32.h),

                Text(
                  'Verification Pending',
                  style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Your Organizer account is currently being reviewed by an Administrator.\n\nThis screen will automatically update once your request is approved.',
                  style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 48.h),

                // Option to logout/cancel
                OutlinedButton(
                  onPressed: () {
                    _authService.signOut();
                    context.go(AppRoutes.login);
                  },
                  child: const Text('Cancel & Logout'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}