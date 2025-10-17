// lib/features/presentation/screens/forum/veranstaltung/widgets/veranstaltung_actions.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:notekey_app/features/screens/forum/data/veranstaltung_fs.dart';

class VeranstaltungActions extends StatelessWidget {
  final String fsId;
  final bool isOwner;

  const VeranstaltungActions({
    super.key,
    required this.fsId,
    required this.isOwner,
  });

  void _toast(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final fs = VeranstaltungenFs();

    return Row(
      children: [
        // Teilen (Platzhalter)
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => _toast(context, 'Teilen folgt …'),
        ),

        // Kopieren in eigenes Profil
        IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () async {
            final uid = FirebaseAuth.instance.currentUser?.uid;
            if (uid == null) {
              _toast(context, 'Nicht eingeloggt.');
              return;
            }
            try {
              final newId = await fs.copyToNewOwner(
                sourceId: fsId,
                newUid: uid, // <-- WICHTIG: Parametername heißt newUid
              );
              _toast(context, 'Kopiert ✔ ($newId)');
            } catch (e) {
              _toast(context, 'Fehler: $e');
            }
          },
        ),

        // Löschen nur für Besitzer
        if (isOwner)
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Löschen?'),
                  content: const Text('Diese Veranstaltung wirklich löschen?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Abbrechen'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Löschen'),
                    ),
                  ],
                ),
              );
              if (ok != true) return;

              try {
                await fs.delete(fsId);
                _toast(context, 'Gelöscht ✔');
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                _toast(context, 'Fehler: $e');
              }
            },
          ),
      ],
    );
  }
}
