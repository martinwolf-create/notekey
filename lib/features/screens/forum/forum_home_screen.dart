import 'package:flutter/material.dart';
import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/routes/app_routes.dart';
import 'package:notekey_app/features/screens/forum/todo/todo_list_screen.dart';
import 'package:notekey_app/features/screens/forum/notenscan/noten_scan_screen.dart';

class ForumHomeScreen extends StatelessWidget {
  const ForumHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hellbeige,

      // 🔥 Eigene AppBar mit funktionierendem Back-Button
      appBar: AppBar(
        backgroundColor: AppColors.dunkelbraun,
        foregroundColor: AppColors.hellbeige,
        title: const Text(
          "Forum",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              // Wenn es eine vorherige Seite im Stack gibt → normal zurück
              Navigator.pop(context);
            } else {
              // Wenn du z.B. über die BottomBar hier gelandet bist → zurück nach Home
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            }
          },
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),

                  // 🎫 Veranstaltungen
                  _ForumPrimaryButton(
                    label: "Veranstaltungen",
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.veranstaltungenList,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // 🔍 Such & Find
                  _ForumPrimaryButton(
                    label: "Such & Find",
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.suchfindHome,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // ✅ ToDo
                  _ForumPrimaryButton(
                    label: "ToDo",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TodoListScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // 🎵 NOTEscan (TFLite offline)
                  _ForumPrimaryButton(
                    label: "🎵 NOTEscan",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotenScanScreen(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ForumPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ForumPrimaryButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldbraun,
          foregroundColor: AppColors.hellbeige,
          elevation: 4,
          shadowColor: AppColors.goldbraun.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
