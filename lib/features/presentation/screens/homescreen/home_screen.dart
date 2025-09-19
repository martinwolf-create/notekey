import 'package:flutter/material.dart';
import 'package:notekey_app/features/presentation/screens/profil/profil_screen.dart';
import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/features/widgets/topbar/basic_topbar.dart';
import 'package:notekey_app/features/widgets/bottom_nav/bottom_navigation_bar.dart';
import 'package:notekey_app/features/widgets/auth/launch_url.dart';
import 'package:notekey_app/features/widgets/promo/promo_banner.dart';
import 'package:notekey_app/features/presentation/screens/homescreen/home_widgets/profile_carousel.dart';
import 'package:notekey_app/features/presentation/screens/homescreen/home_widgets/home_button_grid.dart';
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

      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: BasicTopBar(
          title: 'NOTEkey',
          showBack: false,
          showMenu: true,
        ),
      ),

      // HamburgerButton (openEndDrawer)
      endDrawer: const HamburgerDrawer(),

      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 3)
            Navigator.pushNamed(context, AppRoutes.profil); // Profil
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
