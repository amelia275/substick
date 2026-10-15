import 'package:flutter/material.dart';
import '../../widgets/app_bottom_navigation.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Beranda')),
    body: const Center(child: Text('Feed Notes akan dibuat di sini')),
    bottomNavigationBar: AppBottomNavigation(
      currentIndex: 0,
      onTap: (i) => _go(context, i),
    ),
  );
  static void _go(BuildContext context, int i) {
    const routes = ['/home', '/read', '/podcast', '/chat', '/activity'];
    Navigator.pushReplacementNamed(context, routes[i]);
  }
}
