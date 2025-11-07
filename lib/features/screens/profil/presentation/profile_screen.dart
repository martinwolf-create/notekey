// lib/features/screens/profil/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:notekey_app/features/auth/firebase_auth_repository.dart';
import 'package:notekey_app/features/routes/app_routes.dart';
import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/features/screens/profil/presentation/tabs/friends_tab.dart';
import 'package:notekey_app/features/screens/profil/presentation/profil_extern_screen.dart';

// Detail-Screen der Veranstaltung
import 'package:notekey_app/features/screens/forum/veranstaltung/veranstaltung_detail_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = FirebaseAuthRepository();

    return DefaultTabController(
      length:
          7, // Übersicht, Bilder, Videos, Likes, Events, Gespeichert, Freunde
      child: Scaffold(
        backgroundColor: AppColors.hellbeige,
        body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: repo.streamMyUserDoc(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snap.hasData || !snap.data!.exists) {
              return _EmptyState.scaffold(
                title: 'Mein Profil',
                message: 'Kein Profil gefunden.',
              );
            }

            final data = snap.data!.data()!;
            final username = (data['username'] ?? '').toString();
            final city = (data['city'] ?? '').toString();
            final age = (data['age']?.toString() ?? '—');
            final photoUrl = (data['profileImageUrl'] ?? '').toString();
            final updatedAtMs =
                (data['updatedAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
            // Cache-Bust für Avatar
            final photoBusted =
                photoUrl.isNotEmpty ? '$photoUrl?v=$updatedAtMs' : '';
            final bio = (data['bio'] ?? '').toString();

            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  pinned: true,
                  centerTitle: true,
                  backgroundColor: AppColors.dunkelbraun,
                  foregroundColor: Colors.white,
                  title: const Text('Mein Profil'),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabsHeaderDelegate(
                    TabBar(
                      isScrollable: true,
                      indicatorColor: AppColors.goldbraun,
                      labelColor: AppColors.dunkelbraun,
                      unselectedLabelColor:
                          AppColors.dunkelbraun.withOpacity(.6),
                      tabAlignment: TabAlignment.start,
                      tabs: const [
                        Tab(text: 'Übersicht'),
                        Tab(text: 'Bilder'),
                        Tab(text: 'Videos'),
                        Tab(text: 'Likes'),
                        Tab(text: 'Events'),
                        Tab(text: 'Gespeichert'),
                        Tab(text: 'Freunde'),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                    child: _ProfileSummaryCard(
                      username: username,
                      city: city,
                      age: age,
                      bio: bio,
                      photoUrl: photoBusted,
                      onEdit: () =>
                          Navigator.of(context).pushNamed(AppRoutes.editProfil),
                      onShare: () {
                        // optional: Teilen-Flow
                      },
                    ),
                  ),
                ),
              ],
              body: const TabBarView(
                children: [
                  _OverviewTab(),
                  _ImagesTab(),
                  _VideosTab(),
                  _LikesTab(),
                  _EventsTab(),
                  _SavedTab(),
                  FriendsTab(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({
    required this.username,
    required this.city,
    required this.age,
    required this.bio,
    required this.photoUrl,
    required this.onEdit,
    required this.onShare,
  });

  final String username;
  final String city;
  final String age;
  final String bio;
  final String photoUrl;
  final VoidCallback onEdit;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.rosebeige,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldbraun),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Infos + Actions (links)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _kv('Username', username.isEmpty ? '—' : username),
                _kv('Stadt', city.isEmpty ? '—' : city),
                _kv('Alter', age.isEmpty ? '—' : age),
                if (bio.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    bio,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(color: AppColors.dunkelbraun.withOpacity(.8)),
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeaderChip(
                      icon: Icons.edit,
                      label: 'Bearbeiten',
                      onTap: onEdit,
                    ),
                    _HeaderChip(
                      icon: Icons.share_outlined,
                      label: 'Teilen',
                      onTap: onShare,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Avatar (rechts) – busted URL
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.hellbeige,
            backgroundImage:
                photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
            child: photoUrl.isEmpty
                ? const Icon(Icons.person,
                    size: 36, color: AppColors.dunkelbraun)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$k: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Flexible(child: Text(v, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.goldbraun,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------- TABS

/// Übersicht = „Meine letzten Veranstaltungen“ (20) mit Tap -> Detail + Hero
class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _panel(
          title: 'Meine letzten Veranstaltungen',
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('veranstaltung')
                .where('uid', isEqualTo: uid)
                .orderBy('createdAt', descending: true)
                .limit(20)
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(8),
                  child: LinearProgressIndicator(),
                );
              }

              final docs = snap.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Text('Noch keine Veranstaltungen.');
              }

              return Column(
                children: docs.map((d) {
                  final m = d.data();
                  final id = d.id;
                  final title = (m['title'] ?? '').toString();
                  final img = (m['imageUrl'] ?? '').toString();

                  final whenMs = (m['date_epoch'] as int?) ?? 0;
                  final when = whenMs > 0
                      ? DateTime.fromMillisecondsSinceEpoch(whenMs)
                          .toLocal()
                          .toString()
                      : '—';

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VeranstaltungDetailScreen(fsId: id),
                        ),
                      );
                    },
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: _EventLeadingThumb(id: id, imageUrl: img),
                      title: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(when),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        _panel(
          title: 'Übersicht',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('• Letzte Bilder/Videos'),
              Text('• Zuletzt gelikte Inhalte'),
              Text('• Nächste Events'),
            ],
          ),
        ),
      ],
    );
  }
}

/// Events-Tab = alle eigenen Veranstaltungen mit Tap -> Detail + Hero
class _EventsTab extends StatelessWidget {
  const _EventsTab();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _panel(
          title: 'Events',
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('veranstaltung')
                .where('uid', isEqualTo: uid)
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(8),
                  child: LinearProgressIndicator(),
                );
              }

              final docs = snap.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Text('Noch keine Veranstaltungen.');
              }

              return Column(
                children: docs.map((d) {
                  final m = d.data();
                  final id = d.id;
                  final title = (m['title'] ?? '').toString();
                  final img = (m['imageUrl'] ?? '').toString();

                  final whenMs = (m['date_epoch'] as int?) ?? 0;
                  final when = whenMs > 0
                      ? DateTime.fromMillisecondsSinceEpoch(whenMs)
                          .toLocal()
                          .toString()
                      : '—';

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VeranstaltungDetailScreen(fsId: id),
                        ),
                      );
                    },
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: _EventLeadingThumb(id: id, imageUrl: img),
                      title: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(when),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

Widget _panel({required String title, required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.rosebeige,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.goldbraun),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        child,
      ],
    ),
  );
}

