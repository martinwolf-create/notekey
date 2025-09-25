import 'package:cloud_firestore/cloud_firestore.dart';
import 'forum_item.dart';

class VeranstaltungenFs {
  final _db = FirebaseFirestore.instance;
  static const _col = 'veranstaltung';

  // ERSTELLEN (App Firestore)
  Future<ForumItem> add(ForumItem item) async {
    final data = {
      'type': item.type.index, // int
      'title': item.title, // String
      'info': item.info, // String
      'image_path': item.imagePath, // String
      'date_epoch': item.date?.millisecondsSinceEpoch, // int
      'price_cents': item.priceCents, // int
      'price_currency': item.currency, // String
      'createdAt': FieldValue.serverTimestamp()
    };
    final ref = await _db.collection(_col).add(data);
    // Firestore-Daten zurück in ForumItem mappen (inkl. String-ID)
    final snap = await ref.get();
    return _fromDoc(snap);
  }

  // LÖSCHEN
  Future<void> delete(String id) async {
    await _db.collection(_col).doc(id).delete();
  }

  // LIVE-LISTE
  Stream<List<ForumItem>> watch({
    required ForumItemType type,
    String sortBy = 'date', // date, title, price
    bool desc = false,
    String? query,
  }) {
    Query<Map<String, dynamic>> q =
        _db.collection(_col).where('type', isEqualTo: type.index);

    //AUSKOMMENTIERT (sortierung / index nötig in Firestore)

    //final orderField = sortBy == 'title'
    //  ? 'title'
    //  : sortBy == 'price'
    //    ? 'price_cents'
    //      : 'date_epoch';
    //q = q.orderBy(orderField, descending: desc);

    return q.snapshots().map((snap) {
      var list = snap.docs.map(_fromDoc).toList();
      final qq = query?.trim().toLowerCase();
      if (qq != null && qq.isNotEmpty) {
        list = list
            .where((e) =>
                e.title.toLowerCase().contains(qq) ||
                e.info.toLowerCase().contains(qq))
            .toList();
      }
      return list;
    });
  }

  ForumItem _fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return ForumItem(
      // ForumItem.id ist ein int (für SQLite).
      // Für Firestore: String-ID.

      id: null, // int bleibt ungenutzt bei Firestore
      fsId: d.id, // String-ID aus Firestore
      type: ForumItemType.values[(m['type'] ?? 0) as int],
      title: (m['title'] ?? '') as String,
      info: (m['info'] ?? '') as String,
      imagePath: m['image_path'] as String?,
      date: (m['date_epoch'] as int?) != null
          ? DateTime.fromMillisecondsSinceEpoch(m['date_epoch'] as int)
          : null,
      priceCents: m['price_cents'] as int?,
      currency: m['price_currency'] as String?,
    );
  }
}
