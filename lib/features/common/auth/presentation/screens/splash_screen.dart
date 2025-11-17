import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final user = await _authService.currentUser;
    if (!mounted) return;
    if (user == null) {
      context.go(AppRoutes.login);
      return;
    }
    if (user.role == AppRole.visitor && !user.profileCompleted) {
      context.go(AppRoutes.roleUpgrade);
      return;
    }
    context.go(AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

