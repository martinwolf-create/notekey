import 'package:flutter/material.dart';
import 'package:notekey_app/features/themes/colors.dart';

class ForgotPasswordLink extends StatelessWidget {
  final VoidCallback onTap;

  const ForgotPasswordLink({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: onTap,
        child: const Text(
          'Passwort vergessen?',
          style: TextStyle(
            fontSize: 12,
            decoration: TextDecoration.underline,
            color: AppColors.dunkelbraun,
          ),
        ),
      ),
    );
  }
}
