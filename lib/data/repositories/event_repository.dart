import '../models/event.dart';
import '../models/gallery_item.dart';

abstract class EventRepository {
  // Real-time stream of events
  Stream<List<Event>> getEventsStream();

  Future<Event> getEvent(String id);
  Future<List<GalleryItem>> fetchGallery();

  // --- USER INTERACTION STREAMS ---
  Stream<List<String>> getRegisteredEventIdsStream(String userId);
  Stream<List<String>> getFavoriteEventIdsStream(String userId);

  // For counters (Simulated for now, can be real streams later)
  Future<int> getCertificateCount(String userId);
  Future<int> getFeedbackCount(String userId);

  // Actions
  Future<void> registerForEvent(String eventId, String userId);
  Future<void> cancelRegistration(String eventId, String userId);
  Future<void> toggleFavorite(String eventId, String userId); // Added this
}