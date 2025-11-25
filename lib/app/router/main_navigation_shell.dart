import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Optional if you use FA icons

import '../../app/di/service_locator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_roles.dart';
import '../../core/services/auth_service.dart';
import '../../features/admin/dashboard/presentation/screens/admin_dashboard_screen.dart';
import '../../features/common/event_catalog/presentation/screens/event_catalog_screen.dart';
import '../../features/common/gallery/presentation/screens/gallery_screen.dart';
import '../../features/common/profile/presentation/screens/profile_screen.dart';
import '../../features/organizer/dashboard/presentation/screens/organizer_dashboard_screen.dart';
import '../../features/student/dashboard/presentation/screens/student_dashboard_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  final AuthService _authService = serviceLocator<AuthService>();
  int _selectedIndex = 0;

  AppRole? _userRole;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final user = await _authService.currentUser;
    if (mounted) {
      setState(() {
        _userRole = user?.role ?? AppRole.visitor;
        _loading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    // 1. Define Tabs based on Role
    final tabs = _getTabsForRole(_userRole!);

    // 2. Define Pages based on Role
    final pages = _getPagesForRole(_userRole!);

    // Safety check: ensure index is valid if tabs changed
    if (_selectedIndex >= tabs.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primary.withOpacity(0.15),
          surfaceTintColor: Colors.white,
          destinations: tabs.map((tab) {
            return NavigationDestination(
              icon: Icon(tab.icon, color: AppColors.textSecondary),
              selectedIcon: Icon(tab.activeIcon, color: AppColors.primary),
              label: tab.label,
            );
          }).toList(),
        ),
      ),
    );
  }

  // --- HELPER: DEFINE TABS PER ROLE ---
  List<_NavTab> _getTabsForRole(AppRole role) {
    switch (role) {
      case AppRole.admin:
        return const [
          _NavTab(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Overview'),
          _NavTab(icon: Icons.people_outline, activeIcon: Icons.people, label: 'Users'),
          _NavTab(icon: Icons.analytics_outlined, activeIcon: Icons.analytics, label: 'Reports'),
          _NavTab(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
        ];

      case AppRole.organizer:
        return const [
          _NavTab(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Manage'),
          _NavTab(icon: Icons.event_outlined, activeIcon: Icons.event, label: 'My Events'),
          _NavTab(icon: Icons.qr_code_scanner, activeIcon: Icons.qr_code, label: 'Scan'),
          _NavTab(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
        ];

      case AppRole.student:
      // Participant gets the Full Dashboard
        return const [
          _NavTab(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
          _NavTab(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month, label: 'Events'),
          _NavTab(icon: Icons.photo_library_outlined, activeIcon: Icons.photo_library, label: 'Gallery'),
          _NavTab(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
        ];

      case AppRole.visitor:
      default:
      // Visitor gets limited tabs (No Dashboard)
        return const [
          _NavTab(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month, label: 'Events'), // Home is Catalog
          _NavTab(icon: Icons.photo_library_outlined, activeIcon: Icons.photo_library, label: 'Gallery'),
          _NavTab(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
        ];
    }
  }

  // --- HELPER: DEFINE SCREENS PER ROLE ---
  List<Widget> _getPagesForRole(AppRole role) {
    switch (role) {
      case AppRole.admin:
        return [
          const AdminDashboardScreen(),
          const Center(child: Text("User Management")),
          const Center(child: Text("Reports")),
          const ProfileScreen(),
        ];

      case AppRole.organizer:
        return [
          const OrganizerDashboardScreen(),
          const Center(child: Text("My Events")),
          const Center(child: Text("QR Scanner")),
          const ProfileScreen(),
        ];

      case AppRole.student:
        return [
          const StudentDashboardScreen(), // Full Dashboard
          const EventCatalogScreen(),
          GalleryScreen(),
          const ProfileScreen(),
        ];

      case AppRole.visitor:
      default:
        return [
          // Visitor Home is the Catalog
          const EventCatalogScreen(),
          GalleryScreen(),
          const ProfileScreen(),
        ];
    }
  }
}

class _NavTab {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}