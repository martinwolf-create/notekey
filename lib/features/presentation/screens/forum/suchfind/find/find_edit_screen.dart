import 'dart:io';
import 'package:flutter/material.dart';
import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/features/widgets/topbar/basic_topbar.dart';
import 'package:notekey_app/features/presentation/screens/forum/create_entry_page.dart';
import 'package:notekey_app/features/presentation/screens/forum/data/forum_item.dart';
import 'package:notekey_app/features/presentation/screens/forum/data/suchfind_fs.dart';
import 'package:notekey_app/helpers/image_helper.dart';

const _currencies = ['EUR', 'USD', 'GBP', 'JPY', 'CHF'];

class FindEditScreen extends StatefulWidget {
  final ForumItem? initial;
  const FindEditScreen({super.key, this.initial});

  @override
  State<FindEditScreen> createState() => _FindEditScreenState();
}

class _FindEditScreenState extends State<FindEditScreen> {
  final _sf = SuchFindFs();

  final _titleCtl = TextEditingController();
  final _infoCtl = TextEditingController();
  final _priceCtl = TextEditingController();
  final _infoNode = FocusNode();

  String _currency = 'EUR';
  String? _imagePath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final it = widget.initial;
    if (it != null) {
      _titleCtl.text = it.title;
      _infoCtl.text = it.info;
      _imagePath = it.imagePath;
      _priceCtl.text = it.priceCents != null
          ? (it.priceCents! / 100).toStringAsFixed(2)
          : '';
      _currency = it.currency ?? 'EUR';
    }
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _infoCtl.dispose();
    _priceCtl.dispose();
    _infoNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage({required bool fromCamera}) async {
    final p = await pickAndPersistImage(fromCamera: fromCamera);
    if (p != null) setState(() => _imagePath = p);
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    int? cents;
    final t = _priceCtl.text.trim().replaceAll(',', '.');
    if (t.isNotEmpty) {
      final v = double.tryParse(t);
      if (v != null) cents = (v * 100).round();
    }

    final base = ForumItem(
      fsId: widget.initial?.fsId,
      type: ForumItemType.market,
      title:
          _titleCtl.text.trim().isEmpty ? 'Ohne Titel' : _titleCtl.text.trim(),
      info: _infoCtl.text.trim(),
      imagePath: _imagePath,
      date: null,
      priceCents: cents,
      currency: _currency,
    );

    if (widget.initial?.fsId == null) {
      await _sf.add(base, kind: MarketKind.find); //NEU: kind mitgeben
    } else {
      await _sf.update(widget.initial!.fsId!, base);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final img = _imagePath;
    return Scaffold(
      backgroundColor: AppColors.hellbeige,
      appBar: const BasicTopBar(
        title: 'Angebot/Gesuch',
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
                child: img == null
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
              controller: _titleCtl,
              decoration: const InputDecoration(
                labelText: 'Titel',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _infoCtl,
              focusNode: _infoNode,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Beschreibung',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceCtl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Preis',
                      hintText: 'z. B. 49.90',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _currency,
                  items: _currencies
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _currency = v ?? 'EUR'),
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
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Speichern'),
            ),
          ],
        ),
      ),
    );
  }
}
