import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'todo_item.dart';

class TodoFs {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col() =>
      _db.collection('todo'); // TOP-LEVEL

  String _uid() {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) throw Exception('Nicht eingeloggt');
    return u.uid;
  }

  Future<TodoItem> add(TodoItem t) async {
    final ref = await _col().add({
      ...t.toFirestoreMap(),
      'userId': _uid(), // WICHTIG!
      'createdAt': FieldValue.serverTimestamp(),
    });
    final snap = await ref.get();
    return TodoItem.fromFirestore(snap.data() ?? <String, dynamic>{},
        fsId: ref.id);
  }

  Future<void> update(String id, TodoItem t) async {
    await _col().doc(id).update(t.toFirestoreMap());
  }

  Future<void> delete(String id) async {
    await _col().doc(id).delete();
  }

  Stream<List<TodoItem>> watch({
    String sortBy = 'due',
    bool desc = false,
    bool? onlyOpen,
    String? query,
  }) {
    // Nur eigene To-Dos laden
    Query<Map<String, dynamic>> q = _col().where('userId', isEqualTo: _uid());

    return q.snapshots().map((snap) {
      var list = snap.docs
          .map((d) => TodoItem.fromFirestore(d.data(), fsId: d.id))
          .toList();

      // lokale Filter/Sortierung (kein Index nötig)
      final s = query?.trim().toLowerCase();
      if (s != null && s.isNotEmpty) {
        list = list
            .where((t) =>
                t.title.toLowerCase().contains(s) ||
                t.note.toLowerCase().contains(s))
            .toList();
      }
      if (onlyOpen != null)
        list = list.where((t) => onlyOpen ? !t.done : t.done).toList();

      int cmp(TodoItem a, TodoItem b) {
        switch (sortBy) {
          case 'title':
            final r = a.title.toLowerCase().compareTo(b.title.toLowerCase());
            return desc ? -r : r;
          case 'done':
            final r2 = a.done.toString().compareTo(b.done.toString());
            return desc ? -r2 : r2;
          default:
            final av = a.due?.millisecondsSinceEpoch ?? 1 << 62;
            final bv = b.due?.millisecondsSinceEpoch ?? 1 << 62;
            final r3 = av.compareTo(bv);
            return desc ? -r3 : r3;
        }
      }

      list.sort(cmp);
      return list;
    });
  }
}
