// lib/features/presentation/screens/forum/suchfind/find/find_edit_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/features/widgets/topbar/basic_topbar.dart';

import 'package:notekey_app/features/presentation/screens/forum/suchfind/data/suchfind_model.dart';
import 'package:notekey_app/features/presentation/screens/forum/suchfind/provider/suchfind_provider.dart';
import 'package:notekey_app/helpers/image_helper.dart'; // pickAndPersistImage

class FindEditScreen extends StatefulWidget {
  final Suchfind? initial;
  const FindEditScreen({super.key, this.initial});

  @override
  State<FindEditScreen> createState() => _FindEditScreenState();
}

class _FindEditScreenState extends State<FindEditScreen> {
  final _title = TextEditingController();
  final _info = TextEditingController();
  final _infoNode = FocusNode();

  String? _imagePath; // lokaler Pfad ODER bereits gespeicherte URL
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final it = widget.initial;
    if (it != null) {
      _title.text = it.title;
      _info.text = it.description ?? '';
      _imagePath = it.imageUrl; // kann http-URL sein
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _info.dispose();
    _infoNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage({required bool fromCamera}) async {
    final p = await pickAndPersistImage(fromCamera: fromCamera);
    if (!mounted) return;
    if (p != null) setState(() => _imagePath = p);
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    // kleines Feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 2),
          backgroundColor: AppColors.dunkelbraun,
          content: Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
              SizedBox(width: 10),
              Text('Wird gespeichert...'),
            ],
          ),
        ),
      );
    }

    try {
      final prov = context.read<SuchfindProvider>();

      // 1) optional Bild hochladen (nur wenn lokaler Pfad, nicht bei http-URL)
      String? imageUrl = widget.initial?.imageUrl;
      if (_imagePath != null &&
          _imagePath!.isNotEmpty &&
          !_imagePath!.startsWith('http')) {
        imageUrl = await prov.uploadImage(
          File(_imagePath!),
          kind: MarketKind.find, // Provider kann das ignorieren oder nutzen
        );
      }

      // 2) Datensatz für Firestore
      final s = Suchfind(
        id: widget.initial?.id, // null = create
        title: _title.text.trim().isEmpty ? 'Ohne Titel' : _title.text.trim(),
        description: _info.text.trim().isEmpty ? null : _info.text.trim(),
        imageUrl: imageUrl,
        createdAt: widget.initial?.createdAt, // bleibt bei Update erhalten
      );

      // 3) speichern (create vs update)
      if (widget.initial?.id == null) {
        await prov.add(s, kind: MarketKind.find);
      } else {
        await prov.update(s);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Fehler: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final img = _imagePath;

    return Scaffold(
      backgroundColor: AppColors.hellbeige,
      appBar: const BasicTopBar(
        title: 'Finde – Eintrag',
        showBack: true,
        showMenu: false,
      ),
      floatingActionButton: GestureDetector(
        onLongPress: () => _pickImage(fromCamera: true),
        child: FloatingActionButton(
          backgroundColor: AppColors.dunkelbraun,
          foregroundColor: AppColors.hellbeige,
          onPressed: () => _pickImage(fromCamera: false),
          child: const Icon(Icons.add_a_photo_outlined),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () => _pickImage(fromCamera: false),
              onLongPress: () => _pickImage(fromCamera: true),
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.hellbeige,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.goldbraun),
                ),
                child: img == null
                    ? const Center(child: Text('Bild auswählen'))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: img.startsWith('http')
                            ? Image.network(
                                img,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image),
                              )
                            : Image.file(
                                File(img),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image),
                              ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Titel',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _info,
              focusNode: _infoNode,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Info',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dunkelbraun,
                foregroundColor: AppColors.hellbeige,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Speichern'),
            ),
          ],
        ),
      ),
    );
  }
}
