import 'package:flutter/material.dart';
import '../models/user.dart';
import '../state/current_user_state.dart';

const Color _avatarGreen = Color(0xFF5E9E43);

class CurrentUserAvatar extends StatelessWidget {
  final double radius;

  const CurrentUserAvatar({super.key, this.radius = 16});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<User?>(
      valueListenable: CurrentUserState.user,
      builder: (context, user, _) {
        if (user == null) {
          return CircleAvatar(
            radius: radius,
            backgroundColor: const Color(0xFFE6E6E6),
            child: Icon(
              Icons.person,
              size: radius * 1.3,
              color: const Color(0xFF777777),
            ),
          );
        }

        final name = user.name.trim();
        final letter =
            name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();
        final hasImage = user.avatarUrl != null && user.avatarUrl!.isNotEmpty;

        return CircleAvatar(
          radius: radius,
          backgroundColor: _avatarGreen,
          foregroundImage: hasImage ? NetworkImage(user.avatarUrl!) : null,
          onForegroundImageError: hasImage ? (_, __) {} : null,
          child: Text(
            letter,
            style: TextStyle(
              color: Colors.white,
              fontSize: radius * 1.1,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }
}