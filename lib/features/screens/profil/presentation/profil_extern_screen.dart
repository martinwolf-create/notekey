import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/features/friends/friend_button.dart';

// Chat
import 'package:notekey_app/features/chat/chat_service.dart';
import 'package:notekey_app/features/chat/chat_screen.dart';

class ProfilExternScreen extends StatelessWidget {
  final String userId;

  const ProfilExternScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    // Eigene UID -> Schutz: externes Profil nicht anzeigen
    if (userId == currentUser?.uid) {
      return const Scaffold(
        body: Center(child: Text("Das ist dein eigenes Profil.")),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.hellbeige,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppColors.dunkelbraun,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.goldbraun));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("User nicht gefunden"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final username = (data['username'] ?? '—').toString();
          final city = (data['city'] ?? '').toString();
          final bio = (data['bio'] ?? '').toString();
          final age = (data['age']?.toString() ?? '').toString();
          final imageUrl = (data['profileImageUrl'] ?? '').toString();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                  backgroundColor: AppColors.rosebeige,
                  child: imageUrl.isEmpty
                      ? const Icon(Icons.person,
                          size: 40, color: AppColors.dunkelbraun)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  username,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dunkelbraun),
                ),
                const SizedBox(height: 4),
                if (city.isNotEmpty)
                  Text(city,
                      style: const TextStyle(
                          fontSize: 16, color: AppColors.dunkelbraun)),
                if (age.isNotEmpty) const SizedBox(height: 4),
                if (age.isNotEmpty)
                  Text('Alter: $age',
                      style: const TextStyle(
                          fontSize: 16, color: AppColors.dunkelbraun)),
                const SizedBox(height: 12),
                if (bio.isNotEmpty)
                  Text(
                    bio,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.dunkelbraun.withOpacity(0.85),
                    ),
                  ),
                const SizedBox(height: 24),

                // Buttons: Freundschaft + Chat
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FriendButton(otherUserId: userId),

                    // CHAT STARTEN
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          final chatId =
                              await ChatService().getOrCreateChatWith(userId);
                          if (!context.mounted) return;

                          final otherName =
                              username.isNotEmpty ? username : 'Chat';
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                chatId: chatId,
                                otherUserName: otherName,
                              ),
                            ),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Chat konnte nicht gestartet werden: $e')),
                          );
                        }
                      },
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text("Chat starten"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dunkelbraun,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
