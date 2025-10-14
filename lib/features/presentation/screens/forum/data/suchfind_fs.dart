import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'forum_item.dart';

enum MarketKind { find, such }

class SuchFindFs {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  static const _col = 'suchfind';

  // --------- WATCH ---------
  Stream<List<ForumItem>> watch({
    required MarketKind kind,
    String? query,
  }) {
    final q = _db
        .collection(_col)
        .where('market_kind', isEqualTo: kind.name)
        .orderBy('createdAt', descending: true);

    return q.snapshots().map((snap) {
      var items = snap.docs.map(_fromDoc).toList();
      final qq = query?.trim().toLowerCase();
      if (qq != null && qq.isNotEmpty) {
        items = items
            .where((e) =>
                e.title.toLowerCase().contains(qq) ||
                e.info.toLowerCase().contains(qq))
            .toList();
      }
      return items;
    });
  }

  // --------- ADD ---------
  Future<String> add(ForumItem base, {required MarketKind kind}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw StateError('Nicht eingeloggt.');

    final doc = await _db.collection(_col).add({
      'uid': uid,
      'market_kind': kind.name,
      'title': base.title,
      'info': base.info,
      'imageUrl': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    String? imageUrl;
    final p = base.imagePath;
    if (p != null && p.trim().isNotEmpty) {
      final file = File(p.startsWith('file:') ? Uri.parse(p).path : p);
      if (await file.exists()) {
        final path = 'suchfind/$uid/${doc.id}/${const Uuid().v4()}.jpg';
        final ref = _storage.ref(path);
        final snap = await ref.putFile(
          file,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        if (snap.state == TaskState.success) {
          imageUrl = await ref.getDownloadURL();
        }
      }
    }

    if (imageUrl != null) {
      await doc.update({
        'imageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    return doc.id;
  }

  // --------- UPDATE ---------
  Future<void> update(String fsId, ForumItem base) async {
    final data = <String, dynamic>{
      'title': base.title,
      'info': base.info,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final p = base.imagePath;
    if (p != null && p.trim().isNotEmpty) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final file = File(p.startsWith('file:') ? Uri.parse(p).path : p);
        if (await file.exists()) {
          final path = 'suchfind/$uid/$fsId/${const Uuid().v4()}.jpg';
          final ref = _storage.ref(path);
          final snap = await ref.putFile(
            file,
            SettableMetadata(contentType: 'image/jpeg'),
          );
          if (snap.state == TaskState.success) {
            data['imageUrl'] = await ref.getDownloadURL();
          }
        }
      }
    }

    await _db.collection(_col).doc(fsId).update(data);
  }

  // --------- DELETE ---------
  Future<void> delete(String fsId) async {
    await _db.collection(_col).doc(fsId).delete();
  }

  // --------- MAP ---------
  ForumItem _fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    final imageUrl = (m['imageUrl'] as String?)?.trim();
    DateTime? date;
    final ts = m['createdAt'];
    if (ts is Timestamp) date = ts.toDate();

    return ForumItem(
      id: null,
      fsId: d.id,
      ownerUid: (m['uid'] as String?)?.trim(),
      type: ForumItemType.market,
      title: (m['title'] ?? '').toString(),
      info: (m['info'] ?? '').toString(),
      imagePath: imageUrl,
      date: date,
      priceCents: null,
      currency: null,
    );
  }
}
