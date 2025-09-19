import 'dart:io';
import 'package:flutter/material.dart';
import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/features/widgets/topbar/basic_topbar.dart';
import 'package:notekey_app/features/presentation/screens/forum/data/forum_item.dart';
import 'package:notekey_app/features/presentation/screens/forum/data/suchfind_db.dart';
import 'package:notekey_app/helpers/image_helper.dart';

class SuchEditScreen extends StatefulWidget {
  final ForumItem? initial;
  const SuchEditScreen({super.key, this.initial});

  @override
  State<SuchEditScreen> createState() => _SuchEditScreenState();
}

class _SuchEditScreenState extends State<SuchEditScreen> {
  final _db = SuchFindDb();
  final _title = TextEditingController();
  final _info = TextEditingController();
  String? _imagePath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final it = widget.initial;
    if (it != null) {
      _title.text = it.title;
      _info.text = it.info;
      _imagePath = it.imagePath;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _info.dispose();
    super.dispose();
  }

  Future<void> _pickImage({bool fromCamera = false}) async {
    final p = await pickAndPersistImage(fromCamera: fromCamera);
    if (p != null) setState(() => _imagePath = p);
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        backgroundColor: AppColors.dunkelbraun,
        content: Row(children: const [
          SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white)),
          SizedBox(width: 12),
          Text('Speichern…'),
        ]),
      ),
    );

    final item = ForumItem(
      id: widget.initial?.id,
      type: ForumItemType.market,
      title: _title.text.trim().isEmpty ? 'Ohne Titel' : _title.text.trim(),
      info: _info.text.trim(),
      imagePath: _imagePath,
      date: null,
      priceCents: null, // Such = kein Preis
      currency: null,
    );

    if (widget.initial == null) {
      await _db.insert(item);
    } else {
      await _db.update(item);
    }

    if (!mounted) return;
    await Future.delayed(const Duration(seconds: 3));
    Navigator.pop(context, true);
  }

  void _openSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.hellbeige,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: Icon(Icons.photo_library_outlined,
                color: AppColors.dunkelbraun),
            title: const Text('Foto aus Galerie wählen'),
            onTap: () {
              Navigator.pop(context);
              _pickImage();
            },
          ),
          ListTile(
            leading:
                Icon(Icons.photo_camera_outlined, color: AppColors.dunkelbraun),
            title: const Text('Foto mit Kamera aufnehmen'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(fromCamera: true);
            },
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hellbeige,
      appBar: const BasicTopBar(
          title: 'Such – Eintrag', showBack: true, showMenu: false),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.dunkelbraun,
        foregroundColor: AppColors.hellbeige,
        onPressed: _openSheet,
        child: const Icon(Icons.add_a_photo_outlined),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Bild (wie Veranstaltungen)
          GestureDetector(
            onTap: _openSheet,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.hellbeige,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.goldbraun.withOpacity(.5)),
              ),
              child: _imagePath == null
                  ? const Center(child: Text('Bild auswählen'))
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

          // Titel
          TextField(
            controller: _title,
            decoration: const InputDecoration(
                labelText: 'Titel', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),

          // Info
          TextField(
            controller: _info,
            maxLines: 4,
            decoration: const InputDecoration(
                labelText: 'Info', border: OutlineInputBorder()),
          ),

          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldbraun,
              foregroundColor: AppColors.hellbeige,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Speichern'),
          ),
        ]),
      ),
    );
  }
}
