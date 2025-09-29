import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notekey_app/features/auth/firebase_auth_repository.dart';
import 'package:notekey_app/features/themes/colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = FirebaseAuthRepository();

    return Scaffold(
      backgroundColor: AppColors.hellbeige,
      appBar: AppBar(
        title: const Text('Mein Profil'),
        backgroundColor: AppColors.dunkelbraun,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: repo.streamMyUserDoc(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || !snap.data!.exists) {
            return const Center(child: Text('Kein Profil gefunden.'));
          }
          final data = snap.data!.data()!;
          final username = (data['username'] ?? '').toString();
          final city = (data['city'] ?? '').toString();
          final age = (data['age']?.toString() ?? '—');
          final photoUrl = (data['profileImageUrl'] ?? '').toString();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: AppColors.rosebeige,
                    backgroundImage:
                        photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                    child: photoUrl.isEmpty
                        ? const Icon(Icons.person,
                            size: 36, color: AppColors.dunkelbraun)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.rosebeige,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.goldbraun),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _row('Username', username),
                          _row('Stadt', city.isEmpty ? '—' : city),
                          _row('Alter', age),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
