import 'dart:io';
import 'package:flutter/material.dart';
import 'package:notekey_app/features/screens/forum/suchfind/find/find_detail_screen.dart';
import 'package:provider/provider.dart';

import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/features/widgets/topbar/basic_topbar.dart';

import 'package:notekey_app/features/screens/forum/suchfind/data/suchfind_model.dart';
import 'package:notekey_app/features/screens/forum/suchfind/provider/suchfind_provider.dart';
import 'find_edit_screen.dart';

class FindListScreen extends StatelessWidget {
  const FindListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SuchfindProvider()..start(kind: MarketKind.find),
      child: Scaffold(
        backgroundColor: AppColors.hellbeige,
        appBar: const BasicTopBar(
          title: 'Finde',
          showBack: true,
          showMenu: false,
        ),
        floatingActionButton: Builder(
          builder: (ctx) => FloatingActionButton(
            backgroundColor: AppColors.dunkelbraun,
            foregroundColor: AppColors.hellbeige,
            onPressed: () async {
              final ok = await Navigator.push<bool>(
                ctx,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: ctx.read<SuchfindProvider>(),
                    child: const FindEditScreen(),
                  ),
                ),
              );
              // nichts weiter nötig – Stream aktualisiert sich selbst
            },
            child: const Icon(Icons.add),
          ),
        ),
        body: Consumer<SuchfindProvider>(
          builder: (context, p, _) {
            if (p.loading)
              return const Center(child: CircularProgressIndicator());
            if (p.error != null) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: SelectableText('Fehler beim Laden:\n${p.error}'),
              );
            }
            final items = p.items;
            if (items.isEmpty) {
              return const Center(
                  child: Text('Keine Finde-Anzeigen vorhanden.'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final it = items[i];
                final img = it.imageUrl;
                final hasImg = (img != null && img.isNotEmpty);
                final isUrl = hasImg &&
                    (img!.startsWith('http://') || img.startsWith('https://'));

                return Dismissible(
                  key: ValueKey(it.id ?? 'find-$i'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color: Colors.redAccent,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) async {
                    if (it.id != null) {
                      await context.read<SuchfindProvider>().delete(it.id!);
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
                              child: isUrl
                                  ? Image.network(
                                      img!,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.broken_image),
                                    )
                                  : Image.file(
                                      File(img!),
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.broken_image),
                                    ),
                            )
                          : const Icon(Icons.search_off),
                      title: Text(it.title.isEmpty ? 'Ohne Titel' : it.title),
                      subtitle: (it.description?.isNotEmpty ?? false)
                          ? Text(it.description!)
                          : null,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        final id = it.id!;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider.value(
                              value: context.read<SuchfindProvider>(),
                              child: FindDetailScreen(id: id, initial: it),
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
    );
  }
}
