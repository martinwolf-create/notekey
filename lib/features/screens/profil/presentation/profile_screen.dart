import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notekey_app/features/auth/firebase_auth_repository.dart';
import 'package:notekey_app/features/routes/app_routes.dart';
import 'package:notekey_app/features/themes/colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = FirebaseAuthRepository();

    return DefaultTabController(
      length: 6, // Übersicht, Bilder, Videos, Likes, Events, Gespeichert
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
            final bio = (data['bio'] ?? '').toString();

            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                // CLEAN TOP BAR: Back links, Titel zentriert
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
                // Sticky Tabbar
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
                      ],
                    ),
                  ),
                ),
                // SUMMARY CARD zwischen Tabs und Inhalt
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                    child: _ProfileSummaryCard(
                      username: username,
                      city: city,
                      age: age,
                      bio: bio,
                      photoUrl: photoUrl,
                      onEdit: () =>
                          Navigator.of(context).pushNamed(AppRoutes.editProfil),
                      onShare: () {
                        // TODO: Teilen-Flow
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
          // Avatar (rechts)
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

/// ---------- TABS (Platzhalter v1)

class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    return _PlaceholderPanel(
      title: 'Übersicht',
      lines: const [
        '• Letzte Bilder/Videos',
        '• Zuletzt gelikte Inhalte',
        '• Nächste Events',
      ],
    );
  }
}

class _ImagesTab extends StatelessWidget {
  const _ImagesTab();

  @override
  Widget build(BuildContext context) {
    return _PlaceholderPanel(
      title: 'Bilder',
      lines: const [
        'Grid mit deinen Bildern',
        'Paginierung & Cache',
      ],
    );
  }
}

class _VideosTab extends StatelessWidget {
  const _VideosTab();

  @override
  Widget build(BuildContext context) {
    return _PlaceholderPanel(
      title: 'Videos',
      lines: const [
        'Thumbnails + Dauer',
        'Play in Detailansicht',
      ],
    );
  }
}

class _LikesTab extends StatelessWidget {
  const _LikesTab();

  @override
  Widget build(BuildContext context) {
    return _PlaceholderPanel(
      title: 'Likes',
      lines: const [
        'Medien / Posts / Events',
        'Filter: Typ auswählen',
      ],
    );
  }
}

class _EventsTab extends StatelessWidget {
  const _EventsTab();

  @override
  Widget build(BuildContext context) {
    return _PlaceholderPanel(
      title: 'Events',
      lines: const [
        'Gelikt • Gespeichert • Teilgenommen',
        'Filterchips oben',
      ],
    );
  }
}

class _SavedTab extends StatelessWidget {
  const _SavedTab();

  @override
  Widget build(BuildContext context) {
    return _PlaceholderPanel(
      title: 'Gespeichert',
      lines: const [
        'Deine Bookmarks',
        'Medien / Posts / Events',
      ],
    );
  }
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
