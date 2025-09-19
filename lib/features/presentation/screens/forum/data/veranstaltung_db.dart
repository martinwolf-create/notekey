import 'package:sqflite/sqflite.dart';
import 'app_database.dart';
import 'forum_item.dart';

class VeranstaltungDb {
  final _db = AppDatabase();

  Future<int> insert(ForumItem item) async {
    final d = await _db.db;
    return d.insert('items', item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> delete(int id) async {
    final d = await _db.db;
    return d.delete('items', where: 'id=?', whereArgs: [id]);
  }

  Future<List<ForumItem>> list({
    required ForumItemType type,
    String? query, // Suche im Titel/Info
    String sortBy = 'date', // 'date' | 'price' | 'title'
    bool desc = false,
  }) async {
    final Database d = await _db.db;

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
