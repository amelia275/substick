import 'package:flutter/material.dart';

class AppNavigation {
  static const List<String> routes = [
    '/home',
    '/read',
    '/podcast',
    '/chat',
    '/activity',
  ];

  static void onTabSelected(
    BuildContext context,
    int index,
  ) {
    if (index < 0 || index >= routes.length) return;

    final route = routes[index];

    if (ModalRoute.of(context)?.settings.name == route) {
      return;
    }

    Navigator.pushReplacementNamed(context, route);
  }
}
