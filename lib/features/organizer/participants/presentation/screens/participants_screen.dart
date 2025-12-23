import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/event.dart';
import '../../../../../data/models/registration.dart';
import '../../../../../data/repositories/event_repository.dart';

class ParticipantsScreen extends StatefulWidget {
  final Event event;

  const ParticipantsScreen({super.key, required this.event});

  @override
  State<ParticipantsScreen> createState() => _ParticipantsScreenState();
}

class _ParticipantsScreenState extends State<ParticipantsScreen> {
  final _repository = serviceLocator<EventRepository>();

  Future<void> _updateStatus(Registration reg, String status) async {
    // Capture everything BEFORE any await
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await _repository.updateRegistrationStatus(reg.id, status);

      // Only use context-dependent objects after checking mounted
      if (!mounted) return;

      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Participant marked as $status')),
      );
    } catch (e) {
      if (!mounted) return;

      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _messageParticipant(String userId) {
    // SRS Requirement: Communicate via internal messages
    // In a real app, navigating to: context.push('/chat/$userId');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening chat with Student $userId...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Participants',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            Text(widget.event.title,
                style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: StreamBuilder<List<Registration>>(
        stream: _repository.getEventRegistrationsStream(widget.event.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final registrations = snapshot.data!;

          if (registrations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 60.sp, color: Colors.grey[300]),
                  SizedBox(height: 16.h),
                  Text('No registrations yet',
                      style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: registrations.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final reg = registrations[index];
              return _ParticipantTile(
                registration: reg,
                onApprove: () => _updateStatus(reg, 'approved'),
                onReject: () => _updateStatus(reg, 'rejected'),
                onMessage: () =>
                    _messageParticipant(reg.userId), // NEW CALLBACK
              );
            },
          );
        },
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  final Registration registration;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onMessage; // NEW

  const _ParticipantTile({
    required this.registration,
    required this.onApprove,
    required this.onReject,
    required this.onMessage, // NEW
  });

  @override
  Widget build(BuildContext context) {
    final isPending = registration.status == 'pending';
    final isApproved = registration.status == 'approved';
    final isRejected = registration.status == 'rejected';
    final isAttended = registration.status == 'attended';

    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.access_time;

    if (isApproved) {
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle;
    } else if (isRejected) {
      statusColor = AppColors.error;
      statusIcon = Icons.cancel;
    } else if (isAttended) {
      statusColor = Colors.purple;
      statusIcon = Icons.qr_code_scanner;
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha:0.05),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha:0.1),
            child: const Icon(Icons.person, color: AppColors.primary),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student ID: ${registration.userId}',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                ),
                Text(
                  'Reg: ${DateFormat('MMM d, h:mm a').format(registration.createdAt)}',
                  style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                ),
              ],
            ),
          ),

          // --- 1. NEW: MESSAGE BUTTON ---
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.blue),
            onPressed: onMessage,
            tooltip: 'Message Student',
          ),

          // --- 2. APPROVAL ACTIONS ---
          if (isPending) ...[
            IconButton(
              icon: const Icon(Icons.check, color: AppColors.success),
              onPressed: onApprove,
              tooltip: 'Approve',
            ),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.error),
              onPressed: onReject,
              tooltip: 'Reject',
            ),
          ] else ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(statusIcon, size: 14.sp, color: statusColor),
                  SizedBox(width: 4.w),
                  Text(
                    registration.status.toUpperCase(),
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10.sp),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
