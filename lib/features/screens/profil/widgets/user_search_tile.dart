import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/features/screens/profil/presentation/profil_extern_screen.dart';

/// Kachel für die Usersuche mit Freundschafts-Status + Aktionen
class UserSearchTile extends StatelessWidget {
  final String otherUserId;
  final String username;
  final String city;
  final String profileImageUrl; // <— exakt dieser Name

  const UserSearchTile({
    super.key,
    required this.otherUserId,
    required this.username,
    required this.city,
    required this.profileImageUrl,
  });

  String get _currentUid => FirebaseAuth.instance.currentUser!.uid;

  /// Doc-ID ist sortierte Kombination beider UIDs
  String get _friendDocId {
    final ids = [_currentUid, otherUserId]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Stream<_FriendState> _watchState() {
    final reqs = FirebaseFirestore.instance.collection('friend_requests');
    final friends = FirebaseFirestore.instance.collection('friends');

    final me = _currentUid;

    // pending? (ich -> er) ODER (er -> ich)
    final outgoing = reqs
        .where('senderId', isEqualTo: me)
        .where('receiverId', isEqualTo: otherUserId)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .snapshots();

    final incoming = reqs
        .where('senderId', isEqualTo: otherUserId)
        .where('receiverId', isEqualTo: me)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .snapshots();

    final fr = friends.doc(_friendDocId).snapshots();

    return fr.asyncMap((fDoc) async {
      if (fDoc.exists) return _FriendState.friend;

      final out = await outgoing.first;
      if (out.docs.isNotEmpty) return _FriendState.pendingOutgoing;

      final inc = await incoming.first;
      if (inc.docs.isNotEmpty) return _FriendState.pendingIncoming;

      return _FriendState.none;
    });
  }

  Future<void> _sendRequest(BuildContext context) async {
    await FirebaseFirestore.instance.collection('friend_requests').add({
      'senderId': _currentUid,
      'receiverId': otherUserId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
    _toast(context, 'Anfrage gesendet');
  }

  Future<void> _acceptIncoming(BuildContext context) async {
    final db = FirebaseFirestore.instance;
    final reqSnap = await db
        .collection('friend_requests')
        .where('senderId', isEqualTo: otherUserId)
        .where('receiverId', isEqualTo: _currentUid)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (reqSnap.docs.isEmpty) return;

    final reqRef = reqSnap.docs.first.reference;
    final frRef = db.collection('friends').doc(_friendDocId);

    await db.runTransaction((tx) async {
      tx.set(frRef, {
        'users': [_currentUid, otherUserId]..sort(),
        'since': FieldValue.serverTimestamp(),
      });
      tx.update(reqRef, {
        'status': 'accepted',
        'handledAt': FieldValue.serverTimestamp(),
      });
    });
    _toast(context, 'Ihr seid jetzt Freunde');
  }

  Future<void> _cancelOutgoing(BuildContext context) async {
    final db = FirebaseFirestore.instance;
    final q = await db
        .collection('friend_requests')
        .where('senderId', isEqualTo: _currentUid)
        .where('receiverId', isEqualTo: otherUserId)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();
    if (q.docs.isNotEmpty) {
      await q.docs.first.reference.delete();
      _toast(context, 'Anfrage zurückgezogen');
    }
  }

  Future<void> _removeFriend(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('friends')
        .doc(_friendDocId)
        .delete();
    _toast(context, 'Freund entfernt');
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<_FriendState>(
      stream: _watchState(),
      builder: (context, snap) {
        final state = snap.data ?? _FriendState.none;

        return ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.hellbeige,
              backgroundImage: profileImageUrl.isNotEmpty
                  ? NetworkImage(profileImageUrl)
                  : null,
              child: profileImageUrl.isEmpty
                  ? const Icon(Icons.person, color: AppColors.dunkelbraun)
                  : null,
            ),
            title: Text(username,
                style: const TextStyle(color: AppColors.dunkelbraun)),
            subtitle: Text(city,
                style: const TextStyle(color: AppColors.dunkelbraun)),
            trailing: _buildTrailing(context, state),
            onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfilExternScreen(userId: otherUserId),
                  ),
                ));
      },
    );
  }

  Widget _buildTrailing(BuildContext context, _FriendState state) {
    switch (state) {
      case _FriendState.friend:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Freundschaft löschen',
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => _removeFriend(context),
            ),
          ],
        );
      case _FriendState.pendingOutgoing:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hourglass_top, color: AppColors.goldbraun),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Anfrage zurückziehen',
              icon: const Icon(Icons.undo, color: AppColors.dunkelbraun),
              onPressed: () => _cancelOutgoing(context),
            ),
          ],
        );
      case _FriendState.pendingIncoming:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Annehmen',
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () => _acceptIncoming(context),
            ),
            IconButton(
              tooltip: 'Ablehnen',
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () =>
                  _cancelOutgoing(context), // ablehnen = eingehende löschen
            ),
          ],
        );
      case _FriendState.none:
      default:
        return IconButton(
          tooltip: 'Freund hinzufügen',
          icon:
              const Icon(Icons.person_add_alt_1, color: AppColors.dunkelbraun),
          onPressed: () => _sendRequest(context),
        );
    }
  }
}

enum _FriendState { none, pendingOutgoing, pendingIncoming, friend }
