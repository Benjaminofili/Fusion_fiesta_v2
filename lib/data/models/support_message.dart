class SupportMessage {
  final String id;
  final String senderName;
  final String email;
  final String subject;
  final String message;
  final DateTime receivedAt;
  final bool isReplied;

  const SupportMessage({
    required this.id,
    required this.senderName,
    required this.email,
    required this.subject,
    required this.message,
    required this.receivedAt,
    this.isReplied = false,
  });

  SupportMessage copyWith({bool? isReplied}) {
    return SupportMessage(
      id: id,
      senderName: senderName,
      email: email,
      subject: subject,
      message: message,
      receivedAt: receivedAt,
      isReplied: isReplied ?? this.isReplied,
    );
  }
}