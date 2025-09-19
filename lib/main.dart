import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notekey_app/firebase_options.dart';

import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/features/routes/app_routes.dart';

// Repository-Pattern
import 'package:notekey_app/features/auth/auth_repository.dart';
import 'package:notekey_app/features/auth/firebase_auth_repository.dart';
import 'package:notekey_app/features/auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    name: 'NOTEkey-app',
  );

  final AuthRepository auth = FirebaseAuthRepository();
  runApp(MyApp(auth: auth));
}

class MyApp extends StatelessWidget {
  final AuthRepository auth;
  const MyApp({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(auth: auth),
      onGenerateRoute: (s) => AppRoutes.generateRoute(s, auth),
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.hellbeige,
      ),
    );
  }
}
