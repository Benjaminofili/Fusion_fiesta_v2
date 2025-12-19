import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fusion_fiesta/data/repositories/notification_repository.dart';
import '../../data/models/app_notification.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  final Set<String> _notifiedIds = {};
  StreamSubscription? _subscription;
  final List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings);

    // MOVED: Permission request logic is extracted to a separate method
    // so it doesn't block the main() function during app startup.
  }

  // Call this method after the app has mounted or just fire-and-forget in main
  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
    }
  }

  void monitorNotifications(NotificationRepository repo, String userId) {
    _subscription?.cancel();

    _subscription = repo.getNotificationsStream(userId).listen((notifications) {
      for (final n in notifications) {
        // FIX: Convert both times to UTC to handle TimeZone differences correctly
        final nowUtc = DateTime.now().toUtc();
        final notificationUtc = n.createdAt.toUtc();

        // Use .abs() to handle slight clock skews
        final differenceInMinutes = nowUtc.difference(notificationUtc).inMinutes.abs();

        // Increased buffer to 10 minutes to be safe
        final isRecent = differenceInMinutes < 10;

        if (!n.isRead && !_notifiedIds.contains(n.id) && isRecent) {
          showNotification(
            title: n.title,
            body: n.message,
            userId: userId,
          );
          _notifiedIds.add(n.id);
        }
      }
    });
  }

  // Call this on logout
  void stopMonitoring() {
    _subscription?.cancel();
    _notifiedIds.clear();
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String userId = 'local_user',
  }) async {

    // 1. Add to internal list
    final appNotif = AppNotification(
      id: Random().nextInt(10000).toString(),
      userId: userId,
      title: title,
      message: body,
      createdAt: DateTime.now(),
      isRead: false,
    );
    _notifications.insert(0, appNotif);

    // 2. Trigger System Notification
    const androidDetails = AndroidNotificationDetails(
      'fusion_channel_id',
      'Fusion Events',
      channelDescription: 'Notifications for College Events',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      Random().nextInt(10000),
      title,
      body,
      details,
    );
  }

  void markAllRead() {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }
}