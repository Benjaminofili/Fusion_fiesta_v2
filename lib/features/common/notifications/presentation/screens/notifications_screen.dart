import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/app_notification.dart';
import '../../../../../data/repositories/notification_repository.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  final NotificationRepository _repository = serviceLocator<NotificationRepository>();

  late TabController _tabController;
  List<AppNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final data = await _repository.fetchNotifications();
    if (mounted) {
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(String id) async {
    await _repository.markAsRead(id);
    _loadNotifications(); // Reload to update UI
  }

  Future<void> _markAllRead() async {
    await _repository.markAllAsRead();
    _loadNotifications();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All marked as read')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
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
            onPressed: _markAllRead,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(
        controller: _tabController,
        children: [
          _buildList(_notifications),
          _buildList(_notifications.where((n) => !n.isRead).toList()),
        ],
      ),
    );
  }

  Widget _buildList(List<AppNotification> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined, size: 60.sp, color: Colors.grey[300]),
            SizedBox(height: 16.h),
            Text('No notifications', style: TextStyle(color: Colors.grey[500], fontSize: 16.sp)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final item = items[index];
        return _NotificationCard(
          notification: item,
          onTap: () => _markAsRead(item.id),
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
          color: notification.isRead ? Colors.white : AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: notification.isRead
              ? Border.all(color: Colors.transparent)
              : Border.all(color: AppColors.primary.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                notification.isRead ? Icons.notifications_none : Icons.notifications_active,
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