import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notekey_app/features/presentation/screens/forum/veranstaltung/data/veranstaltung_comments_fs.dart';

class VeranstaltungComments extends StatefulWidget {
  final String veranstaltungId;

  const VeranstaltungComments({super.key, required this.veranstaltungId});

  @override
  State<VeranstaltungComments> createState() => _VeranstaltungCommentsState();
}

class _VeranstaltungCommentsState extends State<VeranstaltungComments> {
  late final VeranstaltungCommentsFs _fs;
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fs = VeranstaltungCommentsFs(widget.veranstaltungId);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    await _fs.add(uid: uid, text: text);
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text("Kommentare", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: _fs.watch(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              );
            }
            final list = snap.data!;
            if (list.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Noch keine Kommentare."),
              );
            }
            return ListView.separated(
              itemCount: list.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const Divider(height: 8),
              itemBuilder: (_, i) {
                final c = list[i];
                return ListTile(
                  dense: true,
                  title: Text(c["text"] ?? ''),
                  subtitle: Text((c["uid"] ?? '').toString()),
                );
              },
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                decoration: const InputDecoration(hintText: "Kommentieren …"),
              ),
            ),
            IconButton(onPressed: _send, icon: const Icon(Icons.send)),
          ],
        ),
      ],
    );
  }
}
