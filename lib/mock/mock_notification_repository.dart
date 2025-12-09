import 'dart:async';
import '../data/models/app_notification.dart';
import '../data/repositories/notification_repository.dart';

class MockNotificationRepository implements NotificationRepository {
  final _controller = StreamController<List<AppNotification>>.broadcast();

  // Remove 'final' so we can modify the list
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

  // --- NEW: Stream Implementation ---
  @override
  Stream<List<AppNotification>> getNotificationsStream() async* {
    yield List.from(_notifications); // Emit initial data
    yield* _controller.stream;       // Emit future updates
  }

  // Helper to push updates to the stream
  void _notifyListeners() {
    _controller.add(List.from(_notifications));
  }

  // Called by other parts of the app (e.g. Event Repository)
  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    _notifyListeners(); // <--- Update UI
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
      _notifyListeners(); // <--- Update UI
    }
  }

  @override
  Future<void> markAllAsRead() async {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _notifyListeners(); // <--- Update UI
  }
}