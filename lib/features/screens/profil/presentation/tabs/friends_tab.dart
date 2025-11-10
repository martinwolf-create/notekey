// lib/features/screens/profil/friends_tab.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notekey_app/features/themes/colors.dart';

// <-- unser Status-Kachel-Widget mit Freundschafts-Logik
import 'package:notekey_app/features/screens/profil/widgets/user_search_tile.dart';

class FriendsTab extends StatefulWidget {
  const FriendsTab({super.key});

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.dunkelbraun),
              hintText: 'User suchen...',
              hintStyle: const TextStyle(color: AppColors.dunkelbraun),
              filled: true,
              fillColor: AppColors.rosebeige,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) => setState(() => searchQuery = value.trim()),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.goldbraun));
              }
              if (!snapshot.hasData) {
                return const Center(child: Text('Keine Daten.'));
              }

              final all = snapshot.data!.docs;

              // Clientseitiges Filtern (einfach & ausreichend für MVP)
              final filtered = all.where((doc) {
                if (doc.id == currentUserId)
                  return false; // mich selbst ausblenden
                final username =
                    (doc['username'] ?? '').toString().toLowerCase();
                return username.contains(searchQuery.toLowerCase());
              }).toList();

              if (filtered.isEmpty) {
                return const Center(
                  child: Text(
                    'Kein User gefunden.',
                    style: TextStyle(color: AppColors.dunkelbraun),
                  ),
                );
              }

              return ListView.builder(
                itemCount: filtered.length,
                padding: const EdgeInsets.only(bottom: 16),
                itemBuilder: (context, index) {
                  final d = filtered[index];
                  final data = d.data() as Map<String, dynamic>;
                  return UserSearchTile(
                    otherUserId: d.id,
                    username: data['username'] ?? 'Unbekannt',
                    city: data['city'] ?? '',
                    profileImageUrl: data['profileImageUrl'] ?? '',
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
