import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/features/widgets/promo/promo_banner.dart';
import 'package:notekey_app/features/screens/homescreen/home_widgets/profile_carousel.dart';
import 'package:notekey_app/features/screens/homescreen/home_widgets/home_button_grid.dart';
import 'package:notekey_app/features/widgets/topbar/hamburger/hamburger_drawer.dart';
import 'package:notekey_app/features/widgets/bottom_nav/bottom_navigation_bar.dart';
import 'package:notekey_app/features/widgets/auth/launch_url.dart';
import 'package:notekey_app/routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  static const double _barHeight = 72; // visuelle Höhe deiner BottomBar

  final List<String> profileImages = const [
    'assets/images/user1.png',
    'assets/images/user2.png',
    'assets/images/user3.png',
    'assets/images/user4.png',
  ];

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final bottomPad = _barHeight + bottomSafe + 16; // Platz unterm Scroll

    return Scaffold(
      backgroundColor: AppColors.hellbeige,
      extendBody: true, // wichtig fürs saubere Zusammenspiel
      resizeToAvoidBottomInset: false, // kein Springen bei Keyboard

      // AppBar
      appBar: AppBar(
        backgroundColor: AppColors.dunkelbraun,
        elevation: 0,
        leading: const _NotificationBell(),
        title: const Text(
          'NOTEkey',
          style: TextStyle(
            color: AppColors.hellbeige,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: AppColors.hellbeige),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),

      endDrawer: const HamburgerDrawer(),

      // Body mit dynamischem Bottom-Padding, damit nichts unter die Bar rutscht
      body: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const PromoBanner(),
              const SizedBox(height: 20),
              ProfileCarousel(profileImages: profileImages),
              const SizedBox(height: 40),
              const HomeButtonGrid(),
              const SizedBox(height: 28),
              InkWell(
                onTap: openNoteKeyWebsite,
                child: const Text(
                  'NOTEkey.de',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: AppColors.dunkelbraun,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation bündig bis ganz nach unten
      // WICHTIG: Container außen, SafeArea innen  → keine helle „Lippe“
      bottomNavigationBar: Container(
        height: _barHeight + MediaQuery.of(context).padding.bottom,
        color: AppColors.dunkelbraun,
        child: SafeArea(
          top: false,
          child: BottomNavBar(
            currentIndex: 0,
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// 🔔 NotificationBell mit pulsierendem Glow-Badge + Halo
// --------------------------------------------------
class _NotificationBell extends StatefulWidget {
  const _NotificationBell();

  @override
  State<_NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<_NotificationBell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _pulse = Tween(begin: 0.7, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    final stream = FirebaseFirestore.instance
        .collection('notifications')
        .where('receiverId', isEqualTo: uid)
        .where('read', isEqualTo: false)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snap) {
        final count = snap.data?.docs.length ?? 0;

        if (count == 0) {
          _controller.stop();
        } else if (!_controller.isAnimating) {
          _controller.repeat(reverse: true);
        }

        return AnimatedBuilder(
          animation: _pulse,
          builder: (context, _) {
            final haloScale = _pulse.value;
            final haloBlur = 14.0 * _pulse.value;
            final haloSpread = 2.5 * _pulse.value;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                if (count > 0)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Center(
                        child: Container(
                          width: 36 * haloScale,
                          height: 36 * haloScale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.goldbraun.withOpacity(0.28),
                                blurRadius: haloBlur,
                                spreadRadius: haloSpread,
                              ),
                              BoxShadow(
                                color: AppColors.goldbraun.withOpacity(0.18),
                                blurRadius: haloBlur * 1.6,
                                spreadRadius: haloSpread * 1.2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(
                    Icons.notifications_rounded,
                    color: AppColors.hellbeige,
                    size: 26,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/notifications');
                  },
                ),
                if (count > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      width: 18 * _pulse.value,
                      height: 18 * _pulse.value,
                      decoration: BoxDecoration(
                        color: AppColors.goldbraun.withOpacity(0.95),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.goldbraun.withOpacity(0.85),
                            blurRadius: 6 * _pulse.value,
                            spreadRadius: 1.4 * _pulse.value,
                          ),
                          BoxShadow(
                            color: AppColors.goldbraun.withOpacity(0.35),
                            blurRadius: 12 * _pulse.value,
                            spreadRadius: 2.2 * _pulse.value,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        count > 9 ? '9+' : '$count',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
