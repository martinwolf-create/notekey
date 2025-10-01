import 'package:cloud_firestore/cloud_firestore.dart';
import 'forum_item.dart';

// int zu ForumItemType sicher
ForumItemType _safeType(dynamic v) {
  final i = (v is int) ? v : 0;
  return (i >= 0 && i < ForumItemType.values.length)
      ? ForumItemType.values[i]
      : ForumItemType.event;
}

class VeranstaltungenFs {
  final _db = FirebaseFirestore.instance;
  static const _col = 'veranstaltung';

  // Create mit sauberem Schema
  Future<ForumItem> addNetwork({
    required ForumItem item,
    required String uid,
    String? imageUrl,
  }) async {
    final data = <String, dynamic>{
      'uid': uid,
      'type': item.type.index,
      'title': item.title,
      'info': item.info,
      if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
      'date_epoch': item.date?.millisecondsSinceEpoch,
      if (item.priceCents != null) 'price_cents': item.priceCents,
      if (item.currency != null) 'price_currency': item.currency,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    final ref = await _db.collection(_col).add(data);
    final snap = await ref.get();
    return _fromDoc(snap);
  }

  // ohne uid
  @Deprecated('Nutze addNetwork() / CreateEntryPage.')
  Future<ForumItem> add(ForumItem item) async {
    final data = {
      'type': item.type.index,
      'title': item.title,
      'info': item.info,
      'image_path': item.imagePath,
      'date_epoch': item.date?.millisecondsSinceEpoch,
      'price_cents': item.priceCents,
      'price_currency': item.currency,
      'createdAt': FieldValue.serverTimestamp(),
    };
    final ref = await _db.collection(_col).add(data);
    final snap = await ref.get();
    return _fromDoc(snap);
  }

  // Löschen per Doc-ID
  Future<void> delete(String id) async {
    await _db.collection(_col).doc(id).delete();
  }

  // Live-Liste nach Typ, sortiert per createdAt (neu zu alt)
  Stream<List<ForumItem>> watch({
    required ForumItemType type,
    String sortBy = 'date',
    bool desc = false,
    String? query,
  }) {
    Query<Map<String, dynamic>> q =
        _db.collection(_col).where('type', isEqualTo: type.index);

    q = q.orderBy('createdAt', descending: true);

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

  // Live-Einzeldokument (Detail)
  Stream<ForumItem?> watchById(String id) {
    return _db.collection(_col).doc(id).snapshots().map((d) {
      if (!d.exists) return null;
      return _fromDoc(d);
    });
  }

  // Kopieren auf neuen Owner
  Future<String> copyToNewOwner({
    required String sourceId,
    required String newUid,
  }) async {
    final src = await _db.collection(_col).doc(sourceId).get();
    if (!src.exists) throw Exception('Quelle nicht gefunden');

    final m = src.data()!;
    final newData = {
      ...m,
      'uid': newUid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    newData.remove('image_path'); // lokalen Pfad nicht übernehmen
    final ref = await _db.collection(_col).add(newData);
    return ref.id;
  }

  // Firestore zu Model (imageUrl bevorzugt)
  ForumItem _fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const <String, dynamic>{};
    final imageUrl = (m['imageUrl'] as String?)?.trim();
    final imagePathLegacy = (m['image_path'] as String?)?.trim();

    return ForumItem(
      id: null,
      fsId: d.id,
      ownerUid:
          (m['uid'] as String?)?.trim() ?? (m['ownerUid'] as String?)?.trim(),
      type: _safeType(m['type']),
      title: (m['title'] as String?)?.trim() ?? '',
      info: (m['info'] as String?)?.trim() ?? '',
      imagePath: (imageUrl != null && imageUrl.isNotEmpty)
          ? imageUrl
          : imagePathLegacy,
      date: (m['date_epoch'] is int)
          ? DateTime.fromMillisecondsSinceEpoch(m['date_epoch'] as int)
          : (m['createdAt'] is Timestamp
              ? (m['createdAt'] as Timestamp).toDate()
              : null),
      priceCents: m['price_cents'] as int?,
      currency: m['price_currency'] as String?,
    );
  }
}
