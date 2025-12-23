import 'package:equatable/equatable.dart';

enum MediaType { image, video }

class GalleryItem extends Equatable {
  const GalleryItem({
    required this.id,
    required this.eventId,
    required this.mediaType,
    required this.url,
    required this.caption,
    required this.category,
    required this.uploadedBy,
    required this.uploadedAt,
    this.isFavorite = false,
    this.isHighlighted = false,
    this.filePath,
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
  final bool isHighlighted;
  final String? filePath;

  // ✅ ADDED: Factory to parse JSON from Supabase
  factory GalleryItem.fromJson(Map<String, dynamic> json) {
    return GalleryItem(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      // Parse string 'image'/'video' to Enum
      mediaType: MediaType.values.firstWhere(
        (e) => e.name == (json['media_type'] as String? ?? 'image'),
        orElse: () => MediaType.image,
      ),
      url: json['url'] as String,
      caption: json['caption'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      uploadedBy: json['uploaded_by'] as String? ?? '',
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
      // 'is_favorite' might come from a join or be false by default
      isFavorite: false,
      isHighlighted: json['is_highlighted'] as bool? ?? false,
      filePath: json['file_path'] as String?,
    );
  }

  // ✅ ADDED: Helper to convert to JSON for Database Inserts
  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'media_type': mediaType.name, // Stores 'image' or 'video'
      'url': url,
      'caption': caption,
      'category': category,
      'uploaded_by': uploadedBy,
      'uploaded_at': uploadedAt.toIso8601String(),
      if (filePath != null) 'file_path': filePath,
      'is_highlighted': isHighlighted,
    };
  }

  GalleryItem copyWith({
    bool? isFavorite,
    String? url, // Added to update URL after upload
    bool? isHighlighted,
  }) {
    return GalleryItem(
      id: id,
      eventId: eventId,
      mediaType: mediaType,
      url: url ?? this.url,
      caption: caption,
      category: category,
      uploadedBy: uploadedBy,
      uploadedAt: uploadedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      filePath: filePath,
    );
  }

  @override
  List<Object?> get props => [id, eventId, mediaType, url, isFavorite, caption];
}
