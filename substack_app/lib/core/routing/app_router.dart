import 'package:flutter/material.dart';
import '../../features/activity/activity_screen.dart';
import '../../features/auth/login_password_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/welcome_screen.dart';
import '../../features/chat/chat_list_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/podcast/podcast_screen.dart';
import '../../features/read/read_screen.dart';
import '../../features/compose/compose_note_screen.dart';
import '../../features/profile/profile_screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    Widget page;

    switch (settings.name) {
      case '/':
        page = const SplashScreen();
        break;
      case '/welcome':
        page = const WelcomeScreen();
        break;
      case '/login':
        page = const LoginScreen();
        break;
      case '/login/password':
        final email = settings.arguments is String
            ? settings.arguments as String
            : '';
        page = LoginPasswordScreen(email: email);
        break;
      case '/register':
        page = const RegisterScreen();
        break;
      case '/home':
        page = const HomeScreen();
        break;
      case '/compose':
        page = const ComposeNoteScreen();
        break;
      case '/profile':
        page = const ProfileScreen();
        break;
      case '/read':
        page = const ReadScreen();
        break;
      case '/podcast':
        page = const PodcastScreen();
        break;
      case '/activity':
        page = const ActivityScreen();
        break;
      case '/chat':
        page = const ChatListScreen();
        break;
      default:
        page = const Scaffold(
          body: Center(child: Text('Halaman tidak ditemukan')),
        );
    }

    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}