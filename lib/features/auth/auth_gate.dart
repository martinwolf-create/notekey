import 'package:flutter/material.dart';
import 'package:notekey_app/features/auth/auth_repository.dart';
import 'package:notekey_app/routes/app_routes.dart';

class AuthGate extends StatelessWidget {
  final AuthRepository auth;
  const AuthGate({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: auth.authStateChanges(),
      builder: (context, snap) {
        final isLoggedIn = snap.hasData;
        return _StartScreen(
          isLoggedIn: isLoggedIn,
          onPrimaryButton: () {
            Navigator.pushReplacementNamed(
              context,
              isLoggedIn ? AppRoutes.home : AppRoutes.signin,
            );
          },
        );
      },
    );
  }
}

class _StartScreen extends StatelessWidget {
  final bool isLoggedIn;
  final VoidCallback onPrimaryButton;
  const _StartScreen({required this.isLoggedIn, required this.onPrimaryButton});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: onPrimaryButton,
            child: Text(isLoggedIn ? 'Weiter zum Home' : 'Jetzt einloggen'),
          ),
        ),
      );
}
