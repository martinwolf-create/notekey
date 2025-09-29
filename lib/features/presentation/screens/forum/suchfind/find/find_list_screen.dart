import 'dart:io';
import 'package:flutter/material.dart';
import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/features/widgets/topbar/basic_topbar.dart';

import 'package:notekey_app/features/presentation/screens/forum/data/forum_item.dart';
import 'package:notekey_app/features/presentation/screens/forum/data/suchfind_fs.dart';
import 'package:notekey_app/features/presentation/screens/forum/suchfind/find/find_edit_screen.dart';
import 'package:notekey_app/features/presentation/screens/forum/create_entry_page.dart';

class FindListScreen extends StatefulWidget {
  const FindListScreen({super.key});

  @override
  State<FindListScreen> createState() => _FindListScreenState();
}

class _FindListScreenState extends State<FindListScreen> {
  final _sf = SuchFindFs();
  final _search = TextEditingController();
  String _sortBy = 'date'; // 'date' | 'title' | 'price'
  bool _desc = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openCreate() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FindEditScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hellbeige,
      appBar: const BasicTopBar(
        title: 'Such & Find',
        showBack: true,
        showMenu: false,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.dunkelbraun,
        foregroundColor: AppColors.hellbeige,
        onPressed: _openCreate,
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
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _sortBy,
                  items: const [
                    DropdownMenuItem(value: 'date', child: Text('Datum')),
                    DropdownMenuItem(value: 'title', child: Text('Titel')),
                    DropdownMenuItem(value: 'price', child: Text('Preis')),
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
                stream: _sf.watch(
                  kind: MarketKind.find,
                  type: ForumItemType.market,
                  // auskommentiert für Abgabe
                  // sortBy: _sortBy,
                  // desc: _desc,
                  query:
                      _search.text.trim().isEmpty ? null : _search.text.trim(),
                ),
                builder: (context, snap) {
                  if (snap.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          'Fehler beim Laden:\n\n${snap.error}\n\n'
                          'Index-Tipp: Collection "suchfind" → '
                          'type Asc + date_epoch/price_cents/title Asc.',
                        ),
                      ),
                    );
                  }

                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final items = snap.data!;
                  if (items.isEmpty) {
                    return const Center(child: Text('Noch keine Einträge.'));
                  }

                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (c, i) {
                      final it = items[i];
                      final hasImage = it.imagePath != null &&
                          File(it.imagePath!).existsSync();

                      final priceText = (it.priceCents != null &&
                              it.currency != null)
                          ? '${(it.priceCents! / 100).toStringAsFixed(2)} ${it.currency}'
                          : 'Preis n. a.';

                      return Dismissible(
                        key: ValueKey(it.fsId ?? '$i-${it.title}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          color: Colors.redAccent,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) async {
                          if (it.fsId != null) {
                            await _sf.delete(it.fsId!);
                          }
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
                                : const Icon(Icons.shopping_bag_outlined),
                            title: Text(
                                it.title.isEmpty ? 'Ohne Titel' : it.title),
                            subtitle: Text('${it.info}\n$priceText'),
                            isThreeLine: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FindEditScreen(initial: it),
                                ),
                              );
                            },
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
