class Reminder {
  final String id; // e.g. messageId + type
  final String title;
  final String description;
  final DateTime dueDate;
  final String fromMessageId;

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.fromMessageId,
  });
}
