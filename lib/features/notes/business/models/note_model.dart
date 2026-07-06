class Note {
  final String id;
  final String title;
  final String content;
  final DateTime modifiedTime;
  final bool isPinned;
  final String categoryId;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.modifiedTime,
    this.isPinned = false,
    this.categoryId = 'general',
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? modifiedTime,
    bool? isPinned,
    String? categoryId,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      modifiedTime: modifiedTime ?? this.modifiedTime,
      isPinned: isPinned ?? this.isPinned,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'modifiedTime': modifiedTime.toIso8601String(),
      'isPinned': isPinned,
      'categoryId': categoryId,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      modifiedTime: DateTime.parse(json['modifiedTime'] as String),
      isPinned: json['isPinned'] as bool,
      categoryId: json['categoryId'] as String,
    );
  }
}
