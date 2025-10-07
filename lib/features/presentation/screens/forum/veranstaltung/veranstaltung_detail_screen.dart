// lib/features/presentation/screens/forum/veranstaltung/veranstaltung_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:notekey_app/features/presentation/screens/forum/data/forum_item.dart';
import 'package:notekey_app/features/presentation/screens/forum/data/veranstaltung_fs.dart';

import 'widgets/veranstaltung_image.dart';
import 'widgets/veranstaltung_actions.dart';

class VeranstaltungDetailScreen extends StatelessWidget {
  final String fsId; // Dokument-ID aus Firestore
  final ForumItem? initial; // optional: schon geladener Datensatz

  const VeranstaltungDetailScreen({
    super.key,
    required this.fsId,
    this.initial,
  });

  @override
  Widget build(BuildContext context) {
    final fs = VeranstaltungenFs();

    return Scaffold(
      appBar: AppBar(title: const Text('Veranstaltung')),
      body: StreamBuilder<ForumItem?>(
        stream: fs.watchById(fsId), // live aus Firestore
        initialData: initial,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data == null) {
            return const Center(child: Text('Veranstaltung nicht gefunden.'));
          }

          final it = snap.data!;
          final currentUid = FirebaseAuth.instance.currentUser?.uid;
          final isOwner = (currentUid != null && currentUid == it.ownerUid);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (it.imagePath != null && it.imagePath!.isNotEmpty) ...[
                VeranstaltungImage(imagePath: it.imagePath!),
                const SizedBox(height: 12),
              ],

              Text(
                it.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),

              Text(it.info),
              const SizedBox(height: 16),

              // Aktionen: Löschen, Kopieren, Teilen (Owner-bezogen)
              VeranstaltungActions(
                fsId: it.fsId!,
                isOwner: isOwner,
              ),
              const SizedBox(height: 24),

              // TODO: Kommentare-Widget hier einhängen
              // VeranstaltungComments(fsId: it.fsId!),
            ],
          );
        },
      ),
    );
  }
}
