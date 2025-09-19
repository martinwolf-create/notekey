import 'package:flutter/material.dart';

// Screens
import 'package:notekey_app/features/presentation/screens/profil/profil_screen.dart';
import 'package:notekey_app/features/presentation/screens/splash_theater/splash_theater_screen.dart';
import 'package:notekey_app/features/presentation/screens/splash_theater/splash_theater2.dart';
import 'package:notekey_app/features/presentation/screens/homescreen/home_screen.dart';
import 'package:notekey_app/features/presentation/screens/startscreen/startscreen.dart';
import 'package:notekey_app/features/presentation/screens/signup/signup_screen.dart';
import 'package:notekey_app/features/presentation/screens/signin/signin_screen.dart';
import 'package:notekey_app/features/chat/chat_home_screen.dart';
import 'package:notekey_app/features/presentation/screens/settings/settings_screen.dart';
import 'package:notekey_app/features/presentation/screens/forum/forum_home_screen.dart';
import 'package:notekey_app/features/presentation/screens/forum/veranstaltung/veranstaltungen_list_screen.dart'
    as veranstaltungen_list;
import 'package:notekey_app/features/presentation/screens/forum/veranstaltung/veranstaltungen_edit_screen.dart';
import 'package:notekey_app/features/presentation/screens/forum/todo/todo_screen.dart';
import 'package:notekey_app/features/presentation/screens/forum/suchfind/suchfind_home_screen.dart';
import 'package:notekey_app/features/presentation/screens/forum/suchfind/such/such_list_screen.dart';
import 'package:notekey_app/features/presentation/screens/forum/suchfind/find/find_list_screen.dart';
import 'package:notekey_app/features/presentation/screens/games/memory/memory_start_screen.dart';
import 'package:notekey_app/features/presentation/screens/games/memory/memory_game_screen.dart';

// Verify-Screen mit Alias (robust gegen Namenskonflikte)
import 'package:notekey_app/features/presentation/screens/auth/verify_email_screen.dart'
    as verify_screen;

// Repository bis in Auth-Screens
import 'package:notekey_app/features/auth/auth_repository.dart';

class AppRoutes {
  static const String splash = "/splash";
  static const String splash2 = "/splash2";

  static const String start = "/start";
  static const String signup = "/signup";
  static const String signin = "/signin";
  static const String auth_gate = "/auth_gate";

  static const String home = "/home";
  static const String profil = "/profil";
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
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashTheaterScreen());
      case splash2:
        return MaterialPageRoute(builder: (_) => const SplashTheater2Screen());
      case start:
        return MaterialPageRoute(builder: (_) => const StartScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => SignUpScreen(auth: auth));
      case signin:
        return MaterialPageRoute(builder: (_) => SignInScreen(auth: auth));
      case home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case profil:
        return MaterialPageRoute(builder: (_) => ProfilScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case chat:
        return MaterialPageRoute(builder: (_) => const ChatHomeScreen());
      case forum:
        return MaterialPageRoute(builder: (_) => const ForumHomeScreen());
      case veranstaltungen:
      case veranstaltungenList:
        return MaterialPageRoute(
          builder: (_) =>
              const veranstaltungen_list.VeranstaltungenListScreen(),
        );
      case todo:
        return MaterialPageRoute(builder: (_) => const TodoScreen());
      case suchfindHome:
        return MaterialPageRoute(builder: (_) => const SuchFindHomeScreen());
      case suchList:
        return MaterialPageRoute(builder: (_) => const SuchListScreen());
      case findList:
        return MaterialPageRoute(builder: (_) => const FindListScreen());
      case memory:
        return MaterialPageRoute(builder: (_) => const MemoryStartScreen());
      // oder: return MaterialPageRoute(builder: (_) => const MemoryGameScreen());
      case verify:
        return MaterialPageRoute(
            builder: (_) => const verify_screen.VerifyEmailScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Seite nicht gefunden")),
          ),
        );
    }
  }
}
