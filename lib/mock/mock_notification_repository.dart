import 'dart:async';
import '../data/models/app_notification.dart';
import '../data/repositories/notification_repository.dart';

class MockNotificationRepository implements NotificationRepository {
  // Remove 'final' so we can add to it
  final List<AppNotification> _notifications = [
    AppNotification(
      id: '1',
      title: 'Registration Confirmed',
      message: 'You have successfully registered for TechViz 2025.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    AppNotification(
      id: '2',
      title: 'Certificate Available',
      message: 'Your certificate for the Cultural Fest is ready to download.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: false,
    ),
    AppNotification(
      id: '3',
      title: 'Event Rescheduled',
      message: 'The Football Finals have been moved to Friday due to rain.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
    ),
  ];

  // --- NEW: Method to inject new notifications from other parts of the app ---
  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
  }

  @override
  Future<List<AppNotification>> fetchNotifications() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _notifications;
  }

  @override
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }
}