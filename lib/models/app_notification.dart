class AppNotificationMessage {
  final String id;
  final String message;
  final DateTime timestamp;
  final bool delivered;
  final bool read;

  const AppNotificationMessage({
    required this.id,
    required this.message,
    required this.timestamp,
    this.delivered = true,
    this.read = true,
  });
}
