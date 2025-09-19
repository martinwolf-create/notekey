import 'package:flutter/material.dart';
import 'package:notekey_app/features/presentation/screens/forum/data/todo_db.dart';
import 'package:notekey_app/features/presentation/screens/forum/data/todo_item.dart';

class TodoEditScreen extends StatefulWidget {
  final TodoItem? item;
  const TodoEditScreen({super.key, this.item});

  @override
  State<TodoEditScreen> createState() => _TodoEditScreenState();
}

class _TodoEditScreenState extends State<TodoEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime? _due;
  bool _done = false;
  final _db = TodoDb();

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _titleCtrl.text = widget.item!.title;
      _noteCtrl.text = widget.item!.note;
      _due = widget.item!.due;
      _done = widget.item!.done;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final title = _titleCtrl.text.trim();
    final note = _noteCtrl.text.trim();

    if (widget.item == null) {
      await _db
          .insert(TodoItem(title: title, note: note, due: _due, done: _done));
    } else {
      await _db.update(widget.item!.copyWith(
        title: title,
        note: note,
        due: _due,
        done: _done,
      ));
    }
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _due ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _due = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'Neues To-Do' : 'To-Do bearbeiten'),
        actions: [
          IconButton(onPressed: _save, icon: const Icon(Icons.save)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Titel'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Titel eingeben' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(labelText: 'Notiz'),
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.event),
                      label: Text(
                        _due == null
                            ? 'Fälligkeitsdatum'
                            : '${_due!.day.toString().padLeft(2, '0')}.'
                                '${_due!.month.toString().padLeft(2, '0')}.'
                                '${_due!.year}',
                      ),
                      onPressed: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      const Text('Erledigt'),
                      Switch(
                        value: _done,
                        onChanged: (v) => setState(() => _done = v),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
