import 'package:flutter/material.dart';

class SubstackNavIcon extends StatelessWidget {
  final int index;
  final bool active;
  final double size;

  const SubstackNavIcon({
    super.key,
    required this.index,
    required this.active,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    final color = Colors.black;

    switch (index) {
      case 0: // Home
        return Icon(
          active ? Icons.home_rounded : Icons.home_outlined,
          size: size,
          color: color,
        );
      case 1: // Read
        return Icon(
          Icons.menu_book_outlined,
          size: size,
          color: color,
        );
      case 2: // Podcasts
        return Icon(
          Icons.headphones_outlined,
          size: size,
          color: color,
        );
      case 3: // Chat
        return Icon(
          Icons.chat_bubble_outline_rounded,
          size: size,
          color: color,
        );
      case 4: // Activity
        return Icon(
          Icons.notifications_none_rounded,
          size: size,
          color: color,
        );
      default:
        return SizedBox(width: size, height: size);
    }
  }
}
