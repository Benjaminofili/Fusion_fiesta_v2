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
    );
  }
}