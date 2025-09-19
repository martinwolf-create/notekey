import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:notekey_app/features/auth/auth_repository.dart';
import 'package:notekey_app/features/presentation/screens/startscreen/startscreen.dart';
import 'package:notekey_app/features/presentation/screens/homescreen/home_screen.dart';

class AuthGate extends StatelessWidget {
  final AuthRepository auth;
  const AuthGate({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Nicht eingeloggt → StartScreen
        if (!snapshot.hasData) {
          return const StartScreen();
        }

        // Eingeloggt → HomeScreen
        return HomeScreen();
      },
    );
  }
}

   // appId: '1:819722583382:ios:7c6cc08fbe5f302af7d929',
   // messagingSenderId: '819722583382',
   // projectId: 'notekey-58325',
   // storageBucket: 'notekey-58325.appspot.com',