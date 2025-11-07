import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/features/friends/friend_button.dart';

class ProfilExternScreen extends StatelessWidget {
  final String userId;

  const ProfilExternScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (userId == currentUser?.uid) {
      // Falls jemand versucht, sein eigenes Profil extern zu öffnen
      return const Scaffold(
        body: Center(
          child: Text("Das ist dein eigenes Profil."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppColors.dunkelbraun,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;

          if (data == null) {
            return const Center(child: Text("User nicht gefunden"));
          }

          final username = data['username'] ?? '—';
          final city = data['city'] ?? '';
          final bio = data['bio'] ?? '';
          final age = data['age']?.toString() ?? '';
          final imageUrl = data['profileImageUrl'] ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      imageUrl != '' ? NetworkImage(imageUrl) : null,
                  backgroundColor: AppColors.hellbeige,
                  child: imageUrl == ''
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  username,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(city, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 4),
                Text('Alter: $age', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 12),
                if (bio.isNotEmpty)
                  Text(
                    bio,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.dunkelbraun.withOpacity(0.8),
                    ),
                  ),
                const SizedBox(height: 24),

                // ✅ Echte Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FriendButton(otherUserId: userId), // ← Dein echter Button
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Später mit Chat-Funktion ersetzen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Chat starten folgt bald.")),
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text("Chat starten"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dunkelbraun,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
