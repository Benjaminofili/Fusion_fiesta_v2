import 'package:flutter/material.dart';

import '../../app/di/service_locator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_roles.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/storage_service.dart';
import '../../data/models/user.dart';

// Screens
import '../../features/admin/dashboard/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/reports/presentation/screens/reports_screen.dart';
import '../../features/admin/users/presentation/screens/user_management_screen.dart';
import '../../features/common/event_catalog/presentation/screens/event_catalog_screen.dart';
import '../../features/common/gallery/presentation/screens/gallery_screen.dart';
import '../../features/common/profile/presentation/screens/profile_screen.dart';
import '../../features/organizer/dashboard/presentation/screens/organizer_dashboard_screen.dart';
import '../../features/student/dashboard/presentation/screens/student_dashboard_screen.dart';
import '../../features/organizer/events/presentation/screens/organizer_events_screen.dart';
import '../../features/organizer/attendance/presentation/screens/organizer_scan_selector_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  final AuthService _authService = serviceLocator<AuthService>();
  final StorageService _storageService = serviceLocator<StorageService>();

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final initialUser = _storageService.getUser();

    return StreamBuilder<User?>(
      stream: _authService.userStream,
      initialData: initialUser,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final role = user?.role ?? AppRole.visitor;

        final tabs = _getTabsForRole(role);
        final pages = _getPagesForRole(role);

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
                  // FIXED: Replaced .withOpacity with .withValues
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              backgroundColor: Colors.white,
              // FIXED: Replaced .withOpacity with .withValues
              indicatorColor: AppColors.primary.withValues(alpha: 0.15),
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
      },
    );
  }

  List<_NavTab> _getTabsForRole(AppRole role) {
    switch (role) {
      case AppRole.admin:
        return const [
          _NavTab(
              icon: Icons.dashboard_outlined,
              activeIcon: Icons.dashboard,
              label: 'Overview'),
          _NavTab(
              icon: Icons.people_outline,
              activeIcon: Icons.people,
              label: 'Users'),
          _NavTab(
              icon: Icons.analytics_outlined,
              activeIcon: Icons.analytics,
              label: 'Reports'),
          _NavTab(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profile'),
        ];
      case AppRole.organizer:
        return const [
          _NavTab(
              icon: Icons.dashboard_outlined,
              activeIcon: Icons.dashboard,
              label: 'Manage'),
          _NavTab(
              icon: Icons.event_outlined,
              activeIcon: Icons.event,
              label: 'My Events'),
          _NavTab(
              icon: Icons.qr_code_scanner,
              activeIcon: Icons.qr_code,
              label: 'Scan'),
          _NavTab(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profile'),
        ];
      case AppRole.student:
        return const [
          _NavTab(
              icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
          _NavTab(
              icon: Icons.calendar_month_outlined,
              activeIcon: Icons.calendar_month,
              label: 'Events'),
          _NavTab(
              icon: Icons.photo_library_outlined,
              activeIcon: Icons.photo_library,
              label: 'Gallery'),
          _NavTab(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profile'),
        ];
    // FIXED: Removed 'default:' because 'visitor' covers the last remaining enum case
      case AppRole.visitor:
        return const [
          _NavTab(
              icon: Icons.calendar_month_outlined,
              activeIcon: Icons.calendar_month,
              label: 'Events'),
          _NavTab(
              icon: Icons.photo_library_outlined,
              activeIcon: Icons.photo_library,
              label: 'Gallery'),
          _NavTab(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profile'),
        ];
    }
  }

  List<Widget> _getPagesForRole(AppRole role) {
    switch (role) {
      case AppRole.admin:
        return [
          const AdminDashboardScreen(),
          const UserManagementScreen(),
          const ReportsScreen(),
          const ProfileScreen(),
        ];
      case AppRole.organizer:
        return [
          const OrganizerDashboardScreen(),
          const OrganizerEventsScreen(),
          const OrganizerScanSelectorScreen(),
          const ProfileScreen(),
        ];
      case AppRole.student:
        return [
          const StudentDashboardScreen(),
          const EventCatalogScreen(),
          GalleryScreen(),
          const ProfileScreen(),
        ];
    // FIXED: Removed 'default:'
      case AppRole.visitor:
        return [
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

  const _NavTab(
      {required this.icon, required this.activeIcon, required this.label});
}