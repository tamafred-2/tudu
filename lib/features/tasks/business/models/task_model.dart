enum TaskPriority {
  low,
  medium,
  high,
}

class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime dueDate;
  final TaskPriority priority;
  final String categoryId;

  const Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.dueDate,
    this.priority = TaskPriority.medium,
    this.categoryId = 'general',
  });

  Task copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? dueDate,
    TaskPriority? priority,
    String? categoryId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority.name,
      'categoryId': categoryId,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool,
      dueDate: DateTime.parse(json['dueDate'] as String),
      priority: TaskPriority.values.byName(json['priority'] as String),
      categoryId: json['categoryId'] as String,
    );
  }
}
