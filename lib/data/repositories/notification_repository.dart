import '../models/app_notification.dart';

abstract class NotificationRepository {
  // Ensure this accepts 'userId'
  Stream<List<AppNotification>> getNotificationsStream(String userId);

  Future<void> markAsRead(String notificationId);

  // Ensure this accepts 'userId'
  Future<void> markAllAsRead(String userId);

  Future<int> getUnreadCount(String userId);
  Future<void> deleteNotification(String notificationId);
}
