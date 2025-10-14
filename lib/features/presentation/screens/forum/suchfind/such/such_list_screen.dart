// lib/features/presentation/screens/forum/suchfind/such/such_list_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:notekey_app/features/presentation/screens/forum/suchfind/such/such_detail_screen.dart';
import 'package:provider/provider.dart';

import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/features/widgets/topbar/basic_topbar.dart';

import 'package:notekey_app/features/presentation/screens/forum/suchfind/data/suchfind_model.dart';
import 'package:notekey_app/features/presentation/screens/forum/suchfind/provider/suchfind_provider.dart';
import 'such_edit_screen.dart';

class SuchListScreen extends StatelessWidget {
  const SuchListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SuchfindProvider()..start(kind: MarketKind.such),
      child: const _Body(),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({super.key});
  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
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
      floatingActionButton: Builder(
        builder: (ctx) => FloatingActionButton(
          backgroundColor: AppColors.dunkelbraun,
          foregroundColor: AppColors.hellbeige,
          onPressed: () async {
            // WICHTIG: gleiche Provider-Instanz in die Route durchreichen!
            final ok = await Navigator.push<bool>(
              ctx,
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider.value(
                  value: ctx.read<SuchfindProvider>(),
                  child: const SuchEditScreen(),
                ),
              ),
            );
            if (ok == true && mounted) {}
          },
          child: const Icon(Icons.add),
        ),
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
              onSubmitted: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Consumer<SuchfindProvider>(
                builder: (context, p, _) {
                  if (p.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (p.error != null) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: SelectableText('Fehler: ${p.error}'),
                    );
                  }

                  // Filter clientseitig
                  final q = _search.text.trim().toLowerCase();
                  var list = p.items.where((it) {
                    if (q.isEmpty) return true;
                    final t = it.title.toLowerCase();
                    final info = (it.description ?? '').toLowerCase();
                    return t.contains(q) || info.contains(q);
                  }).toList();

                  if (list.isEmpty) {
                    return const Center(child: Text('Noch keine Einträge.'));
                  }

                  return ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (c, i) {
                      final it = list[i];
                      final img = it.imageUrl;
                      final hasImg = img != null && img.isNotEmpty;

                      return Dismissible(
                        key: ValueKey(it.id ?? 'such-$i'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          color: Colors.redAccent,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) async {
                          if (it.id != null) {
                            await context
                                .read<SuchfindProvider>()
                                .delete(it.id!);
                          }
                        },
                        child: Card(
                          color: AppColors.hellbeige,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ListTile(
                            leading: hasImg
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      img!,
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
                            subtitle: (it.description?.isNotEmpty ?? false)
                                ? Text(it.description!)
                                : null,
                            onTap: () {
                              final id = it.id!;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChangeNotifierProvider.value(
                                    value: context.read<SuchfindProvider>(),
                                    child:
                                        SuchDetailScreen(id: id, initial: it),
                                  ),
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
