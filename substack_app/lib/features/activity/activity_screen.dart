import 'package:flutter/material.dart';
import '../../widgets/app_bottom_navigation.dart';
class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Aktivitas')),
    body: const Center(child: Text('Notifikasi akan dibuat di sini')),
    bottomNavigationBar: AppBottomNavigation(currentIndex: 4, onTap: (i) {
      const r = ['/home', '/read', '/podcast', '/chat', '/activity'];
      Navigator.pushReplacementNamed(context, r[i]);
    }),
  );
}
