import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_roles.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../core/services/storage_service.dart';
import '../../../../../data/models/user.dart';

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

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notification Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SwitchListTile(value: true, onChanged: (v){}, title: const Text('Event Updates')),
            SwitchListTile(value: true, onChanged: (v){}, title: const Text('Reminders')),
            SwitchListTile(value: false, onChanged: (v){}, title: const Text('Promotional Alerts')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) return const Center(child: CircularProgressIndicator());

    final isStudent = _currentUser!.role == AppRole.student;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // --- USER HEADER ---
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
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
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    labelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // --- ACADEMIC DETAILS (Student Only) ---
            if (isStudent) ...[
              const _SectionHeader(title: 'Academic Details'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    _ProfileRow(icon: Icons.badge_outlined, label: 'Enrolment No', value: _currentUser?.enrolmentNumber ?? 'N/A'),
                    const Divider(height: 24),
                    _ProfileRow(icon: Icons.school_outlined, label: 'Department', value: _currentUser?.department ?? 'N/A'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],

            // --- SETTINGS & CONTENT ---
            const _SectionHeader(title: 'My Content & Settings'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  if (isStudent) ...[
                    _MenuTile(icon: FontAwesomeIcons.heart, title: 'Saved Events', onTap: () => context.push(AppRoutes.favorites)),
                    const Divider(height: 1, indent: 50),
                    _MenuTile(icon: FontAwesomeIcons.certificate, title: 'My Certificates', onTap: () => context.push(AppRoutes.certificates)),
                    const Divider(height: 1, indent: 50),
                    // Saved Media Link (Assuming route exists)
                    _MenuTile(icon: Icons.bookmark_border, title: 'Saved Media', onTap: () => context.push('${AppRoutes.gallery}/saved')),
                    const Divider(height: 1, indent: 50),
                  ],

                  // Notification Settings
                  _MenuTile(
                    icon: Icons.notifications_none,
                    title: 'Notification Preferences',
                    onTap: _showNotificationSettings,
                  ),
                  const Divider(height: 1, indent: 50),

                  _MenuTile(icon: Icons.lock_outline, title: 'Change Password', onTap: () {}),
                  const Divider(height: 1, indent: 50),
                  _MenuTile(icon: Icons.help_outline, title: 'Help & Support', onTap: () => context.push(AppRoutes.contact)),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // --- LOGOUT ---
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
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

            // Reset App
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
                  context.go(AppRoutes.splash);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// --- HELPER WIDGETS ---

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[600])),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _MenuTile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20, color: AppColors.textSecondary),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }
}