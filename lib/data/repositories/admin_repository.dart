import '../models/system_alert.dart';
import '../models/support_message.dart';

abstract class AdminRepository {
  Future<List<SystemAlert>> getSystemAlerts();
  Future<void> resolveAlert(String id);

  Future<List<SupportMessage>> getSupportMessages();
  Future<void> replyToMessage(String id, String replyContent);
}