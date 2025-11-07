import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'friendship_state.dart';

class FriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  Future<FriendshipState> getFriendshipState(String otherUserId) async {
    // Prüfen, ob eine offene Anfrage existiert
    final request = await _firestore
        .collection('friend_requests')
        .where('senderId', isEqualTo: currentUserId)
        .where('receiverId', isEqualTo: otherUserId)
        .where('status', isEqualTo: 'pending')
        .get();

    if (request.docs.isNotEmpty) return FriendshipState.pending;

    // Prüfen, ob beide Freunde sind
    final accepted = await _firestore
        .collection('friends')
        .where('users', arrayContains: currentUserId)
        .get();

    for (var doc in accepted.docs) {
      List<dynamic> users = doc['users'];
      if (users.contains(otherUserId)) return FriendshipState.accepted;
    }

    return FriendshipState.none;
  }

  Future<void> sendFriendRequest(String toUserId) async {
    await _firestore.collection('friend_requests').add({
      'senderId': currentUserId,
      'receiverId': toUserId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> acceptFriendRequest(String fromUserId) async {
    await _firestore.collection('friends').add({
      'users': [currentUserId, fromUserId],
      'since': FieldValue.serverTimestamp(),
    });

    final requests = await _firestore
        .collection('friend_requests')
        .where('senderId', isEqualTo: fromUserId)
        .where('receiverId', isEqualTo: currentUserId)
        .get();

    for (var doc in requests.docs) {
      await doc.reference.delete();
    }
  }
}
