import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notekey_app/features/auth/firebase_auth_repository.dart';
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
                // Collapsible Header mit Cover + Avatar + Name + Bio
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  snap: false,
                  expandedHeight: 240,
                  backgroundColor: AppColors.dunkelbraun,
                  foregroundColor: Colors.white,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  title: const Text('Mein Profil'),
                  flexibleSpace: FlexibleSpaceBar(
                    background: _ProfileHeader(
                      username: username,
                      city: city,
                      age: age,
                      bio: bio,
                      photoUrl: photoUrl,
                    ),
                  ),
                ),
                // Sticky Tabbar wie bei FB/IG
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

/// ---------- HEADER

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.username,
    required this.city,
    required this.age,
    required this.bio,
    required this.photoUrl,
  });

  final String username;
  final String city;
  final String age;
  final String bio;
  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Cover (Beige-Ton mit leichter Textur / Farbfläche)
        Container(color: AppColors.dunkelbraun),
        // Beige Welle unten
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.hellbeige,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
          ),
        ),
        // Inhalt
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 64, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar + Namezeile
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: AppColors.rosebeige,
                      backgroundImage:
                          photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                      child: photoUrl.isEmpty
                          ? const Icon(Icons.person,
                              size: 40, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.rosebeige,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.goldbraun),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _kv('Username', username.isEmpty ? '—' : username),
                            _kv('Stadt', city.isEmpty ? '—' : city),
                            _kv('Alter', age.isEmpty ? '—' : age),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Bio + Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        bio.isEmpty ? '—' : bio,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.hellbeige.withOpacity(.9),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _HeaderButton(
                      icon: Icons.edit,
                      label: 'Bearbeiten',
                      onTap: () {
                        // TODO: navigate to edit_profile_screen.dart
                      },
                    ),
                    const SizedBox(width: 8),
                    _HeaderButton(
                      icon: Icons.share_outlined,
                      label: 'Teilen',
                      onTap: () {
                        // TODO: Teilen-Flow (später)
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(k,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white)),
          const Text(': ', style: TextStyle(color: Colors.white)),
          Expanded(
            child: Text(
              v,
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton(
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
