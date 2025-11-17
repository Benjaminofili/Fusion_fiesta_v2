import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/services/auth_service.dart';

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
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await _authService.signIn(_emailController.text, _passwordController.text);
    if (!mounted) return;
    context.go(AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('FusionFiesta',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) =>
                          value?.isNotEmpty == true ? null : 'Required',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password'),
                      validator: (value) =>
                          value?.isNotEmpty == true ? null : 'Required',
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const CircularProgressIndicator()
                          : const Text('Continue'),
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

