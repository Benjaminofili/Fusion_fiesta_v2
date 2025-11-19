import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../core/services/storage_service.dart'; // Import StorageService

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
          const SizedBox(height: 16),
          const TextField(decoration: InputDecoration(labelText: 'Name')),
          const SizedBox(height: 16),
          const TextField(decoration: InputDecoration(labelText: 'Email')),
          const SizedBox(height: 16),
          const SwitchListTile(
              value: true,
              onChanged: null,
              title: Text('Push Notifications')
          ),

          const SizedBox(height: 32),

          // --- LOGOUT BUTTON (Standard) ---
          FilledButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () async {
              final authService = serviceLocator<AuthService>();
              await authService.signOut();
              if (context.mounted) context.go(AppRoutes.login);
            },
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // --- 🛠️ DEBUG / TEST BUTTON ---
          // Only visible during development if you want, or keep for testing
          TextButton.icon(
            icon: const Icon(Icons.restore),
            label: const Text('TEST: Simulate Fresh Install'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey, // Subtle color
            ),
            onPressed: () async {
              // 1. Clear EVERYTHING (User + Flags)
              final storage = serviceLocator<StorageService>();
              await storage.clearAll();

              // 2. Clear Memory Session
              final authService = serviceLocator<AuthService>();
              await authService.signOut();

              // 3. Show confirmation
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('App Reset! Restart the app to see Onboarding.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}