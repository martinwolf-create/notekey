import 'dart:io';
import 'package:flutter/material.dart';
import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/features/widgets/topbar/basic_topbar.dart';

import 'package:notekey_app/features/presentation/screens/forum/data/forum_item.dart';
import 'package:notekey_app/features/presentation/screens/forum/data/suchfind_db.dart';
import 'find_edit_screen.dart';

String _currencySymbol(String? c) {
  switch (c) {
    case 'USD':
      return '\$';
    case 'GBP':
      return '£';
    case 'JPY':
      return '¥';
    case 'CHF':
      return 'CHF';
    default:
      return '€';
  }
}

class FindListScreen extends StatefulWidget {
  const FindListScreen({super.key});

  @override
  State<FindListScreen> createState() => _FindListScreenState();
}

class _FindListScreenState extends State<FindListScreen> {
  final _db = SuchFindDb();
  final _search = TextEditingController();

  bool _loading = true;
  List<ForumItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    final list = await _db.list(
        withPrice: true, query: _search.text.trim(), sortBy: 'price');
    if (!mounted) return;
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  Future<void> _openCreate() async {
    final ok = await Navigator.push<bool>(
        context, MaterialPageRoute(builder: (_) => const FindEditScreen()));
    if (ok == true) _load();
  }

  Future<void> _openEdit(ForumItem it) async {
    final ok = await Navigator.push<bool>(context,
        MaterialPageRoute(builder: (_) => FindEditScreen(initial: it)));
    if (ok == true) _load();
  }

  Future<void> _delete(ForumItem it) async {
    if (it.id != null) await _db.delete(it.id!);
    if (!mounted) return;
    setState(() => _items.removeWhere((x) => x.id == it.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hellbeige,
      appBar: const BasicTopBar(title: 'Find', showBack: true, showMenu: false),
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
            TextField(
              controller: _search,
              decoration: const InputDecoration(
                hintText: 'Suchen (Titel oder Info)…',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _load(),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(
                      child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2)))
                  : (_items.isEmpty
                      ? const Center(child: Text('Noch keine Einträge.'))
                      : ListView.separated(
                          itemCount: _items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (c, i) {
                            final it = _items[i];
                            final hasImage = it.imagePath != null &&
                                File(it.imagePath!).existsSync();
                            final price = it.priceCents != null
                                ? '${_currencySymbol(it.currency)} ${(it.priceCents! / 100).toStringAsFixed(2)}'
                                : null;
                            return Dismissible(
                              key: ValueKey(it.id ??
                                  '${it.title}-$i-${it.imagePath ?? ''}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                color: Colors.redAccent,
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              onDismissed: (_) => _delete(it),
                              child: Card(
                                color: AppColors.hellbeige,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                child: ListTile(
                                  leading: hasImage
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.file(
                                            File(it.imagePath!),
                                            width: 56,
                                            height: 56,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(Icons.broken_image),
                                          ),
                                        )
                                      : const Icon(Icons.sell_outlined),
                                  title: Text(it.title.isEmpty
                                      ? 'Ohne Titel'
                                      : it.title),
                                  subtitle: Text([
                                    if (price != null) price,
                                    if (it.info.isNotEmpty) it.info,
                                  ].join('  ·  ')),
                                  onTap: () => _openEdit(it),
                                ),
                              ),
                            );
                          },
                        )),
            ),
          ],
        ),
      ),
    );
  }
}
