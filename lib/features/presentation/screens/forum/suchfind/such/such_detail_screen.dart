import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/suchfind_model.dart';
import '../provider/suchfind_provider.dart';
import '../data/suchfind_repository.dart';

class SuchDetailScreen extends StatelessWidget {
  final String id; // Firestore-Doc-ID
  final Suchfind? initial; // optional: bereits geladener Eintrag

  const SuchDetailScreen({
    super.key,
    required this.id,
    this.initial,
  });

  @override
  Widget build(BuildContext context) {
    // Wir nehmen das gleiche Repo wie im Provider (kein neuer Provider nötig)
    final repo = SuchfindRepository();

    return Scaffold(
      appBar: AppBar(title: const Text('Such – Detail')),
      body: StreamBuilder<Suchfind?>(
        stream: repo.watchById(id),
        initialData: initial,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final it = snap.data;
          if (it == null) {
            return const Center(child: Text('Eintrag nicht gefunden.'));
          }

          final img = it.imageUrl;
          final hasImg = img != null && img.isNotEmpty;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (hasImg)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: (img!.startsWith('http'))
                      ? Image.network(img,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover)
                      : Image.file(File(img),
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover),
                ),
              const SizedBox(height: 12),
              Text(
                it.title.isEmpty ? 'Ohne Titel' : it.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              if ((it.description ?? '').isNotEmpty) Text(it.description!),
              const SizedBox(height: 16),

              // Beispiel: Löschen (nur wenn ID vorhanden)
              if (it.id != null)
                FilledButton.tonal(
                  onPressed: () async {
                    await context.read<SuchfindProvider>().delete(it.id!);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Löschen'),
                ),
            ],
          );
        },
      ),
    );
  }
}
