import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../core/services/storage_service.dart';
import '../../../../../data/models/user.dart'; // For displaying user data

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = serviceLocator<AuthService>();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.currentUser;
    if (mounted) setState(() => _currentUser = user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // --- USER HEADER ---
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: _currentUser?.profilePictureUrl != null
                      ? NetworkImage(_currentUser!.profilePictureUrl!)
                      : null,
                  child: _currentUser?.profilePictureUrl == null
                      ? const Icon(Icons.person, size: 50, color: AppColors.primary)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  _currentUser?.name ?? 'Guest User',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  _currentUser?.email ?? 'No email',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Chip(
                  label: Text(_currentUser?.role.name.toUpperCase() ?? 'UNKNOWN'),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  labelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          const Divider(),

          // --- STANDARD ACTIONS ---
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('App Settings'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {}, // TODO: Navigate to settings
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.push(AppRoutes.contact),
          ),

          const SizedBox(height: 24),

          // --- LOGOUT ---
          FilledButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red[50],
              foregroundColor: Colors.red,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () async {
              await _authService.signOut();
              if (context.mounted) context.go(AppRoutes.login);
            },
          ),

          const SizedBox(height: 40),
          const Divider(),

          // --- 🛠️ DEVELOPER / TESTING ZONE ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'DEVELOPER ACTIONS (TESTING ONLY)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[400],
                letterSpacing: 1.5,
              ),
            ),
          ),

          // 1. RESET APP (Fresh Install Simulation)
          ListTile(
            tileColor: Colors.grey[100],
            leading: const Icon(Icons.delete_forever, color: Colors.orange),
            title: const Text('Reset App State'),
            subtitle: const Text('Clears all storage & flags'),
            onTap: () async {
              final storage = serviceLocator<StorageService>();
              await storage.clearAll();
              await _authService.signOut();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('App Reset. Restarting...')),
                );
                // Force navigation to Splash/Onboarding
                context.go(AppRoutes.splash);
              }
            },
          ),
        ],
      ),
    );
  }
}