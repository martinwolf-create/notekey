import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/features/screens/forum/data/forum_item.dart';
import 'package:notekey_app/features/screens/forum/data/veranstaltung_fs.dart';

// WICHTIG: wir nutzen deinen Bearbeiten-Screen hier
import 'package:notekey_app/features/screens/forum/veranstaltung/veranstaltung_bearbeiten_screen.dart';

class VeranstaltungDetailScreen extends StatelessWidget {
  final String fsId;
  final ForumItem? initial;

  const VeranstaltungDetailScreen({
    super.key,
    required this.fsId,
    this.initial,
  });

  @override
  Widget build(BuildContext context) {
    final fs = VeranstaltungenFs();

    // dein InputBorder Theme (Goldbraun statt Lila)
    final inputTheme = Theme.of(context).inputDecorationTheme.copyWith(
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.goldbraun, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.dunkelbraun.withOpacity(.25),
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        );

    return Theme(
      data: Theme.of(context).copyWith(inputDecorationTheme: inputTheme),
      child: Scaffold(
        backgroundColor: AppColors.hellbeige,
        appBar: AppBar(
          backgroundColor: AppColors.dunkelbraun,
          foregroundColor: Colors.white,
          title: const Text('Veranstaltung'),

          // ✎ Button nur anzeigen, wenn aktueller User = Besitzer
          actions: [
            Builder(
              builder: (context) {
                final uid = FirebaseAuth.instance.currentUser?.uid;

                return StreamBuilder<ForumItem?>(
                  stream: fs.watchById(fsId),
                  initialData: initial,
                  builder: (context, snap) {
                    final it = snap.data;
                    final ownerUid = it?.ownerUid ?? '';
                    final isOwner = uid != null && uid == ownerUid;

                    if (!isOwner) {
                      // kein Button für fremde Events
                      return const SizedBox.shrink();
                    }

                    return IconButton(
                      tooltip: 'Bearbeiten',
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        // wir springen jetzt in deinen Bearbeiten-Screen
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VeranstaltungBearbeitenScreen(
                              veranstaltungId: fsId,
                            ),
                          ),
                        );

                        // Wenn dort gespeichert wurde -> Snack hier zeigen
                        if (result == true && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.goldbraun,
                              content: Text(
                                'Änderungen gespeichert.',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),

        // -------- Body mit Inhalt, Likes, Kommentaren --------
        body: StreamBuilder<ForumItem?>(
          stream: fs.watchById(fsId),
          initialData: initial,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snap.hasData || snap.data == null) {
              return const Center(child: Text('Veranstaltung nicht gefunden.'));
            }

            final it = snap.data!;
            final currentUid = FirebaseAuth.instance.currentUser?.uid;
            final ownerUid = it.ownerUid ?? '';
            final imageUrl =
                (it.imagePath?.isNotEmpty == true) ? it.imagePath! : '';

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Bild
                if (imageUrl.isNotEmpty) ...[
                  Hero(
                    tag: 'event_$fsId',
                    child: _ImageBox(imagePath: imageUrl),
                  ),
                  const SizedBox(height: 12),
                ],

                // Titel
                Text(
                  it.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.dunkelbraun,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),

                // Info
                if (it.info.isNotEmpty)
                  Text(
                    it.info,
                    style:
                        TextStyle(color: AppColors.dunkelbraun.withOpacity(.9)),
                  ),

                const SizedBox(height: 12),

                // Likes für das Event
                _EventLikeBar(eventId: fsId),

                const SizedBox(height: 24),

                // Kommentare unter der Veranstaltung
                _CommentsSection(
                  eventId: fsId,
                  ownerUid: ownerUid,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ========== Bildbox (gleich wie bei dir) ==========

class _ImageBox extends StatelessWidget {
  final String imagePath;
  const _ImageBox({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final p = imagePath;
    final isUrl = p.startsWith('http://') || p.startsWith('https://');
    final ImageProvider provider = isUrl
        ? NetworkImage(p)
        : (p.startsWith('file:')
            ? FileImage(File(Uri.parse(p).path))
            : FileImage(File(p))) as ImageProvider;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image(image: provider, fit: BoxFit.cover),
      ),
    );
  }
}

// ========== Likes am Event ==========

class _EventLikeBar extends StatelessWidget {
  const _EventLikeBar({required this.eventId});
  final String eventId;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final likesRef = FirebaseFirestore.instance
        .collection('veranstaltung')
        .doc(eventId)
        .collection('likes');

    return Row(
      children: [
        // Mein Like / Unlike
        if (uid == null)
          IconButton(
            onPressed: null,
            icon: const Icon(Icons.favorite_border),
          )
        else
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: likesRef.doc(uid).snapshots(),
            builder: (context, snap) {
              final liked = snap.data?.exists == true;
              return IconButton(
                icon: Icon(
                  liked ? Icons.favorite : Icons.favorite_border,
                  color: liked ? Colors.red : AppColors.dunkelbraun,
                ),
                onPressed: () async {
                  final meDoc = likesRef.doc(uid);
                  final exists = (await meDoc.get()).exists;
                  if (exists) {
                    await meDoc.delete();
                  } else {
                    await meDoc.set({
                      'uid': uid,
                      'at': FieldValue.serverTimestamp(),
                    });
                  }
                },
              );
            },
          ),

        // Anzahl Likes
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: likesRef.snapshots(),
          builder: (context, snap) {
            final count = snap.data?.docs.length ?? 0;
            return Text(
              '$count Likes',
              style: TextStyle(color: AppColors.dunkelbraun.withOpacity(.9)),
            );
          },
        ),
      ],
    );
  }
}

// ========== Kommentarbereich ==========

class _CommentsSection extends StatelessWidget {
  const _CommentsSection({required this.eventId, required this.ownerUid});
  final String eventId;
  final String ownerUid;

  @override
  Widget build(BuildContext context) {
    final commentsQuery = FirebaseFirestore.instance
        .collection('veranstaltung')
        .doc(eventId)
        .collection('comments')
        .orderBy('createdAt', descending: true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kommentare', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),

        // Liste der Kommentare
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: commentsQuery.snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(),
              );
            }
            final docs = snap.data?.docs ?? [];
            if (docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Noch keine Kommentare.'),
              );
            }

            return Column(
              children: docs.map((d) {
                final m = d.data();
                final commentId = d.id;
                final text = (m['text'] ?? '').toString();
                final authorUid = (m['uid'] ?? '').toString();
                final displayName = (m['displayName'] ?? '').toString();
                final photoUrl = (m['photoUrl'] ?? '').toString();

                final currentUid = FirebaseAuth.instance.currentUser?.uid;
                final canDelete =
                    (currentUid != null && currentUid == authorUid) ||
                        (currentUid != null && currentUid == ownerUid);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 16,
                        backgroundImage:
                            photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                        child: photoUrl.isEmpty
                            ? const Icon(Icons.person, size: 16)
                            : null,
                      ),
                      const SizedBox(width: 10),

                      // Text + Like Row
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName.isNotEmpty ? displayName : 'User',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(text),
                            const SizedBox(height: 4),
                            _CommentLikeRow(
                              eventId: eventId,
                              commentId: commentId,
                            ),
                          ],
                        ),
                      ),

                      // löschen Icon
                      if (canDelete)
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('veranstaltung')
                                .doc(eventId)
                                .collection('comments')
                                .doc(commentId)
                                .delete();
                          },
                        ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),

        const SizedBox(height: 8),

        // Eingabe
        _CommentInput(eventId: eventId),
      ],
    );
  }
}

