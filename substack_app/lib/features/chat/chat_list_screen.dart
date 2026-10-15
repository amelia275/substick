import 'package:flutter/material.dart';
import '../../widgets/app_bottom_navigation.dart';
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Obrolan')),
    body: const Center(child: Text('Daftar percakapan akan dibuat di sini')),
    bottomNavigationBar: AppBottomNavigation(currentIndex: 3, onTap: (i) {
      const r = ['/home', '/read', '/podcast', '/chat', '/activity'];
      Navigator.pushReplacementNamed(context, r[i]);
    }),
  );
}
