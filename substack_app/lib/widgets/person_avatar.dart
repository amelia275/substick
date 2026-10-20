import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Avatar penulis: foto kalau ada, kalau tidak huruf pertama namanya.
class PersonAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double radius;

  const PersonAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 18,
  });

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final letter =
        trimmed.isEmpty ? '?' : trimmed.substring(0, 1).toUpperCase();
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFEAEAEA),
      foregroundImage: hasImage ? NetworkImage(imageUrl!) : null,
      onForegroundImageError: hasImage ? (_, __) {} : null,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: radius * 0.9,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}