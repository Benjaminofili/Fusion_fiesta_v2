import 'package:equatable/equatable.dart';

enum MediaType { image, video }

class GalleryItem extends Equatable {
  const GalleryItem({
    required this.id,
    required this.eventId,
    required this.mediaType, // 'image' or 'video'
    required this.url,
    required this.caption,
    required this.category, // e.g., 'Cultural', 'Technical'
    required this.uploadedBy, // Organizer ID
    required this.uploadedAt,
    this.isFavorite = false, // Local state for UI
  });

  final String id;
  final String eventId;
  final MediaType mediaType;
  final String url;
  final String caption;
  final String category;
  final String uploadedBy;
  final DateTime uploadedAt;
  final bool isFavorite;

  GalleryItem copyWith({
    bool? isFavorite,
  }) {
    return GalleryItem(
      id: id,
      eventId: eventId,
      mediaType: mediaType,
      url: url,
      caption: caption,
      category: category,
      uploadedBy: uploadedBy,
      uploadedAt: uploadedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [id, eventId, mediaType, url, isFavorite, caption];
}