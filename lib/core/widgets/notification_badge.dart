import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app/di/service_locator.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/models/app_notification.dart';
import '../constants/app_colors.dart';
import '../services/auth_service.dart';

class NotificationBadge extends StatelessWidget {
  final Widget child;

  const NotificationBadge({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final authService = serviceLocator<AuthService>();
    final userId = authService.currentUser?.id;

    // If no user is logged in, just show the icon without badge
    if (userId == null) return child;

    return StreamBuilder<List<AppNotification>>(
      stream: serviceLocator<NotificationRepository>().getNotificationsStream(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return child;

        // Count unread messages
        final unreadCount = snapshot.data!.where((n) => !n.isRead).length;

        if (unreadCount == 0) return child;

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            child,
            Positioned(
              top: -5,
              right: -5,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: BoxConstraints(
                  minWidth: 16.w,
                  minHeight: 16.w,
                ),
                child: Center(
                  child: Text(
                    unreadCount > 9 ? '9+' : unreadCount.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}