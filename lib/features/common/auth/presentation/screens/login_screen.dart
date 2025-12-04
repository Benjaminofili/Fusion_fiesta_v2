import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // Pre-filled for testing convenience
  final _emailController = TextEditingController(text: 'student@fusionfiesta.dev');
  final _passwordController = TextEditingController(text: 'password');

  final AuthService _authService = serviceLocator<AuthService>();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- UPDATED LOGIN METHOD ---
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signIn(_emailController.text.trim(), _passwordController.text);
      if (!mounted) return;
      context.go(AppRoutes.main);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- UPDATED GUEST LOGIN ---
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

  // --- NEW: REUSABLE ERROR HANDLER ---
  void _showErrorSnackBar(Object error) {
    // 1. Clean the error message
    String message = error.toString();

    // Remove technical wrappers like "AppFailure(...)" or "Exception:"
    if (message.contains('AppFailure')) {
      message = message.replaceAll('AppFailure(', '').replaceAll(')', '');
    } else {
      message = message.replaceAll('Exception:', '').trim();
    }

    // 2. Determine if we need a "Register" action button
    final isUserNotFound = message.toLowerCase().contains('register') ||
        message.toLowerCase().contains('not found');

    // 3. Show Improved SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating, // Floats nicely above bottom
        elevation: 4,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        action: isUserNotFound
            ? SnackBarAction(
          label: 'Register',
          textColor: Colors.white,
          backgroundColor: Colors.white.withOpacity(0.2),
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
                    // --- LOGO & HEADER ---
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
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Sign in to access your dashboard',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 48.h),

                    // --- EMAIL FIELD ---
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _inputDecoration('Email', Icons.email_outlined),
                      validator: (value) => value?.contains('@') == true ? null : 'Please enter a valid email',
                    ),
                    SizedBox(height: 20.h),

                    // --- PASSWORD FIELD ---
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _inputDecoration('Password', Icons.lock_outline).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),
                      ),
                      validator: (value) => (value?.length ?? 0) > 5 ? null : 'Min 6 characters',
                    ),

                    // --- FORGOT PASSWORD ---
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push(AppRoutes.forgotPassword),
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // --- SIGN IN BUTTON ---
                    SizedBox(
                      height: 56.h,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _login,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                          'Sign In',
                          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // --- GUEST LOGIN BUTTON ---
                    SizedBox(
                      height: 56.h,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _loginAsGuest,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          'Continue as Guest',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // --- REGISTER LINK ---
                    Center(
                      child: GestureDetector(
                        onTap: () => context.push(AppRoutes.register),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 14.sp,
                            ),
                            children: [
                              const TextSpan(text: "Don't have an account? "),
                              TextSpan(
                                text: 'Register',
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
      hintText: label == 'Email' ? 'Enter your college email' : null,
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
      filled: true,
      fillColor: Colors.white,
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
}