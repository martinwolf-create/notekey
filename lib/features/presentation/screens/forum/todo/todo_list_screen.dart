import 'package:flutter/material.dart';
import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/features/widgets/topbar/basic_topbar.dart';
import 'package:notekey_app/features/presentation/screens/forum/data/todo_db.dart';
import 'package:notekey_app/features/presentation/screens/forum/data/todo_item.dart';
import 'todo_edit_screen.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TodoDb _db = TodoDb();

  Future<List<TodoItem>> _loadTodos() => _db.list();

  Future<void> _openEdit([TodoItem? item]) async {
    final saved = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TodoEditScreen(item: item)),
    );
    if (saved == true) setState(() {});
  }

  Future<void> _toggle(TodoItem t, bool v) async {
    await _db.update(t.copyWith(done: v));
    setState(() {});
  }

  Future<void> _delete(TodoItem t) async {
    if (t.id == null) return;
    await _db.delete(t.id!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hellbeige,
      appBar: const BasicTopBar(
        title: 'To-Do',
        showBack: true,
        showMenu: false,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.dunkelbraun,
        foregroundColor: AppColors.hellbeige,
        onPressed: () => _openEdit(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<TodoItem>>(
        future: _loadTodos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('Noch keine To-Dos.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final t = items[index];
              return Dismissible(
                key: ValueKey(t.id ?? '${t.title}-$index'),
                background: Container(
                  color: Colors.red.withOpacity(.85),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => _delete(t),
                child: Card(
                  color: AppColors.hellbeige,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                        color: AppColors.dunkelbraun.withOpacity(.12)),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    leading: Checkbox(
                      value: t.done,
                      onChanged: (v) => _toggle(t, v ?? false),
                      activeColor: AppColors.dunkelbraun,
                    ),
                    title: Text(
                      t.title.isEmpty ? 'Ohne Titel' : t.title,
                      style: TextStyle(
                        decoration: t.done ? TextDecoration.lineThrough : null,
                        color: AppColors.dunkelbraun,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: (t.note.isEmpty && t.due == null)
                        ? null
                        : Text(
                            [
                              if (t.due != null)
                                '${t.due!.day.toString().padLeft(2, '0')}.'
                                    '${t.due!.month.toString().padLeft(2, '0')}.'
                                    '${t.due!.year}',
                              if (t.note.isNotEmpty) t.note,
                            ].join('  ·  '),
                          ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openEdit(t),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
