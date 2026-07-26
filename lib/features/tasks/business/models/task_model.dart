enum TaskPriority {
  low,
  medium,
  high,
}

enum RecurrenceType {
  none,
  daily,
  weekly,
  monthly,
}

class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime dueDate;
  final DateTime? startTime;
  final TaskPriority priority;
  final String categoryId;
  final bool has30MinReminder;
  final bool hasStartReminder;
  final RecurrenceType recurrence;

  const Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.dueDate,
    this.startTime,
    this.priority = TaskPriority.medium,
    this.categoryId = 'general',
    this.has30MinReminder = true,
    this.hasStartReminder = true,
    this.recurrence = RecurrenceType.none,
  });

  Task copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? dueDate,
    DateTime? startTime,
    TaskPriority? priority,
    String? categoryId,
    bool? has30MinReminder,
    bool? hasStartReminder,
    RecurrenceType? recurrence,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      startTime: startTime ?? this.startTime,
      priority: priority ?? this.priority,
      categoryId: categoryId ?? this.categoryId,
      has30MinReminder: has30MinReminder ?? this.has30MinReminder,
      hasStartReminder: hasStartReminder ?? this.hasStartReminder,
      recurrence: recurrence ?? this.recurrence,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'dueDate': dueDate.toIso8601String(),
      'startTime': startTime?.toIso8601String(),
      'priority': priority.name,
      'categoryId': categoryId,
      'has30MinReminder': has30MinReminder,
      'hasStartReminder': hasStartReminder,
      'recurrence': recurrence.name,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      dueDate: DateTime.parse(json['dueDate'] as String),
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime'] as String) : null,
      priority: TaskPriority.values.byName(json['priority'] as String),
      categoryId: json['categoryId'] as String? ?? 'general',
      has30MinReminder: json['has30MinReminder'] as bool? ?? true,
      hasStartReminder: json['hasStartReminder'] as bool? ?? true,
      recurrence: json['recurrence'] != null
          ? RecurrenceType.values.byName(json['recurrence'] as String)
          : RecurrenceType.none,
    );
  }
}
