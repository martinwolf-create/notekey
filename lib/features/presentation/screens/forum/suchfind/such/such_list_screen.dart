import 'dart:io';
import 'package:flutter/material.dart';
import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/features/widgets/topbar/basic_topbar.dart';

import 'package:notekey_app/features/presentation/screens/forum/data/forum_item.dart';
import 'package:notekey_app/features/presentation/screens/forum/data/suchfind_fs.dart';
import 'such_edit_screen.dart';

class SuchListScreen extends StatefulWidget {
  const SuchListScreen({super.key});

  @override
  State<SuchListScreen> createState() => _SuchListScreenState();
}

class _SuchListScreenState extends State<SuchListScreen> {
  final _fs = SuchFindFs();
  final _search = TextEditingController();

  String _sortBy = 'date'; // 'date' | 'title'
  bool _desc = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Stream<List<ForumItem>> _watch() {
    return _fs.watch(
      kind: MarketKind.such,
      type: ForumItemType.market,
      // sortBy: _sortBy,
      // desc: _desc,
      query: _search.text.trim().isEmpty ? null : _search.text.trim(),
      //nur such-Einträge anzeigen
    );
  }

  Future<void> _openCreate() async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const SuchEditScreen()),
    );
    if (ok == true) setState(() {}); // Stream aktualisiert automatisch
  }

  Future<void> _openEdit(ForumItem it) async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => SuchEditScreen(initial: it)),
    );
    if (ok == true) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hellbeige,
      appBar: const BasicTopBar(
        title: 'Such',
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
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
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

            // Firestore Live Liste
            Expanded(
              child: StreamBuilder<List<ForumItem>>(
                stream: _watch(),
                builder: (context, snap) {
                  if (snap.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: SelectableText('Fehler: ${snap.error}'),
                    );
                  }
                  if (!snap.hasData) {
                    return const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
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

                      return Dismissible(
                        key: ValueKey(
                            it.fsId ?? '${it.title}-$i-${it.imagePath ?? ''}'),
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
                                : const Icon(Icons.search),
                            title: Text(
                                it.title.isEmpty ? 'Ohne Titel' : it.title),
                            subtitle: it.info.isEmpty ? null : Text(it.info),
                            onTap: () => _openEdit(it),
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
