import 'dart:async';
import '../data/models/system_alert.dart';
import '../data/models/support_message.dart';
import '../data/repositories/admin_repository.dart';

class MockAdminRepository implements AdminRepository {
  // --- MOCK DATA ---
  final List<SystemAlert> _alerts = [
    SystemAlert(
      id: '1',
      title: 'Security Warning',
      message: 'Multiple failed login attempts detected from IP 192.168.1.1',
      type: AlertType.security,
      severity: AlertSeverity.high,
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    SystemAlert(
      id: '2',
      title: 'Content Flagged',
      message: 'User "Student-88" posted a comment flagged as "Spam".',
      type: AlertType.content,
      severity: AlertSeverity.medium,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    SystemAlert(
      id: '3',
      title: 'Server Latency',
      message: 'API response time exceeded 2000ms.',
      type: AlertType.technical,
      severity: AlertSeverity.low,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  final List<SupportMessage> _messages = [
    SupportMessage(
      id: 'm1',
      senderName: 'John Doe',
      email: 'john@student.edu',
      subject: 'App Crash on Login',
      message: 'Every time I try to login with Google, the app closes.',
      receivedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    SupportMessage(
      id: 'm2',
      senderName: 'Sarah Organizer',
      email: 'sarah@org.com',
      subject: 'Feature Request',
      message: 'Can we have a way to export attendance as CSV?',
      receivedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  final _alertController = StreamController<List<SystemAlert>>.broadcast();
  final _messageController = StreamController<List<SupportMessage>>.broadcast();

  @override
  Future<List<SystemAlert>> getSystemAlerts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _alerts.where((a) => !a.isResolved).toList();
  }

  @override
  Future<void> resolveAlert(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _alerts.indexWhere((a) => a.id == id);
    if (index != -1) {
      _alerts[index] = _alerts[index].copyWith(isResolved: true);
    }
  }

  @override
  Future<List<SupportMessage>> getSupportMessages() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _messages;
  }

  @override
  Future<void> replyToMessage(String id, String replyContent) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _messages.indexWhere((m) => m.id == id);
    if (index != -1) {
      _messages[index] = _messages[index].copyWith(isReplied: true);
    }
  }
}