import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_notification.dart';
import 'notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final SupabaseClient _supabase;

  NotificationRepositoryImpl(this._supabase);

  @override
  Stream<List<AppNotification>> getNotificationsStream(String userId) {
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data
        .map((json) => AppNotification.fromJson(json))
        .toList());
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      // Handle error silently or log it
      print('Error marking notification as read: $e');
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false); // Only update unread ones
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

  // You might need to add this method to your abstract class first if missing
  @override
  Future<int> getUnreadCount(String userId) async {
    final response = await _supabase
        .from('notifications')
        .count()
        .eq('user_id', userId)
        .eq('is_read', false);
    return response;
  }
}