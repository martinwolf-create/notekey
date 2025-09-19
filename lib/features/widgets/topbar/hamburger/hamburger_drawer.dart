import 'package:flutter/material.dart';
import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/features/routes/app_routes.dart';

class HamburgerDrawer extends StatelessWidget {
  const HamburgerDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.hellbeige,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppColors.dunkelbraun),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                "Menü",
                style: TextStyle(
                  color: AppColors.hellbeige,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          _tile(
            context,
            icon: Icons.person,
            label: "Profil",
            onTap: () {
              Navigator.of(context).maybePop();
              // Falls Route vorhanden:
              if (Navigator.canPop(context)) {
                // optional
              }
              Navigator.pushNamed(
                  context, AppRoutes.profil); // TODO: Route sicherstellen
            },
          ),
          _tile(
            context,
            icon: Icons.settings,
            label: "Settings",
            onTap: () {
              Navigator.of(context).maybePop();
              Navigator.pushNamed(
                  context, AppRoutes.settings); // TODO: Route sicherstellen
            },
          ),
          const Divider(height: 1),
          _tile(
            context,
            icon: Icons.logout,
            label: "Logout",
            onTap: () {
              Navigator.of(context).maybePop();
              // TODO: echte Logout-Logik (Session clear etc.)
              Navigator.pushReplacementNamed(context, AppRoutes.signin);
            },
          ),
        ],
      ),
    );
  }

  ListTile _tile(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.dunkelbraun),
      title: Text(label, style: const TextStyle(color: AppColors.dunkelbraun)),
      onTap: onTap,
    );
  }
}
