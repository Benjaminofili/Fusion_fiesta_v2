enum AlertType { security, content, technical }
enum AlertSeverity { high, medium, low }

class SystemAlert {
  final String id;
  final String title;
  final String message;
  final AlertType type;
  final AlertSeverity severity;
  final DateTime timestamp;
  final bool isResolved;

  const SystemAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.severity,
    required this.timestamp,
    this.isResolved = false,
  });

  SystemAlert copyWith({bool? isResolved}) {
    return SystemAlert(
      id: id,
      title: title,
      message: message,
      type: type,
      severity: severity,
      timestamp: timestamp,
      isResolved: isResolved ?? this.isResolved,
    );
  }
}