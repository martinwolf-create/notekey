import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'suchfind_model.dart';

class SuchfindRepository {
  static const String _col = 'suchfind';

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // -------- STREAM: strikt getrennt nach Bereich --------
  Stream<List<Suchfind>> watch({required MarketKind kind}) {
    return _db
        .collection(_col)
        .where('market_kind', isEqualTo: kind.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  // Optionaler Wrapper (falls noch irgendwo genutzt)
  Stream<List<Suchfind>> watchAll() {
    return _db
        .collection(_col)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  // -------- ADD --------
  Future<String> add(Suchfind s, {required MarketKind kind}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('Nicht eingeloggt.');
    }

    final data = <String, dynamic>{
      'uid': uid,
      'title': s.title,
      if (s.description != null && s.description!.isNotEmpty)
        'info': s.description,
      if (s.imageUrl != null && s.imageUrl!.isNotEmpty) 'imageUrl': s.imageUrl,
      'market_kind': kind.name, // wichtig für Filter & Index
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final ref = await _db.collection(_col).add(data);
    return ref.id;
  }

// -------- Einzelnen Datensatz live beobachten (für Detail-Screen) --------
  Stream<Suchfind?> watchById(String id) {
    return _db.collection(_col).doc(id).snapshots().map((d) {
      final data = d.data();
      if (data == null) return null;
      return _fromDoc(d);
    });
  }

  // -------- UPDATE --------
  Future<void> update(Suchfind s) async {
    if (s.id == null || s.id!.isEmpty) {
      throw ArgumentError('update() requires a valid Suchfind.id');
    }

    final data = <String, dynamic>{
      'title': s.title,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // optionale Felder nur setzen, wenn vorhanden
    if (s.description != null) data['info'] = s.description;
    if (s.imageUrl != null && s.imageUrl!.isNotEmpty) {
      data['imageUrl'] = s.imageUrl;
    }

    await _db.collection(_col).doc(s.id).update(data);
  }

  // -------- DELETE --------
  Future<void> delete(String id) async {
    await _db.collection(_col).doc(id).delete();
  }

  // -------- STORAGE UPLOAD --------
  /// Lädt ein Bild hoch und gibt die öffentliche Download-URL zurück.
  /// Pfad an deine Regeln angepasst:
  /// /suchfind/find/<uid>/sf_<timestamp>.jpg   (für MarketKind.find)
  /// /suchfind/such/<uid>/sf_<timestamp>.jpg   (für MarketKind.such)
  Future<String> uploadImage(File file, {required MarketKind kind}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Nicht eingeloggt.');

    final ts = DateTime.now().millisecondsSinceEpoch;
    final name = 'sf_$ts.jpg';

    final sub = (kind == MarketKind.find) ? 'find' : 'such';
    final ref =
        _storage.ref().child('suchfind').child(sub).child(uid).child(name);

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

  // -------- Mapping --------
  Suchfind _fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const <String, dynamic>{};

    DateTime? created;
    final ca = m['createdAt'];
    if (ca is Timestamp) created = ca.toDate();

    return Suchfind(
      id: d.id,
      title: (m['title'] ?? '').toString(),
      description:
          ((m['info'] ?? '') as String).isEmpty ? null : (m['info'] as String),
      imageUrl: (m['imageUrl'] as String?)?.trim(),
      createdAt: created,
    );
  }
}
