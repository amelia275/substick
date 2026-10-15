import 'package:flutter/material.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const AppBottomNavigation({super.key, required this.currentIndex, required this.onTap});

  static const items = [
    (Icons.home_outlined, 'Beranda'),
    (Icons.menu_book_outlined, 'Bacaan'),
    (Icons.podcasts_outlined, 'Podcast'),
    (Icons.chat_bubble_outline, 'Obrolan'),
    (Icons.notifications_none, 'Aktivitas'),
  ];

  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: currentIndex,
    onDestinationSelected: onTap,
    destinations: items.map((item) => NavigationDestination(
      icon: Icon(item.$1), label: item.$2,
    )).toList(),
  );
}
