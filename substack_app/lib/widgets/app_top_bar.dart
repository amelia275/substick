
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onProfileTap;

  const AppTopBar({
    super.key,
    this.onSearchTap,
    this.onProfileTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Icon(
              Icons.stacked_bar_chart,
              color: Colors.white,
              size: 23,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: onSearchTap,
          tooltip: 'Cari',
          icon: const Icon(
            Icons.search,
            size: 27,
            color: AppColors.textPrimary,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 16),
          child: GestureDetector(
            onTap: onProfileTap,
            child: const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFE6E6E6),
              child: Icon(
                Icons.person,
                size: 21,
                color: Color(0xFF777777),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
