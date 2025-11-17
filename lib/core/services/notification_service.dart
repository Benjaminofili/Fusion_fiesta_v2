import '../../data/models/app_notification.dart';

class NotificationService {
  final List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  void push(AppNotification notification) {
    _notifications.insert(0, notification);
  }

  void markAllRead() {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }
}

