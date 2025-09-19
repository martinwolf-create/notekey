import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'forum_item.dart';
import 'todo_item.dart';

class ForumDb {
  static final ForumDb _i = ForumDb._();
  ForumDb._();
  factory ForumDb() => _i;

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final base = await getDatabasesPath();
    final path = p.join(base, 'notekey_forum.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (d, v) async {
        await d.execute('''
          CREATE TABLE items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type INTEGER NOT NULL,
            title TEXT NOT NULL,
            info TEXT NOT NULL,
            image_path TEXT,
            date_epoch INTEGER,
            price_cents INTEGER
          )
        ''');
      },
    );
    return _db!;
  }

  Future<int> insert(ForumItem item) async {
    final d = await db;
    return d.insert(
      'items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> delete(int id) async {
    final d = await db;
    return d.delete('items', where: 'id=?', whereArgs: [id]);
  }

  /// Bildpfad aktualisieren
  Future<int> updateImagePath(int id, String newPath) async {
    final d = await db;
    return d.update(
      'items',
      {'image_path': newPath},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<ForumItem>> list({
    required ForumItemType type,
    String? query,
    String sortBy = 'date',
    bool desc = false,
  }) async {
    final d = await db;
    final where = <String>['type=?'];
    final args = <Object?>[type.index];
    if (query != null && query.trim().isNotEmpty) {
      where.add('(title LIKE ? OR info LIKE ?)');
      args.addAll(['%$query%', '%$query%']);
    }

    String orderBy;
    switch (sortBy) {
      case 'price':
        orderBy = 'price_cents ${desc ? 'DESC' : 'ASC'} NULLS LAST';
        break;
      case 'title':
        orderBy = 'LOWER(title) ${desc ? 'DESC' : 'ASC'}';
        break;
      default:
        orderBy = 'date_epoch ${desc ? 'DESC' : 'ASC'} NULLS LAST';
    }

    final rows = await d.query(
      'items',
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: orderBy,
    );
    return rows.map(ForumItem.fromMap).toList();
  }
}
