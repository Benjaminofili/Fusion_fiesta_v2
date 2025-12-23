import 'package:equatable/equatable.dart';

class Registration extends Equatable {
  const Registration({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String eventId;
  final String userId;
  final String status;
  final DateTime createdAt;

  Registration copyWith({
    String? status,
  }) {
    return Registration(
      id: id,
      eventId: eventId,
      userId: userId,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, eventId, userId, status, createdAt];
}
