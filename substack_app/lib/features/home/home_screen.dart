import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/post.dart';
import '../../services/post_service.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../widgets/app_top_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostService _postService = PostService();

  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = _postService.fetchPosts();
  }

  void _reloadPosts() {
    setState(() {
      _postsFuture = _postService.fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        onSearchTap: () {},
        onProfileTap: () {},
      ),
      body: FutureBuilder<List<Post>>(
        future: _postsFuture,
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
                      'Belum bisa memuat postingan.',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
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
                      onPressed: _reloadPosts,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final posts = snapshot.data ?? <Post>[];

          if (posts.isEmpty) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => _reloadPosts(),
              child: ListView(
                children: const [
                  SizedBox(height: 180),
                  Center(child: Text('Belum ada postingan.')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => _reloadPosts(),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (final post in posts)
                  _NoteItem(
                    username: post.username ?? post.authorName ?? 'Pengguna',
                    time: post.publishedAt == null
                        ? ''
                        : _formatPostTime(post.publishedAt!),
                    content: post.content.isEmpty ? null : post.content,
                    imageUrl: post.imageUrl,
                    likes: '${post.likesCount}',
                    comments: '${post.commentsCount}',
                    restacks: '${post.restacksCount}',
                  ),
                const _PeopleToFollow(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: SizedBox(
        width: 54,
        height: 54,
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: const Color(0xFFFF6719),
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.add, size: 25),
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 0,
        onTap: (index) {
          // TODO: Hubungkan dengan AppRouter.
        },
      ),
    );
  }

  String _formatPostTime(DateTime date) {
    final difference = DateTime.now().difference(date.toLocal());

    if (difference.inMinutes < 1) return 'Baru saja';
    if (difference.inHours < 1) return '${difference.inMinutes}m';
    if (difference.inDays < 1) return '${difference.inHours}h';
    if (difference.inDays < 7) return '${difference.inDays}d';

    return '${date.day}/${date.month}/${date.year}';
  }
}

class _NoteItem extends StatelessWidget {
  final String username;
  final String time;
  final String? content;
  final String? imageUrl;
  final String? quote;
  final String? publication;
  final String? restackedBy;
  final String likes;
  final String comments;
  final String restacks;

  const _NoteItem({
    required this.username,
    required this.time,
    this.content,
    this.imageUrl,
    this.quote,
    this.publication,
    this.restackedBy,
    required this.likes,
    required this.comments,
    required this.restacks,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
            width: 5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (restackedBy != null) ...[
            Text(
              '$restackedBy restacked',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFEAEAEA),
                child: Icon(Icons.person, size: 20, color: Colors.grey),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '·',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Subscribe',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_horiz, size: 12, color: AppColors.iconSecondary),
              const SizedBox(width: 8),
              const Icon(Icons.close, size: 19, color: AppColors.iconSecondary),
            ],
          ),
          if (content != null) ...[
            const SizedBox(height: 14),
            Text(
              content!,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: AppColors.textPrimary,
              ),
            ),
          ],
          if (imageUrl != null) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 190,
                  color: const Color(0xFFF5F5F5),
                  alignment: Alignment.center,
                  child: const Text('Gambar tidak dapat dimuat'),
                ),
              ),
            ),
          ],
          if (quote != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 220),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF79300E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 38, right: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.format_quote,
                          color: Colors.white,
                          size: 26,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          quote!,
                          style: const TextStyle(
                            fontSize: 20,
                            height: 1.4,
                            fontFamily: 'serif',
                            color: Colors.white,
                          ),
                        ),
                        if (publication != null) ...[
                          const SizedBox(height: 24),
                          Text(
                            publication!,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.3,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  Positioned(
                    right: 0,
                    bottom: 38,
                    child: IconButton(
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      icon: const Icon(
                        Icons.bookmark_border,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _NoteAction(
                icon: Icons.favorite_border,
                label: likes,
                onTap: () {},
              ),
              _NoteAction(
                icon: Icons.mode_comment_outlined,
                label: comments,
                onTap: () {},
              ),
              _NoteAction(
                icon: Icons.repeat,
                label: restacks,
                onTap: () {},
              ),
              _NoteAction(
                icon: Icons.share_outlined,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoteAction extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback onTap;

  const _NoteAction({
    required this.icon,
    this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, top: 5, bottom: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.iconSecondary),
            if (label != null) ...[
              const SizedBox(width: 7),
              Text(
                label!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PeopleToFollow extends StatelessWidget {
  const _PeopleToFollow();

  @override
  Widget build(BuildContext context) {
    final people = [
      ('Anies Baswedan', 'Anies Baswedan'),
      ('Azka Adziman', 'Azka Adziman'),
      ('hello.mein', 'Hainthology'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
            width: 5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'People to follow',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  'See all',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 175,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: people.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final person = people[index];

                return Container(
                  width: 150,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Color(0xFFEAEAEA),
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: AppColors.iconSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        person.$1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        person.$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Follow',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
