import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../data/models/event.dart';
import '../../../../../data/repositories/event_repository.dart';

class OrganizerEventsScreen extends StatefulWidget {
  const OrganizerEventsScreen({super.key});

  @override
  State<OrganizerEventsScreen> createState() => _OrganizerEventsScreenState();
}

class _OrganizerEventsScreenState extends State<OrganizerEventsScreen>
    with SingleTickerProviderStateMixin {
  final _repo = serviceLocator<EventRepository>();
  final _auth = serviceLocator<AuthService>();

  late TabController _tabController;

  // Cache the ID here to avoid looking it up in the build loop repeatedly
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUser();
  }

  Future<void> _loadUser() async {
    // Safely fetch user ID
    final user = _auth.currentUser;
    if (mounted && user != null) {
      setState(() => _currentUserId = user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('My Events',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Upcoming & Live'),
            Tab(text: 'History'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'events_tab_create',
        onPressed: () => context.push('${AppRoutes.events}/create'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
      body: _currentUserId == null
          ? const Center(child: CircularProgressIndicator()) // Wait for user ID
          : StreamBuilder<List<Event>>(
              stream: _repo.getEventsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // FILTER LOGIC
                final allEvents = snapshot.data!.where((e) {
                  return e.organizerId == _currentUserId ||
                      e.coOrganizers.contains(_currentUserId);
                }).toList();

                final now = DateTime.now();
                final active =
                    allEvents.where((e) => e.endTime.isAfter(now)).toList();
                final history =
                    allEvents.where((e) => e.endTime.isBefore(now)).toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _EventList(events: active, isHistory: false),
                    _EventList(events: history, isHistory: true),
                  ],
                );
              },
            ),
    );
  }
}

class _EventList extends StatelessWidget {
  final List<Event> events;
  final bool isHistory;

  const _EventList({required this.events, required this.isHistory});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isHistory ? Icons.history : Icons.event_busy,
                size: 64, color: Colors.grey[300]),
            SizedBox(height: 16.h),
            Text(isHistory ? 'No past events' : 'No active events',
                style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: events.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final event = events[index];

        Color statusColor;
        String statusText;

        switch (event.approvalStatus) {
          case EventStatus.approved:
            statusColor = AppColors.success;
            statusText = "LIVE";
            break;
          case EventStatus.rejected:
            statusColor = AppColors.error;
            statusText = "REJECTED";
            break;
          case EventStatus.cancelled:
            statusColor = Colors.grey;
            statusText = "CANCELLED";
            break;
          default:
            statusColor = Colors.orange;
            statusText = "PENDING";
        }

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
              side: BorderSide(color: AppColors.border)),
          child: ListTile(
            contentPadding: EdgeInsets.all(16.w),
            title: Row(
              children: [
                Expanded(
                    child: Text(event.title,
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                if (!isHistory)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                        color: statusColor.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(4.r),
                        border:
                            Border.all(color: statusColor.withValues(alpha:0.2))),
                    child: Text(statusText,
                        style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: statusColor)),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4.h),
                Text(DateFormat('MMM d, h:mm a').format(event.startTime)),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.people, size: 14.sp, color: Colors.grey),
                    SizedBox(width: 4.w),
                    Text('${event.registeredCount} Registered'),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  context.push('${AppRoutes.events}/edit', extra: event),
            ),
            onTap: () =>
                context.push('${AppRoutes.events}/details', extra: event),
          ),
        );
      },
    );
  }
}
