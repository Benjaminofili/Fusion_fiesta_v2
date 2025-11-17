import 'package:equatable/equatable.dart';

class Certificate extends Equatable {
  const Certificate({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.url,
    required this.issuedAt,
  });

  final String id;
  final String userId;
  final String eventId;
  final String url;
  final DateTime issuedAt;

  @override
  List<Object?> get props => [id, userId, eventId, url, issuedAt];
}

