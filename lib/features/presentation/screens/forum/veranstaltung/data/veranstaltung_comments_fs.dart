import 'package:cloud_firestore/cloud_firestore.dart';

class VeranstaltungCommentsFs {
  final _db = FirebaseFirestore.instance;
  final String veranstaltungId;

  VeranstaltungCommentsFs(this.veranstaltungId);

  Stream<List<Map<String, dynamic>>> watch() {
    return _db
        .collection("veranstaltung")
        .doc(veranstaltungId)
        .collection("comments")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => {"id": d.id, ...d.data()}).toList());
  }

  Future<void> add({
    required String uid,
    required String text,
  }) {
    final data = {
      "uid": uid,
      "text": text.trim(),
      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    };
    return _db
        .collection("veranstaltung")
        .doc(veranstaltungId)
        .collection("comments")
        .add(data);
  }

  Future<void> delete(String commentId) {
    return _db
        .collection("veranstaltung")
        .doc(veranstaltungId)
        .collection("comments")
        .doc(commentId)
        .delete();
  }
}
