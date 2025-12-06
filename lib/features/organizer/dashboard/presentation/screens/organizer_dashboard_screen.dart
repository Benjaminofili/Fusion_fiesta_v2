import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../data/models/event.dart';
import '../../../../../data/models/user.dart';
import '../../../../../data/repositories/event_repository.dart';
import '../../../../../core/widgets/stat_tile.dart'; // Ensure you have this widget or use the inline one below

class OrganizerDashboardScreen extends StatefulWidget {
  const OrganizerDashboardScreen({super.key});

  @override
  State<OrganizerDashboardScreen> createState() => _OrganizerDashboardScreenState();
}

class _OrganizerDashboardScreenState extends State<OrganizerDashboardScreen> {
  final EventRepository _eventRepository = serviceLocator<EventRepository>();
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
    if (_currentUser == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: const Icon(Icons.person, color: AppColors.primary),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Organizer Panel', style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                Text(_currentUser!.name, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.sp)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // We will build this screen next!
          context.push('${AppRoutes.events}/create');
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Create Event'),
      ),
      body: StreamBuilder<List<Event>>(
        stream: _eventRepository.getEventsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          // 1. FILTER: Get events created by THIS organizer (Mock logic: matching name or ID)
          // In a real app, you'd filter by organizerId. For mock, we assume 'Tech Club' or current user name.
          final myEvents = snapshot.data!.where((e) {
            // Flexible matching for the mock
            return e.organizer == _currentUser!.name || e.organizer == 'Tech Club';
          }).toList();

          // 2. CALCULATE STATS
          int totalRegistrations = 0;
          for (var e in myEvents) {
            totalRegistrations += e.registeredCount;
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- STATS GRID ---
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Total Events',
                        value: myEvents.length.toString(),
                        icon: Icons.event,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _StatCard(
                        label: 'Registrations',
                        value: totalRegistrations.toString(),
                        icon: Icons.people_outline,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // --- QUICK ACTIONS ---
                Text('Quick Actions', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    _ActionButton(
                      icon: Icons.qr_code_scanner,
                      label: 'Scan QR',
                      onTap: () {
                        // We will build this screen later
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('QR Scanner coming soon')));
                      },
                    ),
                    SizedBox(width: 12.w),
                    _ActionButton(
                      icon: Icons.photo_library_outlined,
                      label: 'Upload Media',
                      onTap: () => context.push('${AppRoutes.gallery}/upload'),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),

                // --- MY EVENTS LIST ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('My Events', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    TextButton(onPressed: () {}, child: const Text('View All')),
                  ],
                ),

                if (myEvents.isEmpty)
                  Container(
                    padding: EdgeInsets.all(32.h),
                    alignment: Alignment.center,
                    child: const Text('No events created yet.\nTap "+ Create Event" to start.'),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: myEvents.length,
                    itemBuilder: (context, index) {
                      final event = myEvents[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        color: Colors.white,
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          leading: Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.event_note, color: AppColors.primary),
                          ),
                          title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            '${event.registeredCount} Registered • ${event.location}',
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () {
                              // NEW: Navigate to Edit
                              context.push('${AppRoutes.events}/edit', extra: event);
                            },
                          ),
                        ),
                      );
                    },
                  ),

                SizedBox(height: 80.h),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(height: 12.h),
          Text(value, style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary),
              SizedBox(height: 8.h),
              Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp)),
            ],
          ),
        ),
      ),
    );
  }
}