// ========== Likes pro Kommentar ==========

class _CommentLikeRow extends StatelessWidget {
  const _CommentLikeRow({
    required this.eventId,
    required this.commentId,
  });

  final String eventId;
  final String commentId;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final ref = FirebaseFirestore.instance
        .collection('veranstaltung')
        .doc(eventId)
        .collection('comments')
        .doc(commentId)
        .collection('likes');

    return Row(
      children: [
        if (uid == null)
          IconButton(
            onPressed: null,
            icon: const Icon(Icons.favorite_border),
          )
        else
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: ref.doc(uid).snapshots(),
            builder: (context, snap) {
              final liked = snap.data?.exists == true;
              return IconButton(
                icon: Icon(
                  liked ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: liked ? Colors.red : AppColors.dunkelbraun,
                ),
                onPressed: () async {
                  final me = ref.doc(uid);
                  final exists = (await me.get()).exists;
                  if (exists) {
                    await me.delete();
                  } else {
                    await me.set({
                      'uid': uid,
                      'at': FieldValue.serverTimestamp(),
                    });
                  }
                },
              );
            },
          ),

        // Anzahl Likes am Kommentar
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: ref.snapshots(),
          builder: (context, snap) {
            final c = snap.data?.docs.length ?? 0;
            return Text(
              '$c',
              style: TextStyle(color: AppColors.dunkelbraun),
            );
          },
        ),
      ],
    );
  }
}

// ========== Kommentar-Eingabe ==========

class _CommentInput extends StatefulWidget {
  const _CommentInput({required this.eventId});
  final String eventId;

  @override
  State<_CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<_CommentInput> {
  final _ctrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final txt = _ctrl.text.trim();
    if (txt.isEmpty) return;

    setState(() => _sending = true);
    try {
      // user profil info holen
      final uDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final u = uDoc.data() ?? {};
      final displayName = (u['username'] ?? '').toString();
      final photoUrl = (u['profileImageUrl'] ?? '').toString();

      await FirebaseFirestore.instance
          .collection('veranstaltung')
          .doc(widget.eventId)
          .collection('comments')
          .add({
        'uid': uid,
        'text': txt,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _ctrl.clear();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Textfeld
        Expanded(
          child: TextField(
            controller: _ctrl,
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Kommentieren…',
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Senden-Button
        _sending
            ? const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : IconButton(
                icon: const Icon(Icons.send),
                onPressed: _send,
              ),
      ],
    );
  }
}
