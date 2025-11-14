import 'package:flutter/material.dart';
import 'package:notekey_app/features/themes/colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
  });

  void _navigate(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/search');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/forum');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/chat'); // ChatListScreen
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profil');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = const <_NavSpec>[
      _NavSpec(label: 'Home', icon: Icons.home_rounded),
      _NavSpec(label: 'Suche', icon: Icons.search_rounded),
      _NavSpec(label: 'Forum', icon: Icons.forum_rounded),
      _NavSpec(label: 'Chat', icon: Icons.chat_bubble_rounded),
      _NavSpec(label: 'Profil', icon: Icons.person_rounded),
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: 72,
        color: AppColors.dunkelbraun,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) {
            final active = currentIndex == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => _navigate(context, i),
                child: _NavItem(
                  spec: items[i],
                  active: active,
                ),
              ),
            );
          }),
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
        Icon(spec.icon, size: 24, color: color),
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
