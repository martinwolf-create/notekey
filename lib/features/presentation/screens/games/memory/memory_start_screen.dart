import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekey_app/features/themes/colors.dart'; // AppColors
import 'memory_game_screen.dart';

class MemoryStartScreen extends StatefulWidget {
  const MemoryStartScreen({super.key});

  @override
  State<MemoryStartScreen> createState() => _MemoryStartScreenState();
}

class _MemoryStartScreenState extends State<MemoryStartScreen> {
  final _nameCtrl = TextEditingController(text: "");

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _go({required bool vsComputer}) {
    final name =
        _nameCtrl.text.trim().isEmpty ? "Spieler 1" : _nameCtrl.text.trim();
    HapticFeedback.selectionClick();
    Navigator.of(context).push(_scaleFadeRoute(
      MemoryGameScreen(vsComputer: vsComputer, player1Name: name),
    ));
  }

  PageRouteBuilder _scaleFadeRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, animation, __) {
        final fade =
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        final scale = Tween<double>(begin: .96, end: 1).animate(fade);
        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(scale: scale, child: page),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hellbeige,
      appBar: AppBar(
        backgroundColor: AppColors.dunkelbraun, // bleibt dunkelbraun
        centerTitle: true,
        iconTheme: const IconThemeData(
          // Farbe vom Pfeil
          color: AppColors.hellbeige,
        ),
        title: const Text(
          "Games",
          style: TextStyle(
            color: AppColors.hellbeige, // Schrift hellbeige
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "NOTEkey Memory",
              style: TextStyle(
                color: AppColors.dunkelbraun,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                letterSpacing: .4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Flip • Match • Score – 3D-Karten im NOTEkey-Look.",
              style: TextStyle(color: AppColors.dunkelbraun.withOpacity(.72)),
            ),
            const SizedBox(height: 22),

            // Name
            Container(
              decoration: BoxDecoration(
                color: AppColors.rosebeige,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.goldbraun.withOpacity(.35), width: 1.2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: TextField(
                controller: _nameCtrl,
                cursorColor: AppColors.dunkelbraun,
                decoration: InputDecoration(
                  hintText: "Dein Name",
                  border: InputBorder.none,
                  hintStyle:
                      TextStyle(color: AppColors.dunkelbraun.withOpacity(.55)),
                ),
                style: TextStyle(
                  color: AppColors.dunkelbraun,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // CTA 1
            _ModeButton(
              icon: Icons.smart_toy_rounded,
              title: "Gegen Computer starten",
              subtitle: "Perfekt zum Aufwärmen",
              onTap: () => _go(vsComputer: true),
            ),
            const SizedBox(height: 12),

            // CTA 2
            _ModeButton(
              icon: Icons.group_rounded,
              title: "Gegen lokalen Spieler",
              subtitle: "Hot-Seat – abwechselnd auf einem Gerät",
              onTap: () => _go(vsComputer: false),
            ),

            const Spacer(),
            Opacity(
              opacity: .7,
              child: Text(
                "Tipp: Lange drücken auf Karten = 3D-Tilt-Vorschau.",
                style: TextStyle(color: AppColors.dunkelbraun, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ModeButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.rosebeige, AppColors.hellbeige],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: AppColors.goldbraun.withOpacity(.35), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppColors.goldbraun.withOpacity(.16),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.dunkelbraun),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: AppColors.dunkelbraun,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          color: AppColors.dunkelbraun.withOpacity(.68),
                          fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.dunkelbraun),
          ],
        ),
      ),
    );
  }
}
