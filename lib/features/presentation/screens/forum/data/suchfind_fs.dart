import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notekey_app/features/presentation/screens/forum/data/forum_item.dart';

enum MarketKind { such, find }

/// Firestore-Service für "Such & Find" (Marktplatz)
/// Collection: `suchfind`
class SuchFindFs {
  final _db = FirebaseFirestore.instance;
  static const _col = 'suchfind';

  /// App -> Firestore: Eintrag anlegen, gespeichertes Item zurückgeben
  Future<ForumItem> add(ForumItem item, {required MarketKind kind}) async {
    final ref = await _db.collection(_col).add({
      ...item.toFirestoreMap(),
      'market_kind': kind.name, //für Such/Find zwei getrennte ordner in FS
      'createdAt': FieldValue.serverTimestamp(),
    });
    final snap = await ref.get();
    return ForumItem.fromFirestore(snap.data() ?? <String, dynamic>{},
        fsId: snap.id);
  }

  /// Firestore  Live-Stream aller Einträge
  /// sortBy: 'date' | 'title' | 'price'
  Stream<List<ForumItem>> watch({
    required MarketKind kind,
    ForumItemType type = ForumItemType.market,
    String sortBy = 'date',
    bool desc = false,
    String? query,
  }) {
    Query<Map<String, dynamic>> q = _db
        .collection(_col)
        .where('type', isEqualTo: type.index)
        .where('market_kind', isEqualTo: kind.name);

    //AUSKOMMENTIERT für Abgabe / Sortierung nach datum,abc & preis deaktiviert
    /*
    final orderField = switch (sortBy) {
      'title' => 'title',
      'price' => 'price_cents',
      _ => 'date_epoch',
    };
    q = q.orderBy(orderField, descending: desc);
    */
    return q.snapshots().map((snap) {
      var list = snap.docs
          .map((d) => ForumItem.fromFirestore(d.data(), fsId: d.id))
          .toList();

      final s = query?.trim().toLowerCase();
      if (s != null && s.isNotEmpty) {
        list = list
            .where((e) =>
                e.title.toLowerCase().contains(s) ||
                e.info.toLowerCase().contains(s))
            .toList();
      }
      return list;
    });
  }

  Future<ForumItem?> getById(String id) async {
    final doc = await _db.collection(_col).doc(id).get();
    if (!doc.exists) return null;
    return ForumItem.fromFirestore(doc.data()!, fsId: doc.id);
  }

  Future<int> count() async {
    final agg = await _db.collection(_col).count().get();
    return agg.count ?? 0;
  }

  Future<void> update(String id, ForumItem item) async {
    await _db.collection(_col).doc(id).update(item.toFirestoreMap());
  }

  Future<void> delete(String id) async {
    await _db.collection(_col).doc(id).delete();
  }
}
