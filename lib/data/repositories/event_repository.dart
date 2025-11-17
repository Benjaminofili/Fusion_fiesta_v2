import '../models/event.dart';
import '../models/gallery_item.dart';

abstract class EventRepository {
  Future<List<Event>> fetchEvents();
  Future<Event> getEvent(String id);
  Future<List<GalleryItem>> fetchGallery();
}

