import 'dart:io';
import 'package:flutter/material.dart';

import 'package:notekey_app/features/presentation/screens/forum/veranstaltung/veranstaltung_edit_screen.dart';
import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/features/widgets/topbar/basic_topbar.dart';

// bestehendes Model aus dem Forum-Bereich
import 'package:notekey_app/features/presentation/screens/forum/data/forum_item.dart';

// alter FS-Service bleibt als Fallback nutzbar (z. B. fürs Löschen)
import 'package:notekey_app/features/presentation/screens/forum/data/veranstaltung_fs.dart';

import 'package:notekey_app/features/presentation/screens/forum/create_entry_page.dart';
import 'package:notekey_app/features/presentation/screens/forum/veranstaltung/veranstaltung_detail_screen.dart';

// Provider + dein Veranstaltungs-Model
import 'package:provider/provider.dart';
import 'package:notekey_app/features/presentation/screens/forum/veranstaltung/provider/veranstaltung_provider.dart';
import 'package:notekey_app/features/presentation/screens/forum/veranstaltung/data/veranstaltung_model.dart';

enum CreatePreset { camera, gallery, info, date }

extension VeranstaltungCompat on Veranstaltung {
  String? get fsId => id; // alias für alte Verwendung
  String? get imagePath => imageUrl; // alias (URL oder lokaler Pfad)
  String get info => description ?? ''; // alias für Beschreibung
  DateTime? get dateMaybe => date; // falls mal nullable erwartet
}

class VeranstaltungenListScreen extends StatefulWidget {
  final String? collection;
  const VeranstaltungenListScreen({super.key, this.collection});

  @override
  State<VeranstaltungenListScreen> createState() =>
      _VeranstaltungenListScreenState();
}

class _VeranstaltungenListScreenState extends State<VeranstaltungenListScreen> {
  // bleibt: dein FS-Service (für Fallbacks wie delete)
  final _fs = VeranstaltungenFs();

  // Suche & Sortierung ohne setState via ValueNotifier/AnimatedBuilder
  final _search = TextEditingController();
  final ValueNotifier<String> _sortByVN = ValueNotifier<String>('date');
  final ValueNotifier<bool> _descVN = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _search.dispose();
    _sortByVN.dispose();
    _descVN.dispose();
    super.dispose();
  }

  Future<void> _openCreate({CreatePreset? preset}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VeranstaltungenScreen()),
    );
    // Kein setState nötig: Provider-Stream aktualisiert automatisch.
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
    // Lokaler Provider nur für diesen Screen – KEINE Änderung an main.dart nötig.
    return ChangeNotifierProvider(
      create: (_) => VeranstaltungProvider()..start(),
      child: Scaffold(
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
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ValueListenableBuilder<String>(
                    valueListenable: _sortByVN,
                    builder: (context, sortBy, _) {
                      return DropdownButton<String>(
                        value: sortBy,
                        items: const [
                          DropdownMenuItem(value: 'date', child: Text('Datum')),
                          DropdownMenuItem(
                              value: 'title', child: Text('Titel')),
                        ],
                        onChanged: (v) {
                          if (v == null) return;
                          _sortByVN.value = v;
                        },
                      );
                    },
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: _descVN,
                    builder: (context, desc, _) {
                      return IconButton(
                        onPressed: () => _descVN.value = !desc,
                        icon: Icon(desc ? Icons.south : Icons.north),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Liste über Provider (p.items = List<Veranstaltung>)
              Expanded(
                child: Consumer<VeranstaltungProvider>(
                  builder: (context, p, _) {
                    if (p.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (p.error != null) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: SingleChildScrollView(
                          child: SelectableText(
                            'Fehler beim Laden:\n\n${p.error}\n\n'
                            'Tipp: Falls "requires an index" auftaucht, '
                            'Composite Index in Firestore anlegen.',
                          ),
                        ),
                      );
                    }

                    // Rohdaten aus Provider:
                    final raw = p.items; // List<Veranstaltung>

                    // Suche/Sortierung
                    return AnimatedBuilder(
                      animation:
                          Listenable.merge([_search, _sortByVN, _descVN]),
                      builder: (context, _) {
                        final q = _search.text.trim().toLowerCase();

                        // Kopie erstellen,sortieren/filtern
                        List<Veranstaltung> list = List.of(raw);

                        if (q.isNotEmpty) {
                          list = list.where((it) {
                            final t = (it.title).toLowerCase();
                            final info = (it.info).toLowerCase();
                            return t.contains(q) || info.contains(q);
                          }).toList();
                        }

                        final sortBy = _sortByVN.value;
                        final desc = _descVN.value;
                        list.sort((a, b) {
                          int cmp;
                          if (sortBy == 'title') {
                            cmp = a.title
                                .toLowerCase()
                                .compareTo(b.title.toLowerCase());
                          } else {
                            final ad = a.dateMaybe ??
                                DateTime.fromMillisecondsSinceEpoch(0);
                            final bd = b.dateMaybe ??
                                DateTime.fromMillisecondsSinceEpoch(0);
                            cmp = ad.compareTo(bd);
                          }
                          return desc ? -cmp : cmp;
                        });

                        if (list.isEmpty) {
                          return const Center(
                              child: Text('Keine Veranstaltungen angelegt.'));
                        }

                        return ListView.separated(
                          itemCount: list.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (c, i) {
                            final it = list[i];

                            final img = it
                                .imagePath; // URL ODER lokaler Pfad (Extension)
                            final isUrl = img != null &&
                                (img.startsWith('http://') ||
                                    img.startsWith('https://'));

                            return Dismissible(
                              key: ValueKey(it.fsId ?? '${i}-${it.title}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                color: Colors.redAccent,
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              onDismissed: (_) async {
                                if (it.fsId != null) {
                                  try {
                                    await context
                                        .read<VeranstaltungProvider>()
                                        .delete(it.fsId!);
                                  } catch (_) {
                                    // Fallback auf alten FS-Service, falls nötig:
                                    await _fs.delete(it.fsId!);
                                  }
                                }
                              },
                              child: Card(
                                color: AppColors.hellbeige,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: ListTile(
                                  onTap: () {
                                    final id = it.fsId;
                                    if (id == null) return; // Sicherheit
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            VeranstaltungDetailScreen(
                                          fsId: id,
                                          initial: ForumItem(
                                            fsId: id,
                                            type: ForumItemType
                                                .event, // Pflichtfeld ergänzen
                                            title: it.title,
                                            info: it.info,
                                            imagePath: it.imagePath,
                                            date: it.dateMaybe,
                                            // ownerUid: it.ownerUid,
                                            // priceCents: null,
                                            // currency: null,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  leading: (img != null && img.isNotEmpty)
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: isUrl
                                              ? Image.network(
                                                  img,
                                                  width: 56,
                                                  height: 56,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      const Icon(
                                                          Icons.broken_image),
                                                )
                                              : Image.file(
                                                  File(img),
                                                  width: 56,
                                                  height: 56,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      const Icon(
                                                          Icons.broken_image),
                                                ),
                                        )
                                      : const Icon(Icons.event_outlined),
                                  title: Text(it.title.isEmpty
                                      ? 'Ohne Titel'
                                      : it.title),
                                  subtitle: Text(
                                    it.dateMaybe != null
                                        ? '${it.dateMaybe!.day.toString().padLeft(2, '0')}.'
                                            '${it.dateMaybe!.month.toString().padLeft(2, '0')}.'
                                            '${it.dateMaybe!.year}  ·  ${it.info}'
                                        : it.info,
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
