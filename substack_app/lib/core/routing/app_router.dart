import 'package:flutter/material.dart';
import '../../features/home/home_screen.dart';
import '../../features/read/read_screen.dart';
import '../../features/podcast/podcast_screen.dart';
import '../../features/activity/activity_screen.dart';
import '../../features/chat/chat_list_screen.dart';
import '../../features/profile/profile_screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/home': return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/read': return MaterialPageRoute(builder: (_) => const ReadScreen());
      case '/podcast': return MaterialPageRoute(builder: (_) => const PodcastScreen());
      case '/activity': return MaterialPageRoute(builder: (_) => const ActivityScreen());
      case '/profile': return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case '/chat': return MaterialPageRoute(builder: (_) => const ChatListScreen());
      default: return MaterialPageRoute(builder: (_) => const Scaffold(
        body: Center(child: Text('Halaman tidak ditemukan')),
      ));
    }
  }
}
