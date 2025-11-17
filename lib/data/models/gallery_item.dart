import 'package:equatable/equatable.dart';

class GalleryItem extends Equatable {
  const GalleryItem({
    required this.id,
    required this.eventId,
    required this.mediaType,
    required this.url,
    required this.favoriteCount,
  });

  final String id;
  final String eventId;
  final String mediaType;
  final String url;
  final int favoriteCount;

  @override
  List<Object?> get props => [id, eventId, mediaType, url, favoriteCount];
}

