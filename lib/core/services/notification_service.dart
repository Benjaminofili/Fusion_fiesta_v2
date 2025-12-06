import 'dart:io'; // Import for Platform check
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../data/models/app_notification.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  final List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  // --- UPDATED INITIALIZATION ---
  Future<void> init() async {
    // 1. Setup Settings
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

    // 2. Initialize Plugin
    await _notificationsPlugin.initialize(settings);

    // 3. REQUEST PERMISSION (Crucial for Android 13+)
    if (Platform.isAndroid) {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
    }
  }

  // --- SHOW NOTIFICATION ---
  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    // A. Add to internal list
    final appNotif = AppNotification(
      id: Random().nextInt(10000).toString(),
      title: title,
      message: body,
      createdAt: DateTime.now(),
      isRead: false,
    );
    _notifications.insert(0, appNotif);

    // B. Trigger System Notification
    const androidDetails = AndroidNotificationDetails(
      'fusion_channel_id',
      'Fusion Events',
      channelDescription: 'Notifications for College Events',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());

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