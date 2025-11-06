import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notekey_app/features/themes/colors.dart';

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
              prefixIcon: const Icon(Icons.search),
              hintText: 'User suchen...',
              filled: true,
              fillColor: AppColors.rosebeige,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value.trim();
              });
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              final filtered = docs.where((doc) {
                if (doc.id == currentUserId) return false;
                final username =
                    (doc['username'] ?? '').toString().toLowerCase();
                return username.contains(searchQuery.toLowerCase());
              }).toList();

              if (filtered.isEmpty) {
                return const Center(child: Text('Kein User gefunden.'));
              }

              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final user = filtered[index].data() as Map<String, dynamic>;
                  final userId = filtered[index].id;
                  final username = user['username'] ?? 'Unbekannt';
                  final city = user['city'] ?? '';
                  final profileUrl = user['profileImageUrl'] ?? '';

                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.hellbeige,
                      backgroundImage:
                          profileUrl != '' ? NetworkImage(profileUrl) : null,
                      child: profileUrl == ''
                          ? const Icon(Icons.person,
                              color: AppColors.dunkelbraun)
                          : null,
                    ),
                    title: Text(username),
                    subtitle: Text(city),
                    onTap: () {
                      Navigator.pushNamed(context, '/profil_extern',
                          arguments: userId);
                    },
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
