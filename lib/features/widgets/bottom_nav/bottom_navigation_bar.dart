import 'package:flutter/material.dart';
import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/routes/app_routes.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
  });

  void _navigate(BuildContext context, int index) {
    // Wenn bereits aktiv → nichts tun
    if (index == currentIndex) return;

    switch (index) {
      case 0: // Home
        Navigator.pushNamed(context, AppRoutes.home);
        break;

      case 1: // Suche
        Navigator.pushNamed(context, '/search');
        break;

      case 2: // Forum
        Navigator.pushNamed(context, AppRoutes.forum);
        break;

      case 3: // Chat → ChatListScreen
        Navigator.pushNamed(context, AppRoutes.chat);
        break;

      case 4: // Profil
        Navigator.pushNamed(context, AppRoutes.profil);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const items = <_NavSpec>[
      _NavSpec(label: 'Home', icon: Icons.home_rounded),
      _NavSpec(label: 'Suche', icon: Icons.search_rounded),
      _NavSpec(label: 'Forum', icon: Icons.forum_rounded),
      _NavSpec(label: 'Chat', icon: Icons.chat_bubble_rounded),
      _NavSpec(label: 'Profil', icon: Icons.person_rounded),
    ];

    return Container(
      color: AppColors.dunkelbraun,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final active = currentIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _navigate(context, i),
                  child: _NavItem(spec: items[i], active: active),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavSpec {
  final String label;
  final IconData icon;
  const _NavSpec({required this.label, required this.icon});
}

class _NavItem extends StatelessWidget {
  final _NavSpec spec;
  final bool active;

  const _NavItem({
    required this.spec,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.goldbraun : AppColors.hellbeige;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(spec.icon, size: 22, color: color),
        const SizedBox(height: 4),
        Text(
          spec.label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
