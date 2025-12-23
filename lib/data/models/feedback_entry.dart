import 'package:equatable/equatable.dart';

class FeedbackEntry extends Equatable {
  const FeedbackEntry({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.ratingOverall,
    required this.ratingOrganization,
    required this.ratingRelevance,
    required this.comment,
    required this.createdAt,
    this.isFlagged = false,
    this.flagReason,
  });

  final String id;
  final String eventId;
  final String userId;

  // Detailed Ratings (Double to allow half-stars)
  final double ratingOverall;
  final double ratingOrganization;
  final double ratingRelevance;

  final String comment;
  final DateTime createdAt;
  final bool isFlagged;
  final String? flagReason;

  @override
  List<Object?> get props => [
        id,
        eventId,
        userId,
        ratingOverall,
        ratingOrganization,
        ratingRelevance,
        comment,
        createdAt,
        isFlagged,
        flagReason,
      ];

  // Optional: Add Serialization helpers for future Backend/Hive usage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'ratingOverall': ratingOverall,
      'ratingOrganization': ratingOrganization,
      'ratingRelevance': ratingRelevance,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'isFlagged': isFlagged,
      'flagReason': flagReason,
    };
  }

  factory FeedbackEntry.fromMap(Map<String, dynamic> map) {
    return FeedbackEntry(
      id: map['id'] as String,
      eventId: map['eventId'] as String,
      userId: map['userId'] as String,
      ratingOverall: (map['ratingOverall'] as num).toDouble(),
      ratingOrganization: (map['ratingOrganization'] as num).toDouble(),
      ratingRelevance: (map['ratingRelevance'] as num).toDouble(),
      comment: map['comment'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      isFlagged: map['isFlagged'] as bool? ?? false,
      flagReason: map['flagReason'] as String?,
    );
  }

  /// Factory to parse Supabase rows (snake_case)
  factory FeedbackEntry.fromJson(Map<String, dynamic> json) {
    return FeedbackEntry(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      userId: json['user_id'] as String,
      ratingOverall: (json['rating_overall'] as num).toDouble(),
      ratingOrganization: (json['rating_organization'] as num? ??
              json['ratingOrganization'] as num? ??
              0)
          .toDouble(),
      ratingRelevance: (json['rating_relevance'] as num? ??
              json['ratingRelevance'] as num? ??
              0)
          .toDouble(),
      comment: json['comment'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      isFlagged:
          json['is_flagged'] as bool? ?? json['isFlagged'] as bool? ?? false,
      flagReason:
          json['flag_reason'] as String? ?? json['flagReason'] as String?,
    );
  }
}
