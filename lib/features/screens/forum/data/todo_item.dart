class TodoItem {
  // SQLite-ID (lokal)
  final int? id;

  // Firestore-Dokument-ID (Cloud)
  final String? fsId;

  final String title;
  final String note;
  final bool done;
  final DateTime? due;

  const TodoItem({
    this.id,
    this.fsId,
    required this.title,
    required this.note,
    this.done = false,
    this.due,
  });

  TodoItem copyWith({
    int? id,
    String? fsId,
    String? title,
    String? note,
    bool? done,
    DateTime? due,
  }) {
    return TodoItem(
      id: id ?? this.id,
      fsId: fsId ?? this.fsId,
      title: title ?? this.title,
      note: note ?? this.note,
      done: done ?? this.done,
      due: due ?? this.due,
    );
  }

  // SQLite
  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'note': note,
        'done': done ? 1 : 0,
        'due_epoch': due?.millisecondsSinceEpoch,
      };

  static TodoItem fromMap(Map<String, dynamic> m) => TodoItem(
        id: m['id'] as int?,
        fsId: null,
        title: m['title'] as String,
        note: m['note'] as String,
        done: (m['done'] as int) == 1,
        due: (m['due_epoch'] as int?) != null
            ? DateTime.fromMillisecondsSinceEpoch(m['due_epoch'] as int)
            : null,
      );

  // Firestore
  factory TodoItem.fromFirestore(
    Map<String, dynamic> m, {
    required String fsId,
  }) {
    return TodoItem(
      id: null,
      fsId: fsId,
      title: (m['title'] ?? '') as String,
      note: (m['note'] ?? '') as String,
      done: (m['done'] ?? false) as bool,
      due: (m['due_epoch'] as int?) != null
          ? DateTime.fromMillisecondsSinceEpoch(m['due_epoch'] as int)
          : null,
    );
  }

  Map<String, dynamic> toFirestoreMap() => {
        'title': title,
        'note': note,
        'done': done,
        'due_epoch': due?.millisecondsSinceEpoch,
      };
}
