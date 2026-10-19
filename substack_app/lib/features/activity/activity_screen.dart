import 'package:flutter/material.dart';

import '../../core/routing/app_navigation.dart';
import '../../core/theme/app_colors.dart';
import '../../models/notification_item.dart';
import '../../services/notification_service.dart';
import '../../widgets/app_bottom_navigation.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  static const List<String> _filters = ['All', 'Replies', 'Restacks'];

  final NotificationService _notificationService = NotificationService();
  late Future<List<NotificationItem>> _notificationsFuture;

  int _selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _notificationService.fetchNotifications();
  }

  void _reloadNotifications() {
    setState(() {
      _notificationsFuture = _notificationService.fetchNotifications();
    });
  }

  List<NotificationItem> _filterItems(List<NotificationItem> notifications) {
    if (_selectedFilterIndex == 1) {
      return notifications
          .where((item) => item.type == 'comment')
          .toList();
    }
    if (_selectedFilterIndex == 2) {
      return notifications
          .where(
            (item) =>
                item.type == 'restack' ||
                (item.message?.toLowerCase().contains('restack') ?? false),
          )
          .toList();
    }
    return notifications;
  }

  String _formatTimeAgo(DateTime? date) {
    if (date == null) return '';
    final difference = DateTime.now().difference(date.toLocal());

    if (difference.inMinutes < 1) return 'now';
    if (difference.inHours < 1) return '${difference.inMinutes}m';
    if (difference.inDays < 1) return '${difference.inHours}h';
    if (difference.inDays < 7) return '${difference.inDays}d';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()}w';
    if (difference.inDays < 365) return '${(difference.inDays / 30).floor()}mo';
    return '${(difference.inDays / 365).floor()}y';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 64,
        titleSpacing: 16,
        title: const Text(
          'Activity',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          // Tombol statistik / trending
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFF2F2F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.trending_up,
                size: 21,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Tombol cari
          IconButton(
            onPressed: () {},
            tooltip: 'Search',
            icon: const Icon(
              Icons.search,
              size: 28,
              color: AppColors.textPrimary,
            ),
          ),
          // Avatar profil
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 16),
            child: GestureDetector(
              onTap: () {},
              child: const CircleAvatar(
                radius: 18,
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
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter chips: All | Replies | Restacks
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: List.generate(_filters.length, (index) {
                final isSelected = _selectedFilterIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilterIndex = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFEEEEEE)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _filters[index],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? AppColors.textPrimary
                              : const Color(0xFF686868),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const Divider(height: 1, thickness: 0.7, color: AppColors.divider),
          // Konten dari API melalui FutureBuilder
          Expanded(
            child: FutureBuilder<List<NotificationItem>>(
              future: _notificationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.wifi_off_outlined,
                            size: 42,
                            color: AppColors.iconSecondary,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Belum bisa memuat aktivitas.',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _reloadNotifications,
                            child: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final allItems = snapshot.data ?? <NotificationItem>[];
                final items = _filterItems(allItems);

                if (items.isEmpty) {
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async => _reloadNotifications(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 160),
                        _EmptyActivityState(
                          filterLabel: _filters[_selectedFilterIndex],
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async => _reloadNotifications(),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      thickness: 0.8,
                      color: AppColors.divider,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _ActivityNotificationTile(
                        item: item,
                        timeAgo: _formatTimeAgo(item.createdAt),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 4,
        onTap: (index) => AppNavigation.onTabSelected(context, index),
      ),
    );
  }
}

class _EmptyActivityState extends StatelessWidget {
  final String filterLabel;

  const _EmptyActivityState({required this.filterLabel});

  @override
  Widget build(BuildContext context) {
    String title = 'No activity yet';
    String subtitle = 'Likes, replies, and restacks will appear here.';

    if (filterLabel == 'Replies') {
      title = 'No replies yet';
      subtitle = 'Replies to your notes and posts will appear here.';
    } else if (filterLabel == 'Restacks') {
      title = 'No restacks yet';
      subtitle = 'Restacks of your notes and posts will appear here.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.notifications_none_outlined,
              size: 44,
              color: AppColors.iconSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityNotificationTile extends StatelessWidget {
  final NotificationItem item;
  final String timeAgo;

  const _ActivityNotificationTile({
    required this.item,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    final actorDisplayName =
        item.actorName ?? item.actorUsername ?? 'Pengguna';
    final previewText = item.displayContentPreview;
    final showFollowButton = item.type != 'follow';
    final showMoreButton = item.type == 'like' || item.type == 'comment';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ActivityTypeBadge(
            type: item.type,
            message: item.message,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris avatar, tombol Follow, dan tombol titik tiga
                Row(
                  children: [
                    CircleAvatar(
                      radius: 19,
                      backgroundColor: const Color(0xFFEAEAEA),
                      backgroundImage: item.actorAvatarUrl != null &&
                              item.actorAvatarUrl!.isNotEmpty
                          ? NetworkImage(item.actorAvatarUrl!)
                          : null,
                      child: item.actorAvatarUrl == null ||
                              item.actorAvatarUrl!.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 20,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    const Spacer(),
                    if (showFollowButton)
                      SizedBox(
                        height: 36,
                        child: FilledButton(
                          onPressed: () {},
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Follow',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    if (showMoreButton) ...[
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {},
                        child: const Icon(
                          Icons.more_horiz,
                          size: 22,
                          color: AppColors.iconSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                // Baris teks utama: Nama + aksi + waktu
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      height: 1.35,
                    ),
                    children: [
                      TextSpan(
                        text: actorDisplayName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: ' ${item.displayActionText} '),
                      if (timeAgo.isNotEmpty)
                        TextSpan(
                          text: timeAgo,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                ),
                // Cuplikan isi note / bio / artikel
                if (previewText != null && previewText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    previewText,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      color: item.type == 'like'
                          ? AppColors.textPrimary
                          : const Color(0xFF686868),
                      height: 1.35,
                    ),
                  ),
                ],
                // Media gambar (jika ada pada post terkait)
                if (item.postImageUrl != null &&
                    item.postImageUrl!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        Image.network(
                          item.postImageUrl!,
                          width: double.infinity,
                          height: 190,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: double.infinity,
                            height: 190,
                            color: const Color(0xFFEAEAEA),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.image_outlined,
                              color: AppColors.iconSecondary,
                              size: 36,
                            ),
                          ),
                        ),
                        if (item.publicationName != null &&
                            item.publicationName!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              item.publicationName!.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTypeBadge extends StatelessWidget {
  final String type;
  final String? message;

  const _ActivityTypeBadge({
    required this.type,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isLikedMessage =
        message != null && message!.toLowerCase().startsWith('liked');

    if (type == 'like' || isLikedMessage) {
      return Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          color: Color(0xFFFCE8EA),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.favorite,
          size: 19,
          color: Color(0xFFE05360),
        ),
      );
    }

    if (type == 'follow') {
      return Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          color: Color(0xFFFFEFE5),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.add,
          size: 22,
          color: AppColors.primary,
        ),
      );
    }

    if (type == 'comment') {
      return Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          color: Color(0xFFEEEEEE),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.chat_bubble_outline,
          size: 18,
          color: AppColors.textPrimary,
        ),
      );
    }

    return Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        color: Color(0xFFEEEEEE),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.repeat,
        size: 20,
        color: AppColors.textPrimary,
      ),
    );
  }
}
