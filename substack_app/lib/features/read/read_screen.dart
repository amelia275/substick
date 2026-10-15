import 'package:flutter/material.dart';
import '../../widgets/app_bottom_navigation.dart';
class ReadScreen extends StatelessWidget {
  const ReadScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Bacaan')),
    body: const Center(child: Text('Daftar artikel akan dibuat di sini')),
    bottomNavigationBar: AppBottomNavigation(currentIndex: 1, onTap: (i) {
      const r = ['/home', '/read', '/podcast', '/chat', '/activity'];
      Navigator.pushReplacementNamed(context, r[i]);
    }),
  );
}
