import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/features/widgets/topbar/basic_topbar.dart';
import 'package:notekey_app/features/presentation/screens/forum/data/forum_item.dart';
import 'package:notekey_app/helpers/image_helper.dart';
import 'package:notekey_app/features/presentation/screens/forum/veranstaltung/veranstaltung_list_screen.dart'
    show CreatePreset;
import 'package:notekey_app/features/presentation/screens/forum/data/veranstaltung_fs.dart';
//import 'package:notekey_app/features/presentation/screens/forum/create_entry_page.dart';

class VeranstaltungenScreen extends StatefulWidget {
  final CreatePreset? preset;
  const VeranstaltungenScreen({super.key, this.preset});

  @override
  State<VeranstaltungenScreen> createState() => _VeranstaltungenScreenState();
}

class _VeranstaltungenScreenState extends State<VeranstaltungenScreen> {
  final _titleController = TextEditingController();
  final _infoController = TextEditingController();
  final _infoNode = FocusNode();

  DateTime? _date;
  String? _imagePath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      switch (widget.preset) {
        case CreatePreset.camera:
          final p = await pickAndPersistImage(fromCamera: true);
          if (!mounted) return;
          if (p != null) setState(() => _imagePath = p);
          break;
        case CreatePreset.gallery:
          final p = await pickAndPersistImage(fromCamera: false);
          if (!mounted) return;
          if (p != null) setState(() => _imagePath = p);
          break;
        case CreatePreset.info:
          _infoNode.requestFocus();
          break;
        case CreatePreset.date:
          _pickDate();
          break;
        default:
          break;
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _infoController.dispose();
    _infoNode.dispose();
    super.dispose();
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
    if (_isSaving) return;
    setState(() => _isSaving = true);

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

    //try {
    final draft = ForumItem(
      type: ForumItemType.event,
      title: _titleController.text.trim().isEmpty
          ? 'Ohne Titel'
          : _titleController.text.trim(),
      info: _infoController.text.trim(),
      imagePath: null,
      date: _date,
    );

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final file = (_imagePath != null) ? File(_imagePath!) : null;
    print(_imagePath);
    // Hier ist die Zeile, die jetzt wirklich passt!
    final saved = await VeranstaltungenFs().addWithUpload(
      draft: draft,
      ownerUid: uid, //  das ist der korrekte Parametername
      localImage: file,
    );

    if (!mounted) return;
    Navigator.pop(context, saved);
    /*} catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }*/
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _date == null
        ? 'Kein Datum gewählt'
        : '${_date!.day.toString().padLeft(2, '0')}.${_date!.month.toString().padLeft(2, '0')}.${_date!.year}';

    return Scaffold(
      backgroundColor: AppColors.hellbeige,
      appBar: const BasicTopBar(
        title: 'Veranstaltung erstellen',
        showBack: true,
        showMenu: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
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
                child: _imagePath == null
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_a_photo_outlined, size: 32),
                            SizedBox(height: 8),
                            Text('Tippen: Galerie  ·  Long-Press: Kamera'),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(_imagePath!),
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
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titel',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
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
              onPressed: _isSaving ? null : _save,
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
  }
}
