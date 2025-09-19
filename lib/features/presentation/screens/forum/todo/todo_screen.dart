import 'package:flutter/material.dart';
import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/features/widgets/topbar/basic_topbar.dart';
import 'package:notekey_app/features/presentation/screens/forum/data/forum_db.dart';
import 'package:notekey_app/features/presentation/screens/forum/data/forum_item.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final List<_TodoItem> _items = [
    _TodoItem('Saiten kaufen'),
    _TodoItem('Probe-Plan posten'),
  ];

  void _addItemDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.hellbeige,
        title: const Text('Neuer ToDo-Punkt'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Titel…'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldbraun,
                foregroundColor: AppColors.hellbeige),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() => _items.add(_TodoItem(controller.text.trim())));
              }
              Navigator.pop(context);
            },
            child: const Text('Hinzufügen'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hellbeige,
      appBar: const BasicTopBar(title: 'ToDo', showBack: true, showMenu: false),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.dunkelbraun,
        foregroundColor: AppColors.hellbeige,
        onPressed: _addItemDialog,
        child: const Icon(Icons.add_task),
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
        itemCount: _items.length,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) newIndex -= 1;
            final item = _items.removeAt(oldIndex);
            _items.insert(newIndex, item);
          });
        },
        itemBuilder: (context, index) {
          final item = _items[index];
          return Dismissible(
            key: ValueKey(item.title),
            background: Container(
              color: Colors.red.withOpacity(.8),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => setState(() => _items.removeAt(index)),
            child: Card(
              color: AppColors.hellbeige,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: CheckboxListTile(
                value: item.done,
                onChanged: (v) => setState(() => item.done = v ?? false),
                title: Text(
                  item.title,
                  style: TextStyle(
                    decoration: item.done ? TextDecoration.lineThrough : null,
                    color: AppColors.dunkelbraun,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                secondary: const Icon(Icons.drag_handle),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TodoItem {
  final String title;
  bool done;
  _TodoItem(this.title, {this.done = false});
}
