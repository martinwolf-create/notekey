import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Liefert bestehende Chat-ID mit [otherUserId] – oder erstellt/vereinheitlicht sie.
  Future<String> getOrCreateChatWith(String otherUserId) async {
    final me = _auth.currentUser!;
    final ids = [me.uid, otherUserId]..sort(); // deterministische Reihenfolge
    final chatId = '${ids[0]}_${ids[1]}';
    final chatRef = _db.collection('chats').doc(chatId);

    // WICHTIG: kein get() vorher -> keine read-Rechte nötig
    await chatRef.set({
      'participants': ids,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      // optional erlaubt laut Rules:
      'lastMessage': '',
    }, SetOptions(merge: true));

    return chatId;
  }

  Future<void> sendMessage({
    required String chatId,
    required String text,
  }) async {
    final me = _auth.currentUser!;
    final chatRef = _db.collection('chats').doc(chatId);
    final msgRef = chatRef.collection('messages').doc();

    await _db.runTransaction((tx) async {
      tx.set(msgRef, {
        'senderId': me.uid,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });
      tx.update(chatRef, {
        'lastMessage': text,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> messageStream(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }
}
