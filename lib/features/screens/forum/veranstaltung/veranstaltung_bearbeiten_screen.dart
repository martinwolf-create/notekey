import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/features/widgets/topbar/basic_topbar.dart';
import 'package:notekey_app/helpers/image_helper.dart';

import 'package:notekey_app/features/screens/forum/veranstaltung/provider/veranstaltung_provider.dart';
import 'package:provider/provider.dart';

class VeranstaltungBearbeitenScreen extends StatefulWidget {
  const VeranstaltungBearbeitenScreen({super.key, required this.eventId});
  final String eventId;

  @override
  State<VeranstaltungBearbeitenScreen> createState() =>
      _VeranstaltungBearbeitenScreenState();
}

class _VeranstaltungBearbeitenScreenState
    extends State<VeranstaltungBearbeitenScreen> {
  final _titleC = TextEditingController();
  final _infoC = TextEditingController();
  final _infoNode = FocusNode();

  DateTime? _date;
  String? _imagePath; // lokaler Pfad (neu gewählt)
  String? _imageUrl; // bestehende URL aus Firestore
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _titleC.dispose();
    _infoC.dispose();
    _infoNode.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final doc = await FirebaseFirestore.instance
        .collection('veranstaltung')
        .doc(widget.eventId)
        .get();

    if (!doc.exists) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event nicht gefunden.')),
        );
        Navigator.pop(context);
      }
      return;
    }

    final m = doc.data()!;
    _titleC.text = (m['title'] ?? '').toString();
    _infoC.text = (m['info'] ?? '').toString();
    _imageUrl = (m['imageUrl'] ?? '').toString();

    final whenMs = (m['date_epoch'] as int?) ?? 0;
    _date = whenMs > 0
        ? DateTime.fromMillisecondsSinceEpoch(whenMs).toLocal()
        : DateTime.now();

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _pickImage({required bool fromCamera}) async {
    final path = await pickAndPersistImage(fromCamera: fromCamera);
    if (path != null) setState(() => _imagePath = path);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    final p = context.read<VeranstaltungProvider>();
    String? imageUrl = _imageUrl;

    try {
      // Falls neues Bild gewählt → in festen Pfad dieses Events hochladen
      if (_imagePath != null && _imagePath!.isNotEmpty) {
        final raw = _imagePath!;
        final file =
            raw.startsWith('file:') ? File(Uri.parse(raw).path) : File(raw);

        final uid = FirebaseAuth.instance.currentUser!.uid;
        imageUrl = await p.uploadEventImage(
          file,
          ownerUid: uid,
          eventId: widget.eventId, // überschreibt/ersetzt für dieses Event
        );
      }

      final nowTs = FieldValue.serverTimestamp();
      final data = <String, dynamic>{
        'title':
            _titleC.text.trim().isEmpty ? 'Ohne Titel' : _titleC.text.trim(),
        'info': _infoC.text.trim().isEmpty ? null : _infoC.text.trim(),
        'imageUrl': imageUrl ?? '',
        'date_epoch': (_date ?? DateTime.now()).millisecondsSinceEpoch,
        'updatedAt': nowTs,
      };
      data.removeWhere((k, v) => v is String && v.trim().isEmpty);

      await FirebaseFirestore.instance
          .collection('veranstaltung')
          .doc(widget.eventId)
          .update(data);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Speichern fehlgeschlagen: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _date == null
        ? 'Kein Datum gewählt'
        : '${_date!.day.toString().padLeft(2, '0')}.'
            '${_date!.month.toString().padLeft(2, '0')}.'
            '${_date!.year}';

    return Scaffold(
      backgroundColor: AppColors.hellbeige,
      appBar: const BasicTopBar(
        title: 'Veranstaltung bearbeiten',
        showBack: true,
        showMenu: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                      child: Builder(
                        builder: (_) {
                          // Priorität: neues lokales Bild > bestehende URL > Platzhalter
                          if (_imagePath != null) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                File(_imagePath!),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            );
                          }
                          if ((_imageUrl ?? '').isNotEmpty) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                _imageUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            );
                          }
                          return const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_a_photo_outlined, size: 30),
                                SizedBox(height: 8),
                                Text('Tippen: Galerie · Long: Kamera'),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _titleC,
                    decoration: const InputDecoration(
                      labelText: 'Titel',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _infoC,
                    focusNode: _infoNode,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Info',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: Text(dateText)),
                      ElevatedButton(
                        onPressed: _pickDate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.goldbraun,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Datum wählen'),
                      ),
                    ],
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
