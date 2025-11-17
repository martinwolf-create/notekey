import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/features/widgets/bottom_nav/bottom_navigation_bar.dart';
import 'package:notekey_app/features/chat/chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.hellbeige,
      appBar: AppBar(
        title: const Text("Chats"),
        centerTitle: true,
        backgroundColor: AppColors.dunkelbraun,
        foregroundColor: AppColors.hellbeige,
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Fehler: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.brown),
            );
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "Keine Chats vorhanden.",
                style: TextStyle(color: Colors.brown, fontSize: 16),
              ),
            );
          }

          // Manuell sortieren (da lastMessageTime optional)
          docs.sort((a, b) {
            final t1 = a.data()['lastMessageTime'];
            final t2 = b.data()['lastMessageTime'];
            if (t1 == null && t2 == null) return 0;
            if (t1 == null) return 1;
            if (t2 == null) return -1;
            return (t2 as Timestamp).compareTo(t1 as Timestamp);
          });

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 90),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final chat = docs[index].data();
              final chatId = docs[index].id;

              final participants = List<String>.from(chat['participants']);
              final otherUser =
                  participants.firstWhere((id) => id != currentUser.uid);

              final lastMessage = chat['lastMessage'] ?? "Keine Nachrichten";
              final time = chat['lastMessageTime'] as Timestamp?;

              return FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUser)
                    .get(),
                builder: (context, userSnap) {
                  if (!userSnap.hasData) {
                    return const ListTile(title: Text("Lade..."));
                  }

                  final u = userSnap.data!.data()!;
                  final username = u['username'] ?? "Unbekannt";
                  final profileImage = u['profileImageUrl'] ?? "";

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: profileImage.isNotEmpty
                          ? NetworkImage(profileImage)
                          : null,
                      child: profileImage.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(username),
                    subtitle: Text(lastMessage),
                    trailing: time == null
                        ? null
                        : Text(
                            "${time.toDate().hour.toString().padLeft(2, '0')}:${time.toDate().minute.toString().padLeft(2, '0')}"),
                    onTap: () {
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