/// Mini-Platzhalter für die anderen Tabs (kannst du später ersetzen)
class _ImagesTab extends StatelessWidget {
  const _ImagesTab();
  @override
  Widget build(BuildContext context) =>
      const _PlaceholderPanel(title: 'Bilder', lines: [
        'Grid mit deinen Bildern',
        'Paginierung & Cache',
      ]);
}

class _VideosTab extends StatelessWidget {
  const _VideosTab();
  @override
  Widget build(BuildContext context) =>
      const _PlaceholderPanel(title: 'Videos', lines: [
        'Thumbnails + Dauer',
        'Play in Detailansicht',
      ]);
}

class _LikesTab extends StatelessWidget {
  const _LikesTab();
  @override
  Widget build(BuildContext context) =>
      const _PlaceholderPanel(title: 'Likes', lines: [
        'Medien / Posts / Events',
        'Filter: Typ auswählen',
      ]);
}

class _SavedTab extends StatelessWidget {
  const _SavedTab();
  @override
  Widget build(BuildContext context) =>
      const _PlaceholderPanel(title: 'Gespeichert', lines: [
        'Deine Bookmarks',
        'Medien / Posts / Events',
      ]);
}

/// ---------- HELPERS UI

class _TabsHeaderDelegate extends SliverPersistentHeaderDelegate {
  _TabsHeaderDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.hellbeige,
      alignment: Alignment.centerLeft,
      child: _tabBar,
    );
  }

  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  bool shouldRebuild(covariant _TabsHeaderDelegate oldDelegate) => false;
}

class _PlaceholderPanel extends StatelessWidget {
  const _PlaceholderPanel({required this.title, required this.lines});
  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.rosebeige,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.goldbraun),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  )),
              const SizedBox(height: 8),
              for (final l in lines)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    l,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  static Widget scaffold({required String title, required String message}) {
    return Scaffold(
      backgroundColor: AppColors.hellbeige,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.dunkelbraun,
        foregroundColor: Colors.white,
      ),
      body: Center(child: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) => Center(child: Text(message));
}

/// Kleines rundes Vorschaubild mit Hero-Tag für nahtlose Transition
class _EventLeadingThumb extends StatelessWidget {
  const _EventLeadingThumb({required this.id, required this.imageUrl});

  final String id;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final hasImg = imageUrl.isNotEmpty;
    final w = 36.0;

    return Hero(
      tag: 'event_$id',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(w / 2),
        child: Container(
          width: w,
          height: w,
          color: AppColors.hellbeige,
          child: hasImg
              ? Image.network(imageUrl, fit: BoxFit.cover)
              : const Icon(Icons.event, size: 20),
        ),
      ),
    );
  }
}
