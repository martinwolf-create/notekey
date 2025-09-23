import 'dart:io';
import 'package:flutter/material.dart';
import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/features/widgets/topbar/basic_topbar.dart';
import 'package:notekey_app/features/presentation/screens/forum/data/forum_item.dart';
import 'package:notekey_app/features/presentation/screens/forum/veranstaltung/veranstaltungen_edit_screen.dart';
import 'package:notekey_app/features/presentation/screens/forum/veranstaltung/veranstaltungen_list_screen.dart'
    show CreatePreset;
import 'package:notekey_app/features/presentation/screens/forum/data/veranstaltungen_fs.dart';

enum CreatePreset { camera, gallery, info, date }

class VeranstaltungenListScreen extends StatefulWidget {
  const VeranstaltungenListScreen({super.key});

  @override
  State<VeranstaltungenListScreen> createState() =>
      _VeranstaltungenListScreenState();
}

class _VeranstaltungenListScreenState extends State<VeranstaltungenListScreen> {
  final _fs = VeranstaltungenFs();
  final _search = TextEditingController();
  String _sortBy = 'date';
  bool _desc = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openCreate({CreatePreset? preset}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VeranstaltungenScreen(preset: preset),
      ),
    );
    // Kein setState nötig: Stream aktualisiert automatisch
  }

  void _showFabMenu() {
    _openCreate();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.hellbeige,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Foto aufnehmen'),
              onTap: () {
                Navigator.pop(ctx);
                _openCreate(preset: CreatePreset.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Foto aus Galerie'),
              onTap: () {
                Navigator.pop(ctx);
                _openCreate(preset: CreatePreset.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Info eingeben'),
              onTap: () {
                Navigator.pop(ctx);
                _openCreate(preset: CreatePreset.info);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Datum auswählen'),
              onTap: () {
                Navigator.pop(ctx);
                _openCreate(preset: CreatePreset.date);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hellbeige,
      appBar: const BasicTopBar(
        title: 'Veranstaltungen',
        showBack: true,
        showMenu: false,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.dunkelbraun,
        foregroundColor: AppColors.hellbeige,
        onPressed: _showFabMenu,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    decoration: const InputDecoration(
                      hintText: 'Suchen (Titel oder Info)…',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => setState(() {}), // Stream neu bauen
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _sortBy,
                  items: const [
                    DropdownMenuItem(value: 'date', child: Text('Datum')),
                    DropdownMenuItem(value: 'title', child: Text('Titel')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _sortBy = v);
                  },
                ),
                IconButton(
                  onPressed: () => setState(() => _desc = !_desc),
                  icon: Icon(_desc ? Icons.south : Icons.north),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ---- Firestore-Live-Liste ----
            Expanded(
              child: StreamBuilder<List<ForumItem>>(
                stream: _fs.watch(
                  type: ForumItemType.event,
                  sortBy: _sortBy,
                  desc: _desc,
                  query:
                      _search.text.trim().isEmpty ? null : _search.text.trim(),
                ),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = snap.data!;
                  if (items.isEmpty) {
                    return const Center(
                        child: Text('Keine Veranstaltungen angelegt.'));
                  }
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (c, i) {
                      final it = items[i];
                      final hasImage = it.imagePath != null &&
                          File(it.imagePath!).existsSync();

                      return Dismissible(
                        key: ValueKey(it.fsId ?? '${i}-${it.title}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          color: Colors.redAccent,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) async {
                          if (it.fsId != null) {
                            await _fs.delete(it.fsId!);
                          }
                          // Stream aktualisiert automatisch
                        },
                        child: Card(
                          color: AppColors.hellbeige,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ListTile(
                            leading: hasImage
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(it.imagePath!),
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.broken_image),
                                    ),
                                  )
                                : const Icon(Icons.event_outlined),
                            title: Text(
                                it.title.isEmpty ? 'Ohne Titel' : it.title),
                            subtitle: Text(
                              it.date != null
                                  ? '${it.date!.day.toString().padLeft(2, '0')}.${it.date!.month.toString().padLeft(2, '0')}.${it.date!.year}  ·  ${it.info}'
                                  : it.info,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
