import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notekey_app/features/themes/colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String query = "";

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hellbeige,
      appBar: AppBar(
        backgroundColor: AppColors.dunkelbraun,
        title: const Text(
          "Suche",
          style: TextStyle(color: AppColors.hellbeige),
        ),
        iconTheme: const IconThemeData(color: AppColors.hellbeige),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔍 Suchfeld
            TextField(
              controller: _searchCtrl,
              onChanged: (txt) => setState(() => query = txt.trim()),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.rosebeige,
                hintText: "Suche nach User, Event ...",
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.dunkelbraun),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🔍 Ergebnisse
            Expanded(
              child: query.isEmpty
                  ? const Center(
                      child: Text(
                        "Tippe etwas ein...",
                        style: TextStyle(color: Colors.brown),
                      ),
                    )
                  : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("users")
          .where("username", isGreaterThanOrEqualTo: query)
          .where("username", isLessThanOrEqualTo: "$query\uf8ff")
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snap.data!.docs;

        if (users.isEmpty) {
          return const Center(
            child: Text(
              "Nichts gefunden.",
              style: TextStyle(color: Colors.brown),
            ),
          );
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, i) {
            final u = users[i].data();
            final img = u['profilbild'] ?? "";
            final name = u['username'] ?? "Unbekannt";

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: img.isNotEmpty ? NetworkImage(img) : null,
                child: img.isEmpty ? const Icon(Icons.person) : null,
              ),
              title: Text(name),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  "/profil_extern",
                  arguments: users[i].id,
                );
              },
            );
          },
        );
      },
    );
  }
}
