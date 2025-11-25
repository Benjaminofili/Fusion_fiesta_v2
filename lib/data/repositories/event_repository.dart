import '../models/event.dart';
import '../models/gallery_item.dart';

abstract class EventRepository {
  // Real-time stream of events
  Stream<List<Event>> getEventsStream();

  Future<Event> getEvent(String id);
  Future<List<GalleryItem>> fetchGallery();

  // --- NEW METHODS ---
  Future<void> registerForEvent(String eventId, String userId);
  Future<void> cancelRegistration(String eventId, String userId);
  Future<List<String>> getRegisteredEventIds(String userId);
}