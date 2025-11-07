import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notekey_app/features/themes/colors.dart';

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
    if (!doc.exists) {
      return {'username': 'Unbekannt', 'profileImageUrl': ''};
    }
    final d = doc.data()!;
    return {
      'username': (d['username'] ?? 'Unbekannt') as String,
      'profileImageUrl': (d['profileImageUrl'] ?? '') as String,
    };
  }

  /// accept == true  -> status: accepted + friends/{uidA_uidB}
  /// accept == false -> status: rejected
  Future<void> _respondToRequest(
      String requestId, String fromUserId, bool accept) async {
    final db = FirebaseFirestore.instance;
    final batch = db.batch();

    final reqRef = db.collection('friend_requests').doc(requestId);

    if (accept) {
      // Eindeutige Friend-Doc-ID: sortierte UIDs, damit nur EIN Dokument existiert
      final ids = [currentUserId, fromUserId]..sort();
      final friendDocId = '${ids[0]}_${ids[1]}';
      final friendRef = db.collection('friends').doc(friendDocId);

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
    // StreamBuilder aktualisiert sich automatisch; kein setState nötig.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hellbeige,
      appBar: AppBar(
        backgroundColor: AppColors.dunkelbraun,
        foregroundColor: AppColors.hellbeige,
        title: const Text('📬 Freundschaftsanfragen'),
        automaticallyImplyLeading: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('friend_requests')
            .where('receiverId', isEqualTo: currentUserId)
            .where('status', isEqualTo: 'pending') // wichtig!
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.goldbraun));
          }

          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'Keine neuen Anfragen',
                style: TextStyle(color: AppColors.dunkelbraun, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final request = docs[i];
              final requestId = request.id;
              final fromUserId = request['senderId'] as String;

              return FutureBuilder<Map<String, dynamic>>(
                future: _getUserInfo(fromUserId),
                builder: (context, userSnap) {
                  final username = userSnap.data?['username'] ?? 'Lädt...';
                  final profileImageUrl =
                      userSnap.data?['profileImageUrl'] ?? '';

                  return Card(
                    color: AppColors.rosebeige, // leichtes Panel
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.goldbraun,
                        backgroundImage: profileImageUrl.isNotEmpty
                            ? NetworkImage(profileImageUrl)
                            : null,
                        child: profileImageUrl.isEmpty
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                      title: Text(
                        'Anfrage von: $username',
                        style: const TextStyle(
                          color: AppColors.dunkelbraun,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          TextButton(
                            onPressed: () =>
                                _respondToRequest(requestId, fromUserId, true),
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  AppColors.goldbraun, // dein Braun-Ton
                              textStyle:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            child: const Text('Annehmen'),
                          ),
                          const SizedBox(width: 16),
                          TextButton(
                            onPressed: () =>
                                _respondToRequest(requestId, fromUserId, false),
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  AppColors.dunkelbraun.withOpacity(0.85),
                              textStyle:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            child: const Text('Ablehnen'),
                          ),
                        ],
                      ),
                      onTap: () {
                        // Optional: zum externen Profil springen
                        Navigator.pushNamed(context, '/profilExtern',
                            arguments: fromUserId);
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
