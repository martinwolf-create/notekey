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

    // kein get() nötig → keine read-Rechte erforderlich
    await chatRef.set({
      'participants': ids,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      // optional erlaubt laut Rules:
      'lastMessage': '',
    }, SetOptions(merge: true));

    return chatId;
  }

  /// Nachricht senden UND Notification für den Empfänger erstellen
  Future<void> sendMessage({
    required String chatId,
    required String text,
  }) async {
    final me = _auth.currentUser!;
    final chatRef = _db.collection('chats').doc(chatId);
    final msgRef = chatRef.collection('messages').doc();

    // Teilnehmer herausfinden (Empfänger ermitteln)
    final chatSnap = await chatRef.get();
    if (!chatSnap.exists) {
      throw Exception("Chat nicht gefunden: $chatId");
    }

    final chatData = chatSnap.data() as Map<String, dynamic>;
    final participants = List<String>.from(chatData['participants'] ?? []);
    if (participants.length != 2) {
      throw Exception("Ungültige Teilnehmerliste");
    }

    final receiverId = participants.firstWhere((id) => id != me.uid);

    // Transaktion: Nachricht + Chat + Notification
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
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Notification-Dokument erstellen
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

  /// Stream der Nachrichten eines Chats
  Stream<QuerySnapshot<Map<String, dynamic>>> messageStream(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }
}
