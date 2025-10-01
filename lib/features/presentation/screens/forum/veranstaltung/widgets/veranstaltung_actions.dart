import 'package:flutter/material.dart';

class VeranstaltungActions extends StatelessWidget {
  final VoidCallback? onDelete;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;

  const VeranstaltungActions({
    super.key,
    this.onDelete,
    this.onCopy,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ElevatedButton.icon(
          onPressed: onShare,
          icon: const Icon(Icons.share),
          label: const Text("Als Status teilen"),
        ),
        ElevatedButton.icon(
          onPressed: onCopy,
          icon: const Icon(Icons.copy_all),
          label: const Text("Kopieren"),
        ),
        ElevatedButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
          label: const Text("Löschen"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
        ),
      ],
    );
  }
}
