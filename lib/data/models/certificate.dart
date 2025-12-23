import 'package:equatable/equatable.dart';

class Certificate extends Equatable {
  const Certificate({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.url,
    required this.issuedAt,
    this.fee = 0.0,
    this.isPaid = true,
  });

  final String id;
  final String userId;
  final String eventId;
  final String url;
  final DateTime issuedAt;
  final double fee;
  final bool isPaid;

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      eventId: json['event_id'] as String,
      // ✅ FIX: Matches your DB column 'url'
      url: json['url'] as String,
      // ✅ FIX: Matches your DB column 'issued_at'
      issuedAt: DateTime.parse(json['issued_at']),
      // ✅ FIX: Handles numeric type safely
      fee: (json['fee'] as num?)?.toDouble() ?? 0.0,
      isPaid: json['is_paid'] ?? true,
    );
  }

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
