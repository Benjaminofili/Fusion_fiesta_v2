import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/stat_tile.dart';
import '../../../../../data/models/event.dart';
import '../../../../../data/models/user.dart';
import '../../../../../data/repositories/event_repository.dart';
import '../../../../../data/repositories/user_repository.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eventRepo = serviceLocator<EventRepository>();
    final userRepo = serviceLocator<UserRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Overview'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined, color: Colors.black),
            onPressed: () => context.push('/admin/alerts'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. STATISTICS CARDS ---
            Row(
              children: [
                // Pending Events Stream
                Expanded(
                  child: StreamBuilder<List<Event>>(
                    stream: eventRepo.getEventsStream(),
                    builder: (context, snapshot) {
                      final pendingCount = snapshot.data
                          ?.where((e) => e.approvalStatus == EventStatus.pending)
                          .length ?? 0;
                      return StatTile(
                        label: 'Pending Events',
                        value: pendingCount.toString().padLeft(2, '0'),
                        icon: Icons.pending_actions,
                        color: Colors.orange,
                      );
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                // Users Future (Simulated Stream)
                Expanded(
                  child: FutureBuilder<List<User>>(
                    future: userRepo.fetchUsers(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.length ?? 0;
                      return StatTile(
                        label: 'Active Users',
                        value: count.toString(),
                        icon: Icons.group,
                        color: AppColors.primary,
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.h),

            // --- 2. QUICK ACTIONS ---
            Text('Quick Actions', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),

            _AdminActionTile(
              title: 'Review Event Proposals',
              subtitle: 'Approve or reject organizer requests',
              icon: Icons.rate_review,
              color: Colors.blue,
              onTap: () => context.push('/admin/approvals'),
            ),
            SizedBox(height: 12.h),
            _AdminActionTile(
              title: 'Content Moderation',
              subtitle: 'Gallery, Feedback & Certificates',
              icon: Icons.shield,
              color: Colors.redAccent,
              onTap: () => context.push('/admin/moderation'),
            ),
            SizedBox(height: 12.h),
            _AdminActionTile(
              title: 'Support Inbox',
              subtitle: 'View user inquiries',
              icon: Icons.mail,
              color: Colors.teal,
              onTap: () => context.push('/admin/support'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AdminActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r), side: BorderSide(color: AppColors.border)),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.w),
        leading: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12.sp)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}