// lib/features/presentation/screens/forum/veranstaltung/veranstaltung_detail_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:notekey_app/features/screens/forum/data/forum_item.dart';
import 'package:notekey_app/features/screens/forum/data/veranstaltung_fs.dart';

import 'widgets/veranstaltung_actions.dart';
import 'widgets/veranstaltung_image.dart'; // falls du dieses Widget nutzt

class VeranstaltungDetailScreen extends StatelessWidget {
  final String fsId; // Dokument-ID aus Firestore
  final ForumItem? initial; // optional: bereits geladener Datensatz

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
            children: <Widget>[
              if (it.imagePath != null && it.imagePath!.isNotEmpty) ...<Widget>[
                // Wenn du dein eigenes Widget hast:
                VeranstaltungImage(imagePath: it.imagePath!),
                // Alternativ direkt anzeigen:
                // _ImageBox(imagePath: it.imagePath!),
                const SizedBox(height: 12),
              ],
              Text(
                it.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(it.info),
              const SizedBox(height: 16),
              VeranstaltungActions(
                fsId: it.fsId!,
                isOwner: isOwner,
              ),
              const SizedBox(height: 24),
              // Hier kannst du später Kommentare anhängen
              // VeranstaltungComments(fsId: it.fsId!),
            ],
          );
        },
      ),
    );
  }
}

// Nur falls du KEIN eigenes Bild-Widget verwendest, kannst du das hier nutzen.
// Sonst diesen Block weglassen.
class _ImageBox extends StatelessWidget {
  final String imagePath;
  const _ImageBox({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final p = imagePath;
    final isUrl = p.startsWith('http://') || p.startsWith('https://');
    final ImageProvider provider = isUrl
        ? NetworkImage(p)
        : (p.startsWith('file:')
            ? FileImage(File(Uri.parse(p).path))
            : FileImage(File(p))) as ImageProvider;

    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: provider, fit: BoxFit.cover),
      ),
    );
  }
}
