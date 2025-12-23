import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../data/models/event.dart';
import '../../../../../data/repositories/event_repository.dart';

class OrganizerScanSelectorScreen extends StatefulWidget {
  const OrganizerScanSelectorScreen({super.key});

  @override
  State<OrganizerScanSelectorScreen> createState() =>
      _OrganizerScanSelectorScreenState();
}

class _OrganizerScanSelectorScreenState
    extends State<OrganizerScanSelectorScreen> {
  final _repo = serviceLocator<EventRepository>();
  final _auth = serviceLocator<AuthService>();
  String? _organizerName;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = _auth.currentUser;
    if (mounted) setState(() => _organizerName = user?.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(title: const Text('Select Event to Scan')),
      body: StreamBuilder<List<Event>>(
        stream: _repo.getEventsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filter: Active Events managed by this organizer
          final now = DateTime.now();
          final events = snapshot.data!.where((e) {
            final isMine =
                e.organizer == _organizerName || e.organizer == 'Tech Club';
            // Allow scanning for events starting soon or currently live (e.g., within 24h window)
            final isRelevant =
                e.endTime.isAfter(now.subtract(const Duration(hours: 1)));
            return isMine && isRelevant;
          }).toList();

          if (events.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'No active events found to scan.\nCreate an event or wait for start time.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: events.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                elevation: 0,
                color: Colors.white,
                child: ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha:0.1),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.qr_code_scanner,
                        color: AppColors.primary),
                  ),
                  title: Text(event.title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(event.location),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to the actual Scanner
                    context.push('${AppRoutes.events}/attendance',
                        extra: event);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
