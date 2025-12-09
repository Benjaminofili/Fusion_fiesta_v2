import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/event.dart';
import '../../../../../data/repositories/event_repository.dart';

class EventApprovalsScreen extends StatefulWidget {
  const EventApprovalsScreen({super.key});

  @override
  State<EventApprovalsScreen> createState() => _EventApprovalsScreenState();
}

class _EventApprovalsScreenState extends State<EventApprovalsScreen> {
  final _repo = serviceLocator<EventRepository>();

  Future<void> _updateStatus(Event event, EventStatus status) async {
    final updatedEvent = event.copyWith(approvalStatus: status);
    await _repo.updateEvent(updatedEvent);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Event marked as ${status.name.toUpperCase()}'),
          backgroundColor: status == EventStatus.approved ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Proposals')),
      body: StreamBuilder<List<Event>>(
        stream: _repo.getEventsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          // Filter only PENDING events
          final pendingEvents = snapshot.data!
              .where((e) => e.approvalStatus == EventStatus.pending)
              .toList();

          if (pendingEvents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[300]),
                  SizedBox(height: 16.h),
                  const Text('No pending approvals'),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: pendingEvents.length,
            separatorBuilder: (_,__) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final event = pendingEvents[index];
              return Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r), side: BorderSide(color: Colors.orange.withOpacity(0.3))),
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
                                Text('by ${event.organizer}', style: TextStyle(color: Colors.grey[600], fontSize: 12.sp)),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(4)),
                            child: Text('PENDING', style: TextStyle(color: Colors.orange, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(event.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _updateStatus(event, EventStatus.rejected),
                              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
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
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}