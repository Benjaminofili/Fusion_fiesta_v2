import 'package:flutter/material.dart';
import 'package:fusion_fiesta/core/services/storage_service.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart'; // Import Lottie

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/constants/app_roles.dart';
import '../../../../../core/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = serviceLocator<AuthService>();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // 1. Wait for animation
    await Future<void>.delayed(const Duration(milliseconds: 10000));

    try {
      final user = await _authService.currentUser;

      // Get the storage service to check the flag
      final storageService = serviceLocator<StorageService>(); // Add this line

      if (!mounted) return;

      if (user != null) {
        // If user is logged in, check profile status
        if (user.role == AppRole.visitor && !user.profileCompleted) {
          context.go(AppRoutes.roleUpgrade);
        } else {
          context.go(AppRoutes.main);
        }
      } else {
        // 2. NEW LOGIC: Check for first launch
        if (storageService.isFirstLaunch) {
          print("🆕 First launch! Going to Onboarding");
          context.go(AppRoutes.onboarding);
        } else {
          print("🚀 Not first launch. Going to Login");
          context.go(AppRoutes.login);
        }
      }
    } catch (e) {
      print("❌ CRITICAL ERROR in Splash: $e");
      if (mounted) context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use your theme's background color
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        // 3. UI: Your custom Lottie animation
        child: Lottie.asset(
          'assets/animations/Welcome.json', //
          width: 250,
          height: 250,
          fit: BoxFit.contain,
          repeat: false,
        ),
      ),
    );
  }
}