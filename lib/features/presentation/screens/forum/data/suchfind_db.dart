import 'package:sqflite/sqflite.dart';
import 'app_database.dart';
import 'forum_item.dart';

class SuchFindDb {
  final _db = AppDatabase();

  Future<int> insert(ForumItem i) async {
    final d = await _db.db;
    return d.insert('items', i.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(ForumItem i) async {
    final d = await _db.db;
    return d.update('items', i.toMap(), where: 'id=?', whereArgs: [i.id]);
  }

  Future<int> delete(int id) async {
    final d = await _db.db;
    return d.delete('items', where: 'id=?', whereArgs: [id]);
  }

  /// withPrice=false -> "Such" (ohne Preis)
  /// withPrice=true  -> "Find" (mit Preis)
  Future<List<ForumItem>> list({
    required bool withPrice,
    String? query,
    String sortBy = 'title', // 'title' | 'price'
    bool desc = false,
  }) async {
    final d = await _db.db;
    final where = <String>['type = ?'];
    final args = <Object?>[ForumItemType.market.index];

    if (withPrice) {
      where.add('price_cents IS NOT NULL');
    } else {
      where.add('price_cents IS NULL');
    }
    if (query != null && query.trim().isNotEmpty) {
      where.add('(title LIKE ? OR info LIKE ?)');
      args.addAll(['%$query%', '%$query%']);
    }

    String orderBy;
    switch (sortBy) {
      case 'price':
        orderBy = 'price_cents ${desc ? 'DESC' : 'ASC'} NULLS LAST';
        break;
      default:
        orderBy = 'LOWER(title) ${desc ? 'DESC' : 'ASC'}';
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
