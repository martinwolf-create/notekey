// lib/features/presentation/screens/forum/suchfind/suchfind_home_screen.dart
import 'package:flutter/material.dart';
import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/features/widgets/topbar/basic_topbar.dart';
import 'such/such_list_screen.dart';
import 'find/find_list_screen.dart';

class SuchFindHomeScreen extends StatelessWidget {
  const SuchFindHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hellbeige,
      appBar: const BasicTopBar(
          title: 'Such & Find', showBack: true, showMenu: false),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PrimaryBtn(
                  label: 'Suchen',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SuchListScreen()),
                  ),
                ),
                const SizedBox(height: 18),
                _PrimaryBtn(
                  label: 'Finden (mit Preis)',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FindListScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryBtn({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldbraun,
          foregroundColor: AppColors.hellbeige,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }
}
