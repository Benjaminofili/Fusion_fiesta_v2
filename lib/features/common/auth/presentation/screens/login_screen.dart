import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart'; // Uses your defined colors
import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // Pre-filled for testing convenience (remove before launch)
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

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signIn(_emailController.text, _passwordController.text);
      if (!mounted) return;
      // Navigation is handled by the router redirect,
      // but we explicitly go to main just in case.
      context.go(AppRoutes.main);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login Failed: ${e.toString()}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w), // Responsive padding
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400.w), // Cap width for tablets
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- 1. LOGO & HEADER ---
                    SizedBox(height: 20.h),
                    Hero(
                      tag: 'app_logo',
                      child: SizedBox(
                        height: 160.h,
                        child: Image.asset(
                          'assets/images/logo.webp', // Ensure you have this file
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>  Icon(
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

                    // --- 2. EMAIL FIELD ---
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your college email',
                        prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondary),
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
                      ),
                      validator: (value) => value?.contains('@') == true ? null : 'Please enter a valid email',
                    ),
                     SizedBox(height: 20.h),

                    // --- 3. PASSWORD FIELD ---
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),
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
                      ),
                      validator: (value) => (value?.length ?? 0) > 5 ? null : 'Password must be at least 6 characters',
                    ),

                    // --- 4. FORGOT PASSWORD LINK ---
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          context.push(AppRoutes.forgotPassword);
                        },
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

                    // --- 5. LOGIN BUTTON ---
                    SizedBox(
                      height: 56.h,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _login,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ?  CircularProgressIndicator(color: Colors.white)
                            :  Text(
                          'Sign In',
                          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                     SizedBox(height: 24.h),

                    // --- 6. REGISTER LINK ---
                    // Replace the entire Row(...) at the bottom with this:
                    Center(
                      child: GestureDetector(
                        onTap: () => context.push(AppRoutes.register),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 14.sp, // Responsive font
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
}