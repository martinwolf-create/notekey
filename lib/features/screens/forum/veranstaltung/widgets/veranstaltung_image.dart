import 'dart:io';
import 'package:flutter/material.dart';

class VeranstaltungImage extends StatelessWidget {
  final String imagePath; // URL oder lokaler Pfad

  const VeranstaltungImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final isUrl =
        imagePath.startsWith('http://') || imagePath.startsWith('https://');

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: isUrl
          ? Image.network(
              imagePath,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
            )
          : Image.file(
              File(imagePath),
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
            ),
    );
  }
}
