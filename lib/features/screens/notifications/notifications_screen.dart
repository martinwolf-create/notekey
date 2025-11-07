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
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _respondToRequest(
      String requestId, String fromUserId, bool accept) async {
    final firestore = FirebaseFirestore.instance;

    if (accept) {
      await firestore.collection('friends').add({
        'users': [currentUserId, fromUserId],
        'since': FieldValue.serverTimestamp(),
      });
    }

    await firestore.collection('friend_requests').doc(requestId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hellbeige,
      appBar: AppBar(
        backgroundColor: AppColors.dunkelbraun,
        iconTheme: const IconThemeData(color: AppColors.hellbeige),
        title: const Text(
          '📬 Freundschaftsanfragen',
          style: TextStyle(
            color: AppColors.hellbeige,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('friend_requests')
            .where('toUserId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.dunkelbraun));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Keine neuen Anfragen.',
                style: TextStyle(color: AppColors.dunkelbraun, fontSize: 16),
              ),
            );
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final fromUserId = request['fromUserId'];

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.goldbraun,
                    child: Icon(Icons.person, color: AppColors.hellbeige),
                  ),
                  title: Text(
                    'Anfrage von: $fromUserId',
                    style: const TextStyle(color: AppColors.dunkelbraun),
                  ),
                  subtitle: Row(
                    children: [
                      TextButton(
                        onPressed: () =>
                            _respondToRequest(request.id, fromUserId, true),
                        child: const Text('Annehmen'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () =>
                            _respondToRequest(request.id, fromUserId, false),
                        child: const Text('Ablehnen'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
