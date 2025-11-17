import 'package:equatable/equatable.dart';

class FeedbackEntry extends Equatable {
  const FeedbackEntry({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String eventId;
  final String userId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, eventId, userId, rating, comment, createdAt];
}

