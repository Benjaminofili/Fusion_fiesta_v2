import 'package:equatable/equatable.dart';

class Certificate extends Equatable {
  const Certificate({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.url,
    required this.issuedAt,
    this.fee = 0.0,      // NEW: Cost of certificate
    this.isPaid = true,  // NEW: Payment status (default true for free ones)
  });

  final String id;
  final String userId;
  final String eventId;
  final String url;
  final DateTime issuedAt;
  final double fee;
  final bool isPaid;

  // Add copyWith to handle status updates
  Certificate copyWith({bool? isPaid}) {
    return Certificate(
      id: id,
      userId: userId,
      eventId: eventId,
      url: url,
      issuedAt: issuedAt,
      fee: fee,
      isPaid: isPaid ?? this.isPaid,
    );
  }

  @override
  List<Object?> get props => [id, userId, eventId, url, issuedAt, fee, isPaid];
}