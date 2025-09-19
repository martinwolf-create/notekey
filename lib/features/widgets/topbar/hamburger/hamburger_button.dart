import 'package:flutter/material.dart';
import 'package:notekey_app/features/widgets/topbar/hamburger/hamburger_drawer.dart';

class HamburgerButton extends StatelessWidget {
  const HamburgerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu_rounded),
      iconSize: 28,
      color: Colors.white,
      padding: const EdgeInsets.only(right: 16.0),
      onPressed: () {
        Scaffold.of(context).openEndDrawer();
      },
    );
  }
}
