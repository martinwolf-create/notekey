class TodoItem {
  final int? id;
  final String title;
  final String note;
  final bool done;
  final DateTime? due;

  TodoItem({
    this.id,
    required this.title,
    required this.note,
    this.done = false,
    this.due,
  });

  TodoItem copyWith({
    int? id,
    String? title,
    String? note,
    bool? done,
    DateTime? due,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      done: done ?? this.done,
      due: due ?? this.due,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'note': note,
        'done': done ? 1 : 0,
        'due_epoch': due?.millisecondsSinceEpoch,
      };

  static TodoItem fromMap(Map<String, dynamic> m) => TodoItem(
        id: m['id'] as int?,
        title: m['title'] as String,
        note: m['note'] as String,
        done: (m['done'] as int) == 1,
        due: (m['due_epoch'] as int?) != null
            ? DateTime.fromMillisecondsSinceEpoch(m['due_epoch'] as int)
            : null,
      );
}
