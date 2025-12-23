import '../models/system_alert.dart';
import '../models/support_message.dart';
import '../models/gallery_item.dart';
import '../models/feedback_entry.dart';
import '../models/certificate.dart';

abstract class AdminRepository {
  // CHANGED: Future -> Stream
  Stream<List<SystemAlert>> getSystemAlertsStream();
  Future<void> resolveAlert(String id);

  Future<List<SupportMessage>> getSupportMessages();
  Future<void> replyToMessage(String id, String replyContent);

  // Gallery Moderation
  Future<List<GalleryItem>> getAllGalleryItems();
  Future<void> toggleGalleryHighlight(String id, bool isHighlighted);
  Future<void> deleteGalleryItem(String id);

  // Feedback Moderation
  Future<List<FeedbackEntry>> getFlaggedFeedback();
  Future<void> dismissFeedback(String id);
  Future<void> deleteFeedback(String id);

  // Certificate Oversight
  Future<List<Certificate>> getAllCertificates();
  Future<void> revokeCertificate(String id);
}
