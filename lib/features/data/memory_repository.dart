import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MemoryRepository {
  final _db = FirebaseFirestore.instance;

  /// Schreibt einen Score nach /memory_scores – Regeln-konform.
  Future<void> addScore({
    required String name,
    required String mode, // 'vs_computer' | 'local'
    required int moves,
    required int score,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError(
          'Nicht eingeloggt – Score darf nicht geschrieben werden.');
    }

    await _db.collection('memory_scores').add({
      'uid': uid,
      'name': name,
      'mode': mode, // exakt wie in den Regeln
      'moves': moves,
      'score': score,
      'finishedAt': FieldValue.serverTimestamp(), // MUSS == request.time sein
    });
  }
}
