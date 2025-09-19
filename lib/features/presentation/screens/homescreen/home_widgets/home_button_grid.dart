import 'package:flutter/material.dart';
import 'package:notekey_app/features/routes/app_routes.dart';
import 'home_button.dart';

class HomeButtonGrid extends StatelessWidget {
  const HomeButtonGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 40,
      runSpacing: 40,
      children: [
        HomeButton(
            label: "Chat",
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.chat)), //chat
        HomeButton(
            label: "Game",
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.memory)), //games

        HomeButton(label: "Libery"),
        HomeButton(label: "NOTEscan"),
        HomeButton(label: "Learn"),
        HomeButton(
          label: "Forum",
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.forum),
        ),
      ],
    );
  }
}
