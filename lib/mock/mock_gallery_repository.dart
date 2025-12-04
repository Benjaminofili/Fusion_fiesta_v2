import 'dart:async';
import '../data/models/gallery_item.dart';
import '../data/repositories/gallery_repository.dart';

class MockGalleryRepository implements GalleryRepository {
  final _controller = StreamController<List<GalleryItem>>.broadcast();

  // Simulated Database
  final List<GalleryItem> _items = [
    GalleryItem(
      id: '1',
      eventId: 'event-0',
      mediaType: MediaType.image,
      url: 'https://picsum.photos/id/1018/400/600', // Vertical image
      caption: 'Hackathon Winners 2025',
      category: 'Technical',
      uploadedBy: 'organizer-1',
      uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    GalleryItem(
      id: '2',
      eventId: 'event-1',
      mediaType: MediaType.image,
      url: 'https://picsum.photos/id/1015/400/400', // Square image
      caption: 'Cultural Night Dance',
      category: 'Cultural',
      uploadedBy: 'organizer-2',
      uploadedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    GalleryItem(
      id: '3',
      eventId: 'event-2',
      mediaType: MediaType.video, // Video Type
      url: 'https://picsum.photos/id/1025/400/300',
      caption: 'Robotics Workshop Highlights',
      category: 'Technical',
      uploadedBy: 'organizer-1',
      uploadedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  @override
  Stream<List<GalleryItem>> getGalleryStream() async* {
    yield List.from(_items); // Emit initial data
    yield* _controller.stream; // Emit updates
  }

  @override
  Future<void> toggleFavorite(String itemId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));

    final index = _items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final current = _items[index];
      // Toggle local state
      _items[index] = current.copyWith(isFavorite: !current.isFavorite);
      // Push update to stream so UI refreshes automatically
      _controller.add(List.from(_items));
    }
  }

  @override
  Future<List<GalleryItem>> getSavedMedia() async {
    return _items.where((i) => i.isFavorite).toList();
  }

  @override
  Future<void> uploadMedia(GalleryItem item) async {
    await Future.delayed(const Duration(seconds: 1));
    _items.insert(0, item);
    _controller.add(List.from(_items));
  }

  @override
  Future<void> deleteMedia(String itemId) async {
    _items.removeWhere((i) => i.id == itemId);
    _controller.add(List.from(_items));
  }
}