import '../models/app_notification.dart';

abstract class NotificationRepository {
  Stream<List<AppNotification>> getNotificationsStream();
  Future<List<AppNotification>> fetchNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}