import 'package:flutter/material.dart';
import '../../widgets/app_bottom_navigation.dart';
class PodcastScreen extends StatelessWidget {
  const PodcastScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Podcast')),
    body: const Center(child: Text('Daftar podcast akan dibuat di sini')),
    bottomNavigationBar: AppBottomNavigation(currentIndex: 2, onTap: (i) {
      const r = ['/home', '/read', '/podcast', '/chat', '/activity'];
      Navigator.pushReplacementNamed(context, r[i]);
    }),
  );
}
