
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final String? name;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.size = 40,
    this.name,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final initial =
        name != null && name!.trim().isNotEmpty
            ? name!.trim()[0].toUpperCase()
            : '?';

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: hasImage ? NetworkImage(imageUrl!) : null,
      child: hasImage
          ? null
          : Text(
              initial,
              style: TextStyle(
                fontSize: size * 0.38,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
    );
  }
}