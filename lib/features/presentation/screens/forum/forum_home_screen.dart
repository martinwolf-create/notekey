import 'package:flutter/material.dart';
import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/features/widgets/topbar/basic_topbar.dart';
import 'package:notekey_app/features/routes/app_routes.dart';
import 'package:notekey_app/features/presentation/screens/forum/todo/todo_list_screen.dart';

class ForumHomeScreen extends StatelessWidget {
  const ForumHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hellbeige,
      appBar: const BasicTopBar(
        title: "Forum",
        showBack: true,
        showMenu: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ForumPrimaryButton(
                  label: "Veranstaltungen",
                  onTap: () => Navigator.pushNamed(
                      context, AppRoutes.veranstaltungenList),
                ),
                const SizedBox(height: 18),
                _ForumPrimaryButton(
                  label: "Such & Find",
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.suchfindHome),
                ),
                const SizedBox(height: 18),
                _ForumPrimaryButton(
                  label: "ToDo",
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TodoListScreen())),
                ),
              ],
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
  const _ForumPrimaryButton({required this.label, required this.onTap});

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
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        child: Text(label),
      ),
    );
  }
}
