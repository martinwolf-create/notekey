import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase _i = AppDatabase._();
  AppDatabase._();
  factory AppDatabase() => _i;

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final base = await getDatabasesPath();
    final path = p.join(base, 'notekey_forum.db'); // bestehender Dateiname

    _db = await openDatabase(
      path,
      version: 3, // Veranstaltung und To-do
      onCreate: (d, v) async {
        await d.execute('''
          CREATE TABLE items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type INTEGER NOT NULL,
            title TEXT NOT NULL,
            info TEXT NOT NULL,
            image_path TEXT,
            date_epoch INTEGER,
            price_cents INTEGER,
            price_currency TEXT

          )
        ''');
        await d.execute('''
          CREATE TABLE todos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            note TEXT NOT NULL,
            done INTEGER NOT NULL DEFAULT 0,
            due_epoch INTEGER

          )
        ''');
      },
      onUpgrade: (d, oldV, newV) async {
        if (oldV < 2) {
          await d.execute('''
            CREATE TABLE IF NOT EXISTS todos(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              note TEXT NOT NULL,
              done INTEGER NOT NULL DEFAULT 0,
              due_epoch INTEGER

            )
          ''');
        }
        if (oldV < 3) {
          await d.execute('''
            ALTER TABLE items ADD COLUMN price_currency TEXT
          ''');
        }
      },
    );

    return _db!;
  }
}
