import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // DateFormat etc.
import 'package:notekey_app/features/themes/colors.dart';

class MemoryLeaderboardScreen extends StatelessWidget {
  const MemoryLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hellbeige,
      appBar: AppBar(
        backgroundColor: AppColors.dunkelbraun,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.hellbeige),
        title: const Text(
          'Bestenliste',
          style: TextStyle(
              color: AppColors.hellbeige, fontWeight: FontWeight.w800),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('memory_scores')
            .orderBy('score', descending: true) // Top Scores zuerst
            .limit(50)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(child: Text('Noch keine Einträge.'));
          }

          final docs = snap.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final d = docs[i].data();
              final name = (d['name'] ?? '–').toString();
              final mode = (d['mode'] ?? 'local').toString();
              final moves = (d['moves'] ?? 0) as int;
              final score = (d['score'] ?? 0) as int;

              String when = '';
              final ts = d['finishedAt'];
              if (ts is Timestamp) {
                when = DateFormat('dd.MM.yyyy – HH:mm').format(ts.toDate());
              }

              return Card(
                color: AppColors.hellbeige,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  leading: _RankBadge(rank: i + 1),
                  title: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.dunkelbraun,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Text(
                    'Score: $score   •   Züge: $moves   •   ${mode == 'vs_computer' ? 'vs Computer' : 'Lokal'}\n$when',
                    style: TextStyle(
                        color: AppColors.dunkelbraun.withOpacity(.75)),
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

class _RankBadge extends StatelessWidget {
  final int rank;
  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    final bg = rank == 1
        ? Colors.amber
        : rank == 2
            ? Colors.grey.shade400
            : rank == 3
                ? Colors.brown.shade300
                : AppColors.rosebeige;
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.goldbraun.withOpacity(.35)),
      ),
      child: Text(
        '$rank',
        style: TextStyle(
          color: AppColors.dunkelbraun,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
