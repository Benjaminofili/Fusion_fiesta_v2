import '../models/event.dart';
import '../models/gallery_item.dart';

abstract class EventRepository {
  // OLD: Future<List<Event>> fetchEvents();

  // NEW: Real-time stream of events
  Stream<List<Event>> getEventsStream();

  Future<Event> getEvent(String id);
  Future<List<GalleryItem>> fetchGallery();
}
