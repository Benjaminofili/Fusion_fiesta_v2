import '../models/gallery_item.dart';

abstract class GalleryRepository {
  // Fetch all items (can be filtered by eventId or category internally)
  Stream<List<GalleryItem>> getGalleryStream();

  // Student Actions
  Future<void> toggleFavorite(String itemId);
  Future<List<GalleryItem>> getSavedMedia();

  // Organizer/Admin Actions
  Future<void> uploadMedia(GalleryItem item);
  Future<void> deleteMedia(String itemId);
}
