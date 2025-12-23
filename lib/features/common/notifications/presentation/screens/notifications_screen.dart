import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../data/models/app_notification.dart';
import '../../../../../data/repositories/notification_repository.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  final NotificationRepository _repository =
      serviceLocator<NotificationRepository>();
  final AuthService _authService = serviceLocator<AuthService>();
  late TabController _tabController;

  // Track IDs hidden from UI but waiting for final deletion
  final Set<String> _pendingDeletions = {};

  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentUserId = _authService.currentUser?.id;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: AppColors.primary),
            tooltip: 'Mark all as read',
            onPressed: () {
              _repository.markAllAsRead(_currentUserId!);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All marked as read')),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Unread'),
          ],
        ),
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: _repository.getNotificationsStream(_currentUserId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          // Filter out items that are pending deletion so they disappear immediately
          final allNotifications = snapshot.data!
              .where((n) => !_pendingDeletions.contains(n.id))
              .toList();

          final unreadNotifications =
              allNotifications.where((n) => !n.isRead).toList();

          // Double check if list is empty after filtering
          if (allNotifications.isEmpty) {
            return _buildEmptyState();
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(allNotifications),
              _buildList(unreadNotifications),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 60.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text('No notifications',
              style: TextStyle(color: Colors.grey[500], fontSize: 16.sp)),
        ],
      ),
    );
  }

  Widget _buildList(List<AppNotification> items) {
    if (items.isEmpty) return _buildEmptyState();

    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final item = items[index];

        return Dismissible(
          key: Key(item.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20.w),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.delete_outline, color: Colors.white, size: 28.sp),
          ),
          onDismissed: (direction) {
            // 1. Optimistic Update: Hide it locally immediately
            setState(() {
              _pendingDeletions.add(item.id);
            });

            // 2. Show SnackBar with Undo
            ScaffoldMessenger.of(context)
                .showSnackBar(
                  SnackBar(
                    content: const Text('Notification deleted'),
                    duration: const Duration(seconds: 4),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        // 3. UNDO: Un-hide it locally
                        setState(() {
                          _pendingDeletions.remove(item.id);
                        });
                      },
                    ),
                  ),
                )
                .closed
                .then((reason) {
              // 4. COMMIT: If SnackBar closed and NOT by clicking Undo...
              if (reason != SnackBarClosedReason.action) {
                // ...actually delete from DB
                _repository.deleteNotification(item.id);

                // Cleanup local set (optional)
                if (mounted) {
                  _pendingDeletions.remove(item.id);
                }
              }
            });
          },
          child: _NotificationCard(
            notification: item,
            onTap: () => _repository.markAsRead(item.id),
          ),
        );
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final timeAgo = DateFormat('MMM d, h:mm a').format(notification.createdAt);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.white
              : AppColors.primary.withValues(alpha:0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: notification.isRead
              ? Border.all(color: Colors.transparent)
              : Border.all(color: AppColors.primary.withValues(alpha:0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: notification.isRead ? Colors.grey[100] : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                notification.isRead
                    ? Icons.notifications_none
                    : Icons.notifications_active,
                color: notification.isRead ? Colors.grey : AppColors.primary,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    timeAgo,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
