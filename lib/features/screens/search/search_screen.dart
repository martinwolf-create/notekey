import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/features/widgets/bottom_nav/bottom_navigation_bar.dart';
import 'package:notekey_app/routes/app_routes.dart';

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
          style: TextStyle(
            color: AppColors.hellbeige,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),

      // ✔ BottomNavBar GANZ UNTEN
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),

      body: SafeArea(
        bottom: false, // ❗ Verhindert doppeltes Padding
        child: Column(
          children: [
            // 🔍 Suchfeld oben
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (txt) => setState(() => query = txt.trim()),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.rosebeige,
                  hintText: "Suche nach Usern...",
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.dunkelbraun),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // 🔥 Suchergebnis
            Expanded(
              child: query.isEmpty
                  ? const Center(
                      child: Text(
                        "Bitte etwas eingeben...",
                        style: TextStyle(
                          color: Colors.brown,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : _buildUserSearch(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSearch() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("users")
          .where("username", isGreaterThanOrEqualTo: query)
          .where("username", isLessThanOrEqualTo: "$query\uf8ff")
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.brown),
          );
        }

        final users = snap.data!.docs;

        if (users.isEmpty) {
          return const Center(
            child: Text(
              "Keine Treffer gefunden.",
              style: TextStyle(color: Colors.brown, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 20),
          itemCount: users.length,
          itemBuilder: (context, i) {
            final u = users[i].data();
            final img = u["profilbild"] ?? "";
            final name = u["username"] ?? "Unbekannt";

            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              leading: CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.goldbraun.withOpacity(0.2),
                backgroundImage: img.isNotEmpty ? NetworkImage(img) : null,
                child: img.isEmpty
                    ? const Icon(Icons.person, color: AppColors.dunkelbraun)
                    : null,
              ),
              title: Text(
                name,
                style: const TextStyle(
                  color: AppColors.dunkelbraun,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.profilExtern,
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
