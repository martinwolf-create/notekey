import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/features/widgets/topbar/basic_topbar.dart';
import 'package:notekey_app/helpers/image_helper.dart';

import 'provider/veranstaltung_provider.dart';

class VeranstaltungBearbeitenScreen extends StatefulWidget {
  final String veranstaltungId; // <-- bestehendes Dokument in "veranstaltung"

  const VeranstaltungBearbeitenScreen({
    super.key,
    required this.veranstaltungId,
  });

  @override
  State<VeranstaltungBearbeitenScreen> createState() =>
      _VeranstaltungBearbeitenScreenState();
}

class _VeranstaltungBearbeitenScreenState
    extends State<VeranstaltungBearbeitenScreen> {
  final _titleController = TextEditingController();
  final _infoController = TextEditingController();
  final _infoNode = FocusNode();

  DateTime? _date;
  String? _imagePath; // LOKAL neu gewähltes Bild (wie im CreateScreen)
  String? _imageUrlFirestore; // altes Bild aus Firestore
  String? _uidOwner; // damit wir uploadEventImage korrekt aufrufen können

  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _infoController.dispose();
    _infoNode.dispose();
    super.dispose();
  }

  // Bild auswählen (Galerie/Kamera) -> exakt wie bei dir
  Future<void> _pickImage({required bool fromCamera}) async {
    final path = await pickAndPersistImage(fromCamera: fromCamera);
    if (path != null) {
      setState(() {
        _imagePath = path;
      });
    }
  }

  // Datum wählen -> exakt wie bei dir
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  // 1. Laden der bestehenden Daten aus Firestore und in die Felder kippen
  Future<void> _loadExisting() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('veranstaltung')
          .doc(widget.veranstaltungId)
          .get();

      if (!snap.exists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veranstaltung nicht gefunden.')),
        );
        Navigator.pop(context);
        return;
      }

      final data = snap.data() as Map<String, dynamic>;

      // deine Felder aus CreateScreen-Logik:
      // 'uid', 'title', 'info', 'imageUrl', 'date_epoch', 'createdAt', 'updatedAt'
      final loadedUid = data['uid'] as String?;
      final loadedTitle = (data['title'] ?? '') as String;
      final loadedInfo = (data['info'] ?? '') as String;
      final loadedImageUrl = (data['imageUrl'] ?? '') as String;
      final loadedDateEpoch = data['date_epoch'] as int?;
      // createdAt lassen wir später in Ruhe, updatedAt setzen wir neu

      setState(() {
        _uidOwner = loadedUid;
        _titleController.text = loadedTitle;
        _infoController.text = loadedInfo;
        _imageUrlFirestore = loadedImageUrl.isEmpty ? null : loadedImageUrl;
        _date = loadedDateEpoch != null
            ? DateTime.fromMillisecondsSinceEpoch(loadedDateEpoch)
            : DateTime.now();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Laden: $e')),
      );
      Navigator.pop(context);
    }
  }

  // 2. Speichern (Update bestehendes Doc) -> NICHT add(), sondern update()
  Future<void> _save(BuildContext context) async {
    if (_isSaving || _isLoading) return;

    setState(() {
      _isSaving = true;
    });

    final p = context.read<VeranstaltungProvider>();

    // Gleiche Snackbar wie in Create
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 3),
        backgroundColor: AppColors.dunkelbraun,
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 12),
            Text('Speichern…'),
          ],
        ),
      ),
    );

    try {
      // uid vom Owner, falls null -> currentUser als Fallback
      final uid = _uidOwner ?? FirebaseAuth.instance.currentUser!.uid;

      // Bild-Upload:
      // Wenn der User ein neues Bild gewählt hat (_imagePath), laden wir hoch
      // über GENAU deine Provider-Methode uploadEventImage.
      // Sonst behalten wir die alte URL (_imageUrlFirestore).
      String? finalImageUrl = _imageUrlFirestore;

      if (_imagePath != null && _imagePath!.isNotEmpty) {
        final raw = _imagePath!;
        final file =
            raw.startsWith('file:') ? File(Uri.parse(raw).path) : File(raw);

        finalImageUrl = await p.uploadEventImage(
          file,
          ownerUid: uid,
          eventId: widget.veranstaltungId,
        );
      }

      final nowTs = FieldValue.serverTimestamp();

      // Map exakt wie bei CreateScreen, ABER:
      // - 'createdAt' NICHT überschreiben!
      //   Wir lassen createdAt einfach so, wie es ist.
      //   Firestore update lässt Felder aus, die wir nicht setzen.
      //
      // - 'updatedAt' setzen wir neu.
      //
      // - 'date_epoch' aktualisieren wir mit _date.
      //
      // - 'info' und 'title' sind exakt wie bei dir.
      //
      // - leere Strings nachher rauswerfen wie im CreateScreen.

      final updateData = <String, dynamic>{
        'uid': uid,
        'title': _titleController.text.trim().isEmpty
            ? 'Ohne Titel'
            : _titleController.text.trim(),
        'info': _infoController.text.trim().isEmpty
            ? null
            : _infoController.text.trim(),
        'imageUrl': finalImageUrl ?? '',
        'date_epoch': (_date ?? DateTime.now()).millisecondsSinceEpoch,
        'updatedAt': nowTs,
      };

      // leere Strings killen (genau wie in deinem CreateScreen)
      updateData.removeWhere((k, v) => v is String && v.trim().isEmpty);

      // Firestore Update statt Add
      await FirebaseFirestore.instance
          .collection('veranstaltung')
          .doc(widget.veranstaltungId)
          .update(updateData);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Speichern: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _date == null
        ? 'Kein Datum gewählt'
        : '${_date!.day.toString().padLeft(2, '0')}.'
            '${_date!.month.toString().padLeft(2, '0')}.'
            '${_date!.year}';

    return ChangeNotifierProvider(
      create: (_) => VeranstaltungProvider(),
      child: Consumer<VeranstaltungProvider>(
        builder: (context, p, _) {
          // Gleiche Optik wie dein CreateScreen
          return Scaffold(
            backgroundColor: AppColors.hellbeige,
            appBar: const BasicTopBar(
              title: 'Veranstaltung bearbeiten',
              showBack: true,
              showMenu: false,
            ),
            body: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.dunkelbraun,
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // BILD-BLOCK -> IDENTISCHER STYLE
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
                                // Reihenfolge:
                                // 1. wenn neues Bild gewählt (_imagePath)
                                // 2. sonst vorhandene URL (_imageUrlFirestore)
                                // 3. sonst Placeholder wie dein CreateScreen
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
                                } else if (_imageUrlFirestore != null &&
                                    _imageUrlFirestore!.isNotEmpty) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      _imageUrlFirestore!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  );
                                } else {
                                  return const Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.add_a_photo_outlined,
                                            size: 30),
                                        SizedBox(height: 8),
                                        Text('Tippen: Galerie · Long: Kamera'),
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // TITEL -> IDENTISCHER STYLE
                        TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Titel',
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // INFO -> IDENTISCHER STYLE
                        TextField(
                          controller: _infoController,
                          focusNode: _infoNode,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Info',
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // DATUMSBLOCK -> IDENTISCHER STYLE
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

                        // SPEICHERN BUTTON -> IDENTISCHER STYLE
                        ElevatedButton(
                          onPressed: _isSaving ? null : () => _save(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.dunkelbraun,
                            foregroundColor: AppColors.hellbeige,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isSaving
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
        },
      ),
    );
  }
}
