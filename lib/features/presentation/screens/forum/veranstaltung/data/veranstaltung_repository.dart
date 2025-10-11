import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'veranstaltung_model.dart';

class VeranstaltungRepository {
  static const String _col = 'veranstaltung';

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ---------- STREAM ----------
  Stream<List<Veranstaltung>> watchAll() {
    return _db
        .collection(_col)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  // ---------- ADD ----------
  Future<String> add(Veranstaltung v) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    final data = <String, dynamic>{
      'uid': uid,
      'title': v.title,
      // WICHTIG: Regeln erwarten "info", nicht "description"
      if (v.description != null && v.description!.isNotEmpty)
        'info': v.description,
      // optionales Datum
      if (v.date != null) 'date_epoch': v.date!.millisecondsSinceEpoch,
      // Bild-URL optional
      if (v.imageUrl != null && v.imageUrl!.isNotEmpty) 'imageUrl': v.imageUrl,
      // Regeln erlauben "type" → 0 = event
      'type': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final ref = await _db.collection(_col).add(data);
    return ref.id;
  }

  // ---------- UPDATE ----------
  Future<void> update(Veranstaltung v) async {
    if (v.id == null || v.id!.isEmpty) {
      throw ArgumentError('update() requires a valid Veranstaltung.id');
    }

    final data = <String, dynamic>{
      'title': v.title,
      if (v.description != null) 'info': v.description, // wieder "info"
      if (v.imageUrl != null && v.imageUrl!.isNotEmpty) 'imageUrl': v.imageUrl,
      if (v.date != null) 'date_epoch': v.date!.millisecondsSinceEpoch,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _db.collection(_col).doc(v.id).update(data);
  }

  // ---------- DELETE ----------
  Future<void> delete(String id) async {
    await _db.collection(_col).doc(id).delete();
  }

  // ---------- IMAGE UPLOAD ----------
  Future<String> uploadImage(File file) async {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final name = 'event_$ts.jpg';
    final ref = _storage.ref().child('events').child(name);

    final snap = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    if (snap.state != TaskState.success) {
      throw FirebaseException(
        plugin: 'firebase_storage',
        code: 'upload-failed',
        message: 'Upload failed with state: ${snap.state}',
      );
    }
    return await ref.getDownloadURL();
  }

  //  MAPPING
  Veranstaltung _fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    // Datum robust aus date_epoch oder createdAt
    DateTime parsedDate = DateTime.now();
    final de = m['date_epoch'];
    if (de is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(de);
    } else if (m['createdAt'] is Timestamp) {
      parsedDate = (m['createdAt'] as Timestamp).toDate();
    }

    return Veranstaltung(
      id: d.id,
      title: (m['title'] ?? '').toString(),
      // "info" aus DB zurück in dein Model.description
      description:
          (m['info'] ?? '').toString().isEmpty ? null : (m['info'] as String),
      imageUrl: (m['imageUrl'] as String?)?.trim() ?? '',
      date: parsedDate,
      // KEIN "location": ist in Regeln nicht erlaubt
      location: null,
    );
  }
}
