import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Erstellt Chat oder liefert vorhandenen Chat (ID = sortierte UIDs)
  Future<String> getOrCreateChatWith(String otherUserId) async {
    final me = _auth.currentUser!;
    final ids = [me.uid, otherUserId]..sort();
    final chatId = '${ids[0]}_${ids[1]}';

    final chatRef = _db.collection('chats').doc(chatId);

    // Chat-Dokument erstellen (Regeln erlauben NUR diese Felder!)
    await chatRef.set({
      'participants': ids,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastMessage': '',
    }, SetOptions(merge: true));

    return chatId;
  }

  /// Nachricht senden + Chat Übersicht aktualisieren
  Future<void> sendMessage({
    required String chatId,
    required String text,
  }) async {
    final me = _auth.currentUser!;
    final chatRef = _db.collection('chats').doc(chatId);
    final msgRef = chatRef.collection('messages').doc();

    final chatSnap = await chatRef.get();
    final data = chatSnap.data()!;
    final List<dynamic> participants = data['participants'];
    final receiverId =
        participants.firstWhere((id) => id != me.uid, orElse: () => me.uid);

    await _db.runTransaction((tx) async {
      // Nachricht speichern
      tx.set(msgRef, {
        'senderId': me.uid,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Chat aktualisieren
      tx.update(chatRef, {
        'lastMessage': text,
        'lastMessageTime':
            FieldValue.serverTimestamp(), // ← erlaubt bei UPDATE!
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Notification erstellen
      final notifRef = _db.collection('notifications').doc();
      tx.set(notifRef, {
        'receiverId': receiverId,
        'senderId': me.uid,
        'type': 'message',
        'chatId': chatId,
        'text': text,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Nachrichtenstream
  Stream<QuerySnapshot<Map<String, dynamic>>> messageStream(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }
}
