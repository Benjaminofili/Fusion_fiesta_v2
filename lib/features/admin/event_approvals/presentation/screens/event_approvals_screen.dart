import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../data/models/event.dart';
import '../../../../../data/repositories/event_repository.dart';

class EventApprovalsScreen extends StatefulWidget {
  const EventApprovalsScreen({super.key});

  @override
  State<EventApprovalsScreen> createState() => _EventApprovalsScreenState();
}

class _EventApprovalsScreenState extends State<EventApprovalsScreen> with SingleTickerProviderStateMixin {
  final _repo = serviceLocator<EventRepository>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _updateStatus(Event event, EventStatus status) async {
    final updatedEvent = event.copyWith(approvalStatus: status);
    await _repo.updateEvent(updatedEvent);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Event ${status.name} successfully!'),
          backgroundColor: status == EventStatus.approved ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Management'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Pending Requests'),
            Tab(text: 'All Events'),
          ],
        ),
      ),
      body: StreamBuilder<List<Event>>(
        stream: _repo.getEventsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final allEvents = snapshot.data!;
          final pendingEvents = allEvents.where((e) => e.approvalStatus == EventStatus.pending).toList();
          // Sort 'All Events' by newest first
          final processedEvents = allEvents.reversed.toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildEventList(pendingEvents, isPending: true),
              _buildEventList(processedEvents, isPending: false),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEventList(List<Event> events, {required bool isPending}) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isPending ? Icons.check_circle_outline : Icons.history, size: 64, color: Colors.grey[300]),
            SizedBox(height: 16.h),
            Text(isPending ? 'No pending approvals' : 'No event history'),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: events.length,
      separatorBuilder: (_,__) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r), side: BorderSide(color: Colors.grey.withOpacity(0.2))),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),

                          // --- FIX: Fetch Name from ID ---
                          FutureBuilder<String>(
                            future: _repo.getOrganizerName(event.organizerId),
                            builder: (context, snapshot) {
                              final name = snapshot.data ?? 'Loading...';
                              return Text('by $name', style: TextStyle(color: Colors.grey[600], fontSize: 12.sp));
                            },
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(event.approvalStatus),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(event.description, maxLines: 2, overflow: TextOverflow.ellipsis),

                if (isPending) ...[
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _updateStatus(event, EventStatus.rejected),
                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                          child: const Text('Reject'),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => _updateStatus(event, EventStatus.approved),
                          style: FilledButton.styleFrom(backgroundColor: AppColors.success),
                          child: const Text('Approve'),
                        ),
                      ),
                    ],
                  )
                ] else ...[
                  SizedBox(height: 12.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text("View Details"),
                      onPressed: () => context.push('${AppRoutes.events}/details', extra: event),
                    ),
                  )
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(EventStatus status) {
    Color color;
    switch (status) {
      case EventStatus.approved: color = AppColors.success; break;
      case EventStatus.rejected: color = AppColors.error; break;
      case EventStatus.cancelled: color = Colors.grey; break;
      default: color = Colors.orange;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(status.name.toUpperCase(), style: TextStyle(color: color, fontSize: 10.sp, fontWeight: FontWeight.bold)),
    );
  }
}