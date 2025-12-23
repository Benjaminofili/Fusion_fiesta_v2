import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../core/services/connectivity_service.dart';
import '../../../../../core/widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController =
      TextEditingController(text: 'student@fusionfiesta.dev');
  final _passwordController = TextEditingController(text: 'password');

  final AuthService _authService = serviceLocator<AuthService>();
  final ConnectivityService _connectivityService =
      serviceLocator<ConnectivityService>();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    // 1. Pre-Check Internet
    if (!await _connectivityService.isConnected) {
      _showErrorSnackBar(
          'No internet connection. Please check your WiFi or Data.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.signIn(
          _emailController.text.trim(), _passwordController.text);
      if (!mounted) return;
      context.go(AppRoutes.main);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginAsGuest() async {
    setState(() => _isLoading = true);
    try {
      await _authService.loginAsGuest();
      if (!mounted) return;
      context.go(AppRoutes.main);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(Object error) {
    String message = error.toString();
    if (message.contains('AppFailure')) {
      message = message.replaceAll('AppFailure(', '').replaceAll(')', '');
    } else {
      message = message.replaceAll('Exception:', '').trim();
    }

    final isUserNotFound = message.toLowerCase().contains('register') ||
        message.toLowerCase().contains('not found');

    final isNetworkError = message.toLowerCase().contains('internet') ||
        message.toLowerCase().contains('connect') ||
        message.toLowerCase().contains('time out');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isNetworkError ? Icons.wifi_off : Icons.error_outline,
                color: Colors.white),
            SizedBox(width: 12.w),
            Expanded(
                child: Text(message,
                    style: TextStyle(
                        fontSize: 13.sp, fontWeight: FontWeight.w500))),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        action: isUserNotFound
            ? SnackBarAction(
                label: 'Register',
                textColor: Colors.white,
                backgroundColor: Colors.white.withValues(alpha:0.2),
                onPressed: () => context.push(AppRoutes.register),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400.w),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 20.h),
                    Hero(
                      tag: 'app_logo',
                      child: SizedBox(
                        height: 160.h,
                        child: Image.asset(
                          'assets/images/logo.webp',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            FontAwesomeIcons.graduationCap,
                            size: 80.sp,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),
                    Text(
                      'Welcome Back!',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Sign in to access your dashboard',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                    SizedBox(height: 48.h),

                    // --- EMAIL ---
                    AppTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Enter your college email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value?.contains('@') == true
                          ? null
                          : 'Please enter a valid email',
                    ),
                    SizedBox(height: 20.h),

                    // --- PASSWORD ---
                    AppTextField(
                      controller: _passwordController,
                      label: 'Password',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      validator: (value) =>
                          (value?.length ?? 0) > 5 ? null : 'Min 6 characters',
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push(AppRoutes.forgotPassword),
                        child: const Text('Forgot Password?',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // --- BUTTONS ---
                    SizedBox(
                      height: 56.h,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _login,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text('Sign In',
                                style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    SizedBox(
                      height: 56.h,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _loginAsGuest,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('Continue as Guest',
                            style: TextStyle(
                                fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    Center(
                      child: GestureDetector(
                        onTap: () => context.push(AppRoutes.register),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 14.sp),
                            children: [
                              const TextSpan(text: "Don't have an account? "),
                              TextSpan(
                                  text: 'Register',
                                  style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
