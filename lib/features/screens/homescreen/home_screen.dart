import 'package:flutter/material.dart';
import 'package:notekey_app/features/screens/profil/presentation/profile_screen.dart';
import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/features/widgets/topbar/basic_topbar.dart';
import 'package:notekey_app/features/widgets/bottom_nav/bottom_navigation_bar.dart';
import 'package:notekey_app/features/widgets/auth/launch_url.dart';
import 'package:notekey_app/features/widgets/promo/promo_banner.dart';
import 'package:notekey_app/features/screens/homescreen/home_widgets/profile_carousel.dart';
import 'package:notekey_app/features/screens/homescreen/home_widgets/home_button_grid.dart';
import 'package:notekey_app/features/widgets/topbar/hamburger/hamburger_drawer.dart';
import 'package:notekey_app/features/routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List<String> profileImages = const [
    'assets/images/user1.png',
    'assets/images/user2.png',
    'assets/images/user3.png',
    'assets/images/user4.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hellbeige,
      appBar: AppBar(
        backgroundColor: AppColors.dunkelbraun,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.notifications_none_rounded,
              color: AppColors.hellbeige),
          onPressed: () {
            Navigator.pushNamed(context, '/notifications');
          },
        ),
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
          IconButton(
            icon: const Icon(Icons.menu, color: AppColors.hellbeige),
            onPressed: () {
              Scaffold.of(context).openEndDrawer(); // oder dein Hamburger-Menü
            },
          ),
        ],
      ),
      endDrawer: const HamburgerDrawer(),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 3) {
            Navigator.pushNamed(context, AppRoutes.profil); // Profil
          }
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
    );
  }
}
