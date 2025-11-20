import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Chat-ID (kombiniert aus beiden User-IDs, sortiert)
  Future<String> getOrCreateChatWith(String otherUserId) async {
    final me = _auth.currentUser!;
    final ids = [me.uid, otherUserId]..sort();
    final chatId = '${ids[0]}_${ids[1]}';

    final chatRef = _db.collection('chats').doc(chatId);

    await chatRef.set({
      'participants': ids,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastMessage': '',
      // lastMessageTime kommt beim ersten Senden
    }, SetOptions(merge: true));

    return chatId;
  }

  /// Text- oder Bildnachricht senden (+ Notification + lastMessageTime)
  Future<void> sendMessage({
    required String chatId,
    required String text,
    String? imageUrl,
  }) async {
    final me = _auth.currentUser!;
    final chatRef = _db.collection('chats').doc(chatId);
    final msgRef = chatRef.collection('messages').doc();

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

    final String trimmed = text.trim();
    final String preview = trimmed.isNotEmpty
        ? trimmed
        : (imageUrl != null && imageUrl.isNotEmpty ? '📷 Foto' : '');

    await _db.runTransaction((tx) async {
      tx.set(msgRef, {
        'senderId': me.uid,
        'text': trimmed,
        'imageUrl': imageUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      tx.update(chatRef, {
        'lastMessage': preview,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final notifRef = _db.collection('notifications').doc();
      tx.set(notifRef, {
        'receiverId': receiverId,
        'senderId': me.uid,
        'type': 'message',
        'chatId': chatId,
        'text': preview,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Stream der Nachrichten in zeitlicher Reihenfolge
  Stream<QuerySnapshot<Map<String, dynamic>>> messageStream(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }
}
