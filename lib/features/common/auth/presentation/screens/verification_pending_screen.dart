import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../data/repositories/user_repository.dart';
import '../../../../../data/models/user.dart';

class VerificationPendingScreen extends StatefulWidget {
  const VerificationPendingScreen({super.key});

  @override
  State<VerificationPendingScreen> createState() => _VerificationPendingScreenState();
}

class _VerificationPendingScreenState extends State<VerificationPendingScreen> {
  final AuthService _authService = serviceLocator<AuthService>();
  final UserRepository _userRepo = serviceLocator<UserRepository>();

  // Get current raw Auth ID (not the full user profile yet)
  final String _currentAuthId = supabase.Supabase.instance.client.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    // Safety check: if no auth ID, force back to login
    if (_currentAuthId.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.login);
      });
    }
  }

  Future<void> _handleApproval(User updatedUser) async {
    // 1. Update the global session with fresh data
    await _authService.updateUserSession(updatedUser);

    // 2. Redirect to dashboard
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account Approved! Welcome.'),
          backgroundColor: AppColors.success,
        ),
      );
      // Logic to decide dashboard is handled by router or manually here:
      context.go(AppRoutes.organizerDashboard); // Or Organizer dashboard based on role
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _authService.signOut();
    } catch (e) {
      debugPrint("Logout error (harmless): $e");
    } finally {
      // Always go to login, even if API failed
      if (mounted) context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        // Listen to the DB row in Real-time
        stream: _userRepo.getUserStream(_currentAuthId),
        builder: (context, snapshot) {

          // 1. Handle Loading/Errors
          if (snapshot.hasError) {
            return _buildErrorState('Connection Error: ${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data!;

          // 2. AUTO-REDIRECT if Approved
          // We use a microtask to avoid "setState during build" errors
          if (user.isApproved) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _handleApproval(user);
            });
            return const Center(child: CircularProgressIndicator());
          }

          // 3. Show "Pending" UI
          return Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security_update_warning, size: 80, color: Colors.orange),
                const SizedBox(height: 24),
                const Text(
                  'Verification Pending',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your Organizer account is currently under review.\n\n'
                      'Name: ${user.name}\n'
                      'Role: ${user.role.name.toUpperCase()}\n\n'
                      'You will be automatically redirected here once an Admin approves your request.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], height: 1.5),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _handleLogout,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Logout'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(msg, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _handleLogout,
            child: const Text("Go Back to Login"),
          )
        ],
      ),
    );
  }
}