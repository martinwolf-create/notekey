import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/features/chat/chat_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  Future<Map<String, dynamic>> _getUserInfo(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!doc.exists) return {'username': 'Unbekannt', 'profileImageUrl': ''};
    final d = doc.data()!;
    return {
      'username': (d['username'] ?? 'Unbekannt') as String,
      'profileImageUrl': (d['profileImageUrl'] ?? '') as String,
    };
  }

  Future<void> _respondToRequest(
      String requestId, String fromUserId, bool accept) async {
    final db = FirebaseFirestore.instance;
    final batch = db.batch();
    final reqRef = db.collection('friend_requests').doc(requestId);

    if (accept) {
      final ids = [currentUserId, fromUserId]..sort();
      final friendRef = db.collection('friends').doc('${ids[0]}_${ids[1]}');
      batch.set(friendRef, {
        'users': ids,
        'since': FieldValue.serverTimestamp(),
      });
      batch.update(reqRef, {
        'status': 'accepted',
        'handledAt': FieldValue.serverTimestamp(),
      });
    } else {
      batch.update(reqRef, {
        'status': 'rejected',
        'handledAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    final friendRequestStream = FirebaseFirestore.instance
        .collection('friend_requests')
        .where('receiverId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'pending')
        .snapshots();

    // ✅ Mit type-Filter + orderBy (benötigt den Composite-Index)
    final notificationStream = FirebaseFirestore.instance
        .collection('notifications')
        .where('receiverId', isEqualTo: currentUserId)
        .where('type', isEqualTo: 'message')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: AppColors.hellbeige,
      appBar: AppBar(
        backgroundColor: AppColors.dunkelbraun,
        foregroundColor: AppColors.hellbeige,
        title: const Text('📬 Notifications'),
        automaticallyImplyLeading: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: friendRequestStream,
        builder: (context, reqSnap) {
          if (reqSnap.hasError) {
            return _errorBox('Fehler (Friend-Req): ${reqSnap.error}');
          }
          final requestDocs = reqSnap.data?.docs ?? [];

          return StreamBuilder<QuerySnapshot>(
            stream: notificationStream,
            builder: (context, notiSnap) {
              if (notiSnap.hasError) {
                return _errorBox('Fehler (Notifications): ${notiSnap.error}');
              }

              final notiDocs = notiSnap.data?.docs ?? [];
              final hasAny = requestDocs.isNotEmpty || notiDocs.isNotEmpty;

              if (reqSnap.connectionState == ConnectionState.waiting ||
                  notiSnap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.goldbraun),
                );
              }

              if (!hasAny) {
                return const Center(
                  child: Text(
                    'Keine neuen Benachrichtigungen',
                    style:
                        TextStyle(color: AppColors.dunkelbraun, fontSize: 16),
                  ),
                );
              }

              final items = <Widget>[];

              // 🔔 Nachrichten
              if (notiDocs.isNotEmpty) {
                items.add(_sectionHeader('Nachrichten'));
                for (final n in notiDocs) {
                  items.add(_MessageNotificationTile(
                    notifDoc: n,
                    getUserInfo: _getUserInfo,
                  ));
                }
              }

              // 🧑‍🤝‍🧑 Freundschaftsanfragen
              if (requestDocs.isNotEmpty) {
                items.add(_sectionHeader('Freundschaftsanfragen'));
                for (final req in requestDocs) {
                  final fromUserId = req['senderId'] as String;
                  final requestId = req.id;
                  items.add(
                    FutureBuilder<Map<String, dynamic>>(
                      future: _getUserInfo(fromUserId),
                      builder: (context, snap) {
                        final username = snap.data?['username'] ?? 'Lädt...';
                        final imageUrl = snap.data?['profileImageUrl'] ?? '';

                        return Card(
                          color: AppColors.rosebeige,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: imageUrl.isNotEmpty
                                  ? NetworkImage(imageUrl)
                                  : null,
                              backgroundColor: AppColors.goldbraun,
                              radius: 28,
                              child: imageUrl.isEmpty
                                  ? const Icon(Icons.person,
                                      color: Colors.white)
                                  : null,
                            ),
                            title: Text(
                              'Anfrage von: $username',
                              style: const TextStyle(
                                color: AppColors.dunkelbraun,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                TextButton(
                                  onPressed: () => _respondToRequest(
                                      requestId, fromUserId, true),
                                  child: const Text('Annehmen'),
                                ),
                                const SizedBox(width: 12),
                                TextButton(
                                  onPressed: () => _respondToRequest(
                                      requestId, fromUserId, false),
                                  child: const Text('Ablehnen'),
                                ),
                              ],
                            ),
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/profilExtern',
                              arguments: fromUserId,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              }

              final fromCache = notiSnap.data?.metadata.isFromCache == true ||
                  reqSnap.data?.metadata.isFromCache == true;

              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 24),
                      children: items,
                    ),
                  ),
                  if (fromCache)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        '… aus Cache geladen – Serverdaten folgen',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.dunkelbraun,
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.dunkelbraun,
          ),
        ),
      );

  Widget _errorBox(String msg) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            msg,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      );
}

// ----------------------------------------------------------
// 🔥 Nachricht-Card mit stabilem Swipe-to-Delete (Fix)
// ----------------------------------------------------------

class _MessageNotificationTile extends StatefulWidget {
  final QueryDocumentSnapshot notifDoc;
  final Future<Map<String, dynamic>> Function(String uid) getUserInfo;

  const _MessageNotificationTile({
    required this.notifDoc,
    required this.getUserInfo,
  });

  @override
  State<_MessageNotificationTile> createState() =>
      _MessageNotificationTileState();
}

class _MessageNotificationTileState extends State<_MessageNotificationTile> {
  @override
  Widget build(BuildContext context) {
    final data = widget.notifDoc.data() as Map<String, dynamic>;
    final senderId = data['senderId'] ?? '';
    final chatId = data['chatId'] ?? '';
    final text = data['text'] ?? 'Neue Nachricht';
    final isRead = data['read'] ?? false;

    return FutureBuilder<Map<String, dynamic>>(
      future: widget.getUserInfo(senderId),
      builder: (context, snap) {
        final username = snap.data?['username'] ?? 'Unbekannt';
        final imageUrl = snap.data?['profileImageUrl'] ?? '';

        return Dismissible(
          key: ValueKey(widget.notifDoc.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete, color: Colors.white, size: 28),
          ),
          confirmDismiss: (_) async {
            // Animation darf sofort ablaufen
            return true;
          },
          onDismissed: (_) async {
            // Erst nach Animation löschen → kein Hänger
            try {
              await widget.notifDoc.reference.delete();
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Fehler beim Löschen: $e'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            }
          },
          child: Card(
            color: AppColors.rosebeige,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundImage:
                    imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                backgroundColor: AppColors.goldbraun,
                child: imageUrl.isEmpty
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              title: Text(
                username,
                style: const TextStyle(
                  color: AppColors.dunkelbraun,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.dunkelbraun.withOpacity(0.8),
                ),
              ),
              trailing: isRead
                  ? const SizedBox.shrink()
                  : const Icon(Icons.fiber_manual_record,
                      size: 12, color: Colors.redAccent),
              onTap: () async {
                await widget.notifDoc.reference.update({'read': true});
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      chatId: chatId,
                      otherUserName: username,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
