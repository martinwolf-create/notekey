import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendsTab extends StatefulWidget {
  const FriendsTab({super.key});

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔍 Suchfeld
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'User suchen...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                query = value.trim();
              });
            },
          ),
        ),

        // 👤 Userliste
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: query.isEmpty
                ? FirebaseFirestore.instance
                    .collection('users')
                    .orderBy('timestamp', descending: true)
                    .limit(10)
                    .snapshots()
                : FirebaseFirestore.instance
                    .collection('users')
                    .where('username',
                        isGreaterThanOrEqualTo: query,
                        isLessThanOrEqualTo: '$query\uf8ff')
                    .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return const Center(child: Text('Kein User gefunden.'));
              }

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final user = docs[index].data() as Map<String, dynamic>;
                  final userId = docs[index].id;

                  return ListTile(
                    leading: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/profil_extern',
                          arguments: userId,
                        );
                      },
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(user['profilbild']),
                      ),
                    ),
                    title: Text(user['username'] ?? 'Unbekannt'),
                    subtitle: Text(user['stadt'] ?? ''),
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
