import 'package:flutter/material.dart';

// Profil & Auth
import 'package:notekey_app/features/screens/profil/presentation/profile_screen.dart';
import 'package:notekey_app/features/screens/profil/presentation/edit_profile_screen.dart';
import 'package:notekey_app/features/screens/profil/presentation/profil_extern_screen.dart';

// Splash
import 'package:notekey_app/features/screens/splash_theater/splash_theater_screen.dart';
import 'package:notekey_app/features/screens/splash_theater/splash_theater2.dart';

// Start / Login
import 'package:notekey_app/features/screens/homescreen/home_screen.dart';
import 'package:notekey_app/features/screens/startscreen/startscreen.dart';
import 'package:notekey_app/features/screens/signup/signup_screen.dart';
import 'package:notekey_app/features/screens/signin/signin_screen.dart';

// Chat NEU
import 'package:notekey_app/features/chat/chat_list_screen.dart';

// Search
import 'package:notekey_app/features/screens/search/search_screen.dart';

// Settings & Notifications
import 'package:notekey_app/features/screens/settings/settings_screen.dart';
import 'package:notekey_app/features/screens/notifications/notifications_screen.dart';

// Forum / Veranstaltungen
import 'package:notekey_app/features/screens/forum/forum_home_screen.dart';
import 'package:notekey_app/features/screens/forum/veranstaltung/veranstaltung_list_screen.dart'
    as veranstaltungen_list;
import 'package:notekey_app/features/screens/forum/veranstaltung/veranstaltung_create_screen.dart';
import 'package:notekey_app/features/screens/forum/veranstaltung/veranstaltung_bearbeiten_screen.dart';
import 'package:notekey_app/features/screens/forum/todo/todo_screen.dart';
import 'package:notekey_app/features/screens/forum/suchfind/suchfind_home_screen.dart';
import 'package:notekey_app/features/screens/forum/suchfind/such/such_list_screen.dart';
import 'package:notekey_app/features/screens/forum/suchfind/find/find_list_screen.dart';

// Games
import 'package:notekey_app/features/screens/games/memory/memory_start_screen.dart';
import 'package:notekey_app/features/screens/games/memory/memory_game_screen.dart';

// Verify
import 'package:notekey_app/features/auth/verify_email_screen.dart'
    as verify_screen;

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
  static const String search = "/search";
  static const String profil = "/profil";
  static const String editProfil = "/profil/edit";
  static const String profilExtern = "/profil_extern";
  static const String chat = "/chat"; // NEU: ChatListScreen
  static const String settings = "/settings";
  static const String notifications = "/notifications";

  // Forum
  static const String forum = "/forum";
  static const String veranstaltungen = "/forum/veranstaltungen";
  static const String veranstaltungenList = "/forum/veranstaltungen_list";
  static const String veranstaltungBearbeiten =
      "/forum/veranstaltungen/bearbeiten";
  static const String todo = "/forum/todo";
  static const String suchfindHome = '/suchfind';
  static const String suchList = '/suchfind/such';
  static const String findList = '/suchfind/find';

  // Games
  static const String memory = '/memory';
  static const String memoryGame = '/memory/game';

  // Verify
  static const String verify = '/verify';

  static Route<dynamic> generateRoute(
      RouteSettings settings, AuthRepository auth) {
    switch (settings.name) {
      // ---------- SPLASH ----------
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashTheaterScreen());
      case AppRoutes.splash2:
        return MaterialPageRoute(builder: (_) => const SplashTheater2Screen());

      // ---------- AUTH ----------
      case AppRoutes.start:
        return MaterialPageRoute(builder: (_) => const StartScreen());
      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => SignUpScreen(auth: auth));
      case AppRoutes.signin:
        return MaterialPageRoute(builder: (_) => SignInScreen(auth: auth));

      // ---------- HAUPTBEREICHE ----------
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case AppRoutes.search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case AppRoutes.profil:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case AppRoutes.editProfil:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case AppRoutes.profilExtern:
        final userId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ProfilExternScreen(userId: userId),
        );
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case AppRoutes.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      // ---------- CHAT (NEU, RICHTIG!) ----------
      case AppRoutes.chat:
        return MaterialPageRoute(builder: (_) => const ChatListScreen());

      // ---------- FORUM ----------
      case AppRoutes.forum:
        return MaterialPageRoute(builder: (_) => const ForumHomeScreen());
      case AppRoutes.veranstaltungenList:
      case AppRoutes.veranstaltungen:
        return MaterialPageRoute(
          builder: (_) =>
              const veranstaltungen_list.VeranstaltungenListScreen(),
        );
      case AppRoutes.veranstaltungBearbeiten:
        return MaterialPageRoute(
          builder: (_) => VeranstaltungBearbeitenScreen(
            veranstaltungId: settings.arguments as String,
          ),
        );
      case AppRoutes.todo:
        return MaterialPageRoute(builder: (_) => const TodoScreen());
      case AppRoutes.suchfindHome:
        return MaterialPageRoute(builder: (_) => const SuchFindHomeScreen());
      case AppRoutes.suchList:
        return MaterialPageRoute(builder: (_) => const SuchListScreen());
      case AppRoutes.findList:
        return MaterialPageRoute(builder: (_) => const FindListScreen());

      // ---------- GAMES ----------
      case AppRoutes.memory:
        return MaterialPageRoute(builder: (_) => const MemoryStartScreen());
      case AppRoutes.memoryGame:
        return MaterialPageRoute(
          builder: (_) => const MemoryGameScreen(
            vsComputer: true,
            player1Name: 'Player 1',
          ),
        );

      // ---------- VERIFY ----------
      case AppRoutes.verify:
        return MaterialPageRoute(
            builder: (_) => const verify_screen.VerifyEmailScreen());

      // ---------- DEFAULT ----------
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Seite nicht gefunden")),
          ),
        );
    }
  }
}
