import 'dart:io';
import 'package:flutter/material.dart';

class VeranstaltungImage extends StatelessWidget {
  final String? imagePath;

  const VeranstaltungImage({super.key, this.imagePath});

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return const SizedBox.shrink();
    }

    final isUrl =
        imagePath!.startsWith("http://") || imagePath!.startsWith("https://");

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: isUrl
          ? Image.network(
              imagePath!,
              fit: BoxFit.cover,
              height: 180,
              width: double.infinity,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
            )
          : Image.file(
              File(imagePath!),
              fit: BoxFit.cover,
              height: 180,
              width: double.infinity,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
            ),
    );
  }
}
