import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

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
    final color = active ? AppColors.iconPrimary : AppColors.iconSecondary;

    switch (index) {
      case 0: // Home
        return Icon(
          active ? Icons.home_rounded : Icons.home_outlined,
          size: size,
          color: color,
        );
      case 1: // Read
        return Icon(
          active ? Icons.menu_book_rounded : Icons.menu_book_outlined,
          size: size,
          color: color,
        );
      case 2: // Podcasts
        return Icon(
          active ? Icons.headphones_rounded : Icons.headphones_outlined,
          size: size,
          color: color,
        );
      case 3: // Chat
        return Icon(
          active ? Icons.chat_bubble_rounded : Icons.chat_bubble_outline_rounded,
          size: size,
          color: color,
        );
      case 4: // Activity
        return Icon(
          active ? Icons.notifications_rounded : Icons.notifications_none_rounded,
          size: size,
          color: color,
        );
      default:
        return SizedBox(width: size, height: size);
    }
  }
}