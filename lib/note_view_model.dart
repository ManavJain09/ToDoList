
class Task {
  String id;
  String title;
  String description;
  DateTime dueDate;
  int priority; // 1 = High, 2 = Medium, 3 = Low
  bool isCompleted;
  bool hasReminder; // New field
  DateTime? reminderDate; // New field

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
    this.hasReminder = false, // Default to false
    this.reminderDate, // Nullable
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      priority: json['priority'],
      isCompleted: json['isCompleted'] ?? false,
      hasReminder: json['hasReminder'] ?? false,
      reminderDate: json['reminderDate'] != null ? DateTime.parse(json['reminderDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority,
      'isCompleted': isCompleted,
      'hasReminder': hasReminder,
      'reminderDate': reminderDate?.toIso8601String(),
    };
  }
}