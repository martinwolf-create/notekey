import 'package:flutter/material.dart';

// Screens
import 'package:notekey_app/features/screens/profil/presentation/profile_screen.dart';
import 'package:notekey_app/features/screens/profil/presentation/edit_profile_screen.dart';

import 'package:notekey_app/features/screens/splash_theater/splash_theater_screen.dart';
import 'package:notekey_app/features/screens/splash_theater/splash_theater2.dart';
import 'package:notekey_app/features/screens/homescreen/home_screen.dart';
import 'package:notekey_app/features/screens/startscreen/startscreen.dart';
import 'package:notekey_app/features/screens/signup/signup_screen.dart';
import 'package:notekey_app/features/screens/signin/signin_screen.dart';
import 'package:notekey_app/core/detail_repo/chat/chat_home_screen.dart';
import 'package:notekey_app/features/screens/settings/settings_screen.dart';
import 'package:notekey_app/features/screens/forum/forum_home_screen.dart';
import 'package:notekey_app/features/screens/forum/veranstaltung/veranstaltung_list_screen.dart'
    as veranstaltungen_list;
import 'package:notekey_app/features/screens/forum/veranstaltung/veranstaltung_edit_screen.dart';
import 'package:notekey_app/features/screens/forum/todo/todo_screen.dart';
import 'package:notekey_app/features/screens/forum/suchfind/suchfind_home_screen.dart';
import 'package:notekey_app/features/screens/forum/suchfind/such/such_list_screen.dart';
import 'package:notekey_app/features/screens/forum/suchfind/find/find_list_screen.dart';
import 'package:notekey_app/features/screens/games/memory/memory_start_screen.dart';
import 'package:notekey_app/features/screens/games/memory/memory_game_screen.dart';

// Verify-Screen mit Alias (robust gegen Namenskonflikte)
import 'package:notekey_app/features/auth/verify_email_screen.dart'
    as verify_screen;

// Repository bis in Auth-Screens
import 'package:notekey_app/features/auth/auth_repository.dart';

class AppRoutes {
  // Splash / Start / Auth
  static const String splash = "/splash";
  static const String splash2 = "/splash2";
  static const String start = "/start";
  static const String signup = "/signup";
  static const String signin = "/signin";
  static const String authGate = "/auth_gate";

  // Hauptbereiche
  static const String home = "/home";
  static const String profil = "/profil";
  static const String editProfil = "/profil/edit";
  static const String chat = "/chat";
  static const String settings = "/settings";

  // Forum
  static const String forum = "/forum";
  static const String veranstaltungen = "/forum/veranstaltungen";
  static const String veranstaltungenList = "/forum/veranstaltungen_list";
  static const String todo = "/forum/todo";
  static const String suchfindHome = '/suchfind';
  static const String suchList = '/suchfind/such';
  static const String findList = '/suchfind/find';

  // Games
  static const String memory = '/memory';

  // E-Mail-Verify
  static const String verify = '/verify';

  static Route<dynamic> generateRoute(
      RouteSettings settings, AuthRepository auth) {
    switch (settings.name) {
      // ---------- Splash ----------
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashTheaterScreen());
      case AppRoutes.splash2:
        return MaterialPageRoute(builder: (_) => const SplashTheater2Screen());

      // ---------- Auth / Start ----------
      case AppRoutes.start:
        return MaterialPageRoute(builder: (_) => const StartScreen());
      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => SignUpScreen(auth: auth));
      case AppRoutes.signin:
        return MaterialPageRoute(builder: (_) => SignInScreen(auth: auth));

      // ---------- Hauptscreens ----------
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case AppRoutes.profil:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case AppRoutes.editProfil:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case AppRoutes.chat:
        return MaterialPageRoute(builder: (_) => const ChatHomeScreen());

      // ---------- Forum ----------
      case AppRoutes.forum:
        return MaterialPageRoute(builder: (_) => const ForumHomeScreen());
      case AppRoutes.veranstaltungen:
      case AppRoutes.veranstaltungenList:
        return MaterialPageRoute(
          builder: (_) =>
              const veranstaltungen_list.VeranstaltungenListScreen(),
        );
      case AppRoutes.todo:
        return MaterialPageRoute(builder: (_) => const TodoScreen());
      case AppRoutes.suchfindHome:
        return MaterialPageRoute(builder: (_) => const SuchFindHomeScreen());
      case AppRoutes.suchList:
        return MaterialPageRoute(builder: (_) => const SuchListScreen());
      case AppRoutes.findList:
        return MaterialPageRoute(builder: (_) => const FindListScreen());

      // ---------- Games ----------
      case AppRoutes.memory:
        return MaterialPageRoute(builder: (_) => const MemoryStartScreen());
      // oder: return MaterialPageRoute(builder: (_) => const MemoryGameScreen());

      // ---------- Verify ----------
      case AppRoutes.verify:
        return MaterialPageRoute(
            builder: (_) => const verify_screen.VerifyEmailScreen());

      // ---------- Default ----------
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Seite nicht gefunden")),
          ),
        );
    }
  }
}
