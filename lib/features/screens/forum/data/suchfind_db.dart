import 'package:sqflite/sqflite.dart';
import 'forum_item.dart';

/// SQLite-DB für "Such & Find" (Marktplatz)
class SuchfindDb {
  final Database db;
  SuchfindDb(this.db);

  Future<int> insert(ForumItem item) {
    // factory-konform
    return db.insert('items', item.toSqlMap());
  }

  Future<int> delete(int id) {
    return db.delete('items', where: 'id=?', whereArgs: [id]);
  }

  Future<int> updateImagePath(int id, String newPath) {
    return db.update(
      'items',
      {'image_path': newPath},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<ForumItem>> list({
    String? query,
    String sortBy = 'date',
    bool desc = false,
  }) async {
    final where = <String>[];
    final args = <Object?>[];

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

    final rows = await db.query(
      'items',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: orderBy,
    );

    // factory-konform
    return rows.map(ForumItem.fromSqlMap).toList();
  }
}
