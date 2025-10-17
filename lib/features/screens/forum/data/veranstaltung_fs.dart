import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'forum_item.dart';

// Fallback für 'type'
ForumItemType _safeType(dynamic v) {
  final i = (v is int) ? v : 0;
  return (i >= 0 && i < ForumItemType.values.length)
      ? ForumItemType.values[i]
      : ForumItemType.event;
}

class VeranstaltungenFs {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  static const _col = 'veranstaltung';

  /// Event anlegen, optional Bild hochladen (setzt imageUrl + storagePath).
  /// Storage-Pfad: events/{ownerUid}/{eventId}/{uuid}.jpg
  Future<ForumItem> addWithUpload({
    required ForumItem draft,
    required String ownerUid,
    File? localImage,
  }) async {
    // 1) Firestore-Dokument anlegen (passt zu deinen Regeln)
    final docRef = await _db.collection(_col).add({
      'uid': ownerUid,
      'type': draft.type.index,
      'title': draft.title,
      'info': draft.info,
      if (draft.date != null) 'date_epoch': draft.date!.millisecondsSinceEpoch,
      if (draft.priceCents != null) 'price_cents': draft.priceCents,
      if (draft.currency != null) 'price_currency': draft.currency,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    print('ausgefürt');

    final eventId = docRef.id;

    // 2) Optional Bild hochladen
    String? imageUrl;
    String? storagePath;
    debugPrint('schritt2');
    if (localImage != null && await localImage.exists()) {
      final fileId = const Uuid().v4();
      storagePath = '/events/$ownerUid/$eventId/$fileId.jpg';
      debugPrint('Upload to: $storagePath');
      final ref = _storage.ref(storagePath);

      final snap = await ref.putFile(
        localImage,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      if (snap.state != TaskState.success) {
        throw FirebaseException(
          plugin: 'firebase_storage',
          code: 'upload-failed',
          message: 'Upload state: ${snap.state}',
        );
      }
      imageUrl = await ref.getDownloadURL();
    }
    print('ausgefürt');
    // 3) URL + storagePath nachtragen
    await docRef.update({
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (storagePath != null) 'storagePath': storagePath,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    print('ausgefürt');
    final snap = await docRef.get();
    return _fromDoc(snap);
  }

  /// Liste beobachten (serverseitig nach type gefiltert)
  Stream<List<ForumItem>> watch({
    required ForumItemType type,
    String? query,
  }) {
    Query<Map<String, dynamic>> q = _db
        .collection(_col)
        .where('type', isEqualTo: type.index)
        .orderBy('createdAt', descending: true);

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

  /// Einzelnes Event beobachten
  Stream<ForumItem?> watchById(String id) {
    return _db.collection(_col).doc(id).snapshots().map((d) {
      if (!d.exists) return null;
      return _fromDoc(d);
    });
  }

  /// Kopieren inkl. Bild in anderes Profil.
  Future<String> copyToNewOwner({
    required String sourceId,
    required String newUid, // <— Signatur bleibt "newUid"
  }) async {
    final src = await _db.collection(_col).doc(sourceId).get();
    if (!src.exists) throw Exception('Quelle nicht gefunden (id=$sourceId)');
    final m = src.data()!;
    final String? srcImageUrl = (m['imageUrl'] as String?)?.trim();

    final newRef = _db.collection(_col).doc();
    final newId = newRef.id;

    await newRef.set({
      'uid': newUid,
      'type': (m['type'] is int) ? m['type'] : 0,
      'title': (m['title'] ?? '').toString(),
      'info': (m['info'] ?? '').toString(),
      if (m['date_epoch'] != null) 'date_epoch': m['date_epoch'],
      if (m['price_cents'] != null) 'price_cents': m['price_cents'],
      if (m['price_currency'] != null) 'price_currency': m['price_currency'],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    String? newImageUrl;
    String? newStoragePath;

    if (srcImageUrl != null && srcImageUrl.isNotEmpty) {
      try {
        final srcRef = _storage.refFromURL(srcImageUrl);
        final data = await srcRef.getData(20 * 1024 * 1024); // ≤ 20 MB
        if (data != null) {
          final fileId = const Uuid().v4();
          newStoragePath = 'events/$newUid/$newId/$fileId.jpg';
          final dstRef = _storage.ref(newStoragePath);
          final snap = await dstRef.putData(
            Uint8List.fromList(data),
            SettableMetadata(contentType: 'image/jpeg'),
          );
          if (snap.state != TaskState.success) {
            throw FirebaseException(
              plugin: 'firebase_storage',
              code: 'upload-failed',
              message: 'Upload state: ${snap.state}',
            );
          }
          newImageUrl = await dstRef.getDownloadURL();
        }
      } catch (_) {
        // optional – Event existiert auch ohne Bild
      }
    }

    await newRef.update({
      if (newImageUrl != null) 'imageUrl': newImageUrl,
      if (newStoragePath != null) 'storagePath': newStoragePath,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return newId;
  }

  Future<void> delete(String id) async {
    await _db.collection(_col).doc(id).delete();
  }

  // Mapping
  ForumItem _fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const <String, dynamic>{};
    final imageUrl = (m['imageUrl'] as String?)?.trim();
    final legacy = (m['image_path'] as String?)?.trim();

    return ForumItem(
      id: null,
      fsId: d.id,
      ownerUid: (m['uid'] as String?)?.trim(),
      type: _safeType(m['type']),
      title: (m['title'] ?? '').toString(),
      info: (m['info'] ?? '').toString(),
      imagePath: (imageUrl != null && imageUrl.isNotEmpty) ? imageUrl : legacy,
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
