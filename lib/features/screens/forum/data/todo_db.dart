import 'package:sqflite/sqflite.dart';
import 'app_database.dart';
import 'todo_item.dart';

class TodoDb {
  final _db = AppDatabase();

  Future<int> insert(TodoItem t) async {
    final d = await _db.db;
    return d.insert('todos', t.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(TodoItem t) async {
    final d = await _db.db;
    return d.update('todos', t.toMap(), where: 'id=?', whereArgs: [t.id]);
  }

  Future<int> delete(int id) async {
    final d = await _db.db;
    return d.delete('todos', where: 'id=?', whereArgs: [id]);
  }

  Future<List<TodoItem>> list({
    String? query,
    String sortBy = 'due',
    bool desc = false,
    bool? onlyOpen,
  }) async {
    final Database d = await _db.db;

    final where = <String>[];
    final args = <Object?>[];

    if (query != null && query.trim().isNotEmpty) {
      where.add('(title LIKE ? OR note LIKE ?)');
      args.addAll(['%$query%', '%$query%']);
    }
    if (onlyOpen != null) {
      where.add('done = ?');
      args.add(onlyOpen ? 0 : 1);
    }

    String orderBy;
    switch (sortBy) {
      case 'title':
        orderBy = 'LOWER(title) ${desc ? 'DESC' : 'ASC'}';
        break;
      case 'done':
        orderBy = 'done ${desc ? 'DESC' : 'ASC'}, due_epoch IS NULL, due_epoch';
        break;
      default:
        orderBy = 'due_epoch IS NULL, due_epoch ${desc ? 'DESC' : 'ASC'}, done';
    }

    final rows = await d.query(
      'todos',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: orderBy,
    );
    return rows.map(TodoItem.fromMap).toList();
  }
}
