import 'package:flutter/material.dart';
import '../../core/network/api_exception.dart';
import '../../core/routing/app_navigation.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/comment.dart';
import '../../models/post.dart';
import '../../services/interaction_service.dart';
import '../../services/post_service.dart';
import '../../state/current_user_state.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../widgets/app_top_bar.dart';
import '../notes_detail/notes_detail_screen.dart';
import '../notes_detail/reply_feed_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostService _postService = PostService();
  final InteractionService _interactionService = InteractionService();
  final Set<int> _busyLikes = {};
  final Set<int> _busyRestacks = {};

  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = _postService.fetchPosts();
    CurrentUserState.ensureLoaded();
  }

  void _reloadPosts() {
    setState(() {
      _postsFuture = _postService.fetchPosts();
    });
  }

  Future<void> _openCompose() async {
    final created = await Navigator.pushNamed(context, '/compose');
    if (!mounted) return;
    if (created == true) _reloadPosts();
  }

  Future<void> _openDetail(Post post) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => NotesDetailScreen(post: post)),
    );
    // Halaman detail menulis statusnya kembali ke objek post yang sama.
    if (mounted) setState(() {});
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _toggleLike(Post post) async {
    if (_busyLikes.contains(post.id)) return;

    final previousLiked = post.likedByMe;
    final previousCount = post.likesCount;
    final wantLiked = !previousLiked;

    _busyLikes.add(post.id);
    setState(() {
      post.likedByMe = wantLiked;
      post.likesCount = previousCount + (wantLiked ? 1 : -1);
    });

    try {
      final result =
          await _interactionService.setLike(post.id, liked: wantLiked);
      if (!mounted) return;
      setState(() {
        post.likedByMe = result.active;
        post.likesCount = result.count;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        post.likedByMe = previousLiked;
        post.likesCount = previousCount;
      });
      _showMessage(e.message);
    } finally {
      _busyLikes.remove(post.id);
    }
  }

  Future<void> _toggleRestack(Post post) async {
    if (_busyRestacks.contains(post.id)) return;

    final previousRestacked = post.restackedByMe;
    final previousCount = post.restacksCount;
    final wantRestacked = !previousRestacked;

    _busyRestacks.add(post.id);
    setState(() {
      post.restackedByMe = wantRestacked;
      post.restacksCount = previousCount + (wantRestacked ? 1 : -1);
    });

    try {
      final result = await _interactionService.setRestack(
        post.id,
        restacked: wantRestacked,
      );
      if (!mounted) return;
      setState(() {
        post.restackedByMe = result.active;
        post.restacksCount = result.count;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        post.restackedByMe = previousRestacked;
        post.restacksCount = previousCount;
      });
      _showMessage(e.message);
    } finally {
      _busyRestacks.remove(post.id);
    }
  }

  Future<void> _openReply(Post post) async {
    final created = await Navigator.push<Comment>(
      context,
      MaterialPageRoute(builder: (_) => ReplyScreen(post: post)),
    );
    if (created == null || !mounted) return;
    setState(() => post.commentsCount += 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        onSearchTap: () {},
        onProfileTap: () => Navigator.pushNamed(context, '/profile'),
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
                for (int i = 0; i < posts.length; i++) ...[
                  if (i == 4) const _PeopleToFollow(),
                  _NoteItem.fromPost(
                    posts[i],
                    onTap: () => _openDetail(posts[i]),
                    onLike: () => _toggleLike(posts[i]),
                    onComment: () => _openReply(posts[i]),
                    onRestack: () => _toggleRestack(posts[i]),
                  ),
                ],
                if (posts.length <= 4) const _PeopleToFollow(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: SizedBox(
        width: 54,
        height: 54,
        child: FloatingActionButton(
          onPressed: _openCompose,
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
        onTap: (index) => AppNavigation.onTabSelected(context, index),
      ),
    );
  }
}

const Color _cardColor = Color(0xFF3B3B3F);

class _NoteItem extends StatelessWidget {
  final String username;
  final String? avatarUrl;
  final String time;
  final String? content;
  final String? imageUrl;
  final String? cardTitle;
  final String? cardExcerpt;
  final String? cardImageUrl;
  final String? publication;
  final String? restackedBy;
  final String likes;
  final String comments;
  final String restacks;
  final bool liked;
  final bool restacked;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onRestack;

  const _NoteItem({
    required this.username,
    this.avatarUrl,
    required this.time,
    this.content,
    this.imageUrl,
    this.cardTitle,
    this.cardExcerpt,
    this.cardImageUrl,
    this.publication,
    this.restackedBy,
    required this.likes,
    required this.comments,
    required this.restacks,
    required this.liked,
    required this.restacked,
    this.onTap,
    this.onLike,
    this.onComment,
    this.onRestack,
  });

  /// 'article' dan 'quote' tampil sebagai kartu. 'note' tampil sebagai teks biasa.
  factory _NoteItem.fromPost(
    Post post, {
    VoidCallback? onTap,
    VoidCallback? onLike,
    VoidCallback? onComment,
    VoidCallback? onRestack,
  }) {
    final isCard = post.type == 'article' || post.type == 'quote';

    return _NoteItem(
      username: post.username ?? post.authorName ?? 'Pengguna',
      avatarUrl: post.authorAvatarUrl,
      time: formatPostTime(post.publishedAt),
      content: (isCard || post.content.isEmpty) ? null : post.content,
      imageUrl: isCard ? null : post.imageUrl,
      cardTitle: isCard ? post.title : null,
      cardExcerpt: isCard ? post.content : null,
      cardImageUrl: isCard ? post.imageUrl : null,
      publication: isCard ? post.publicationName : null,
      restackedBy: post.restackedBy,
      likes: formatCount(post.likesCount),
      comments: formatCount(post.commentsCount),
      restacks: formatCount(post.restacksCount),
      liked: post.likedByMe,
      restacked: post.restackedByMe,
      onTap: onTap,
      onLike: onLike,
      onComment: onComment,
      onRestack: onRestack,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.divider, width: 5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (restackedBy != null) ...[
              Text(
                '$restackedBy merestack',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
            ],
            _buildHeader(),
            if (content != null) ...[
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
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
            if (cardExcerpt != null) ...[
              const SizedBox(height: 12),
              _PostCard(
                publication: publication,
                title: cardTitle,
                excerpt: cardExcerpt!,
                imageUrl: cardImageUrl,
              ),
            ],
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NoteAction(
                  icon: liked ? Icons.favorite : Icons.favorite_border,
                  color: liked ? Colors.red : null,
                  label: likes,
                  onTap: onLike,
                ),
                _NoteAction(
                  icon: Icons.mode_comment_outlined,
                  label: comments,
                  onTap: onComment,
                ),
                _NoteAction(
                  icon: Icons.repeat,
                  color: restacked ? AppColors.primary : null,
                  label: restacks,
                  onTap: onRestack,
                ),
                const _NoteAction(icon: Icons.share_outlined),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _Avatar(name: username, imageUrl: avatarUrl),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  if (time.isNotEmpty) ...[
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '·',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 6),
                  ],
                  const Text(
                    'Berlangganan',
                    style: TextStyle(fontSize: 12, color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Icon(Icons.more_horiz, size: 20, color: AppColors.iconSecondary),
        const SizedBox(width: 14),
        const Icon(Icons.close, size: 20, color: AppColors.iconSecondary),
      ],
    );
  }
}

class _NoteAction extends StatelessWidget {
  final IconData icon;
  final String? label;
  final Color? color;
  final VoidCallback? onTap;

  const _NoteAction({
    required this.icon,
    this.label,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 24, top: 8, bottom: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color ?? AppColors.iconSecondary),
            if (label != null) ...[
              const SizedBox(width: 8),
              Text(
                label!,
                style: TextStyle(
                  fontSize: 13,
                  color: color ?? AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double radius;

  const _Avatar({required this.name, this.imageUrl, this.radius = 18});

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

class _PostCard extends StatelessWidget {
  final String? publication;
  final String? title;
  final String excerpt;
  final String? imageUrl;

  const _PostCard({
    this.publication,
    this.title,
    required this.excerpt,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final hasPublication = publication != null && publication!.isNotEmpty;
    final hasTitle = title != null && title!.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Positioned.fill(
            child: hasImage
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const ColoredBox(color: _cardColor),
                  )
                : const ColoredBox(color: _cardColor),
          ),
          if (hasImage)
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x00000000),
                      Color(0xB3000000),
                      Color(0xF2222226),
                    ],
                    stops: [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: hasImage ? 330 : 0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasPublication) ...[
                      Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              publication!.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              publication!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (hasTitle) ...[
                      Text(
                        title!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Padding(
                      padding: const EdgeInsets.only(right: 48),
                      child: Text(
                        excerpt,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xCCFFFFFF),
                          fontSize: 13.5,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            right: 12,
            bottom: 12,
            child: _BookmarkButton(),
          ),
        ],
      ),
    );
  }
}

class _BookmarkButton extends StatelessWidget {
  const _BookmarkButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0x40FFFFFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.bookmark_border, color: Colors.white, size: 22),
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
          bottom: BorderSide(color: AppColors.divider, width: 5),
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
                    'Orang untuk diikuti',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  'Lihat semua',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 232,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: people.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final person = people[index];

                return Container(
                  width: 164,
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.iconSecondary,
                        ),
                      ),
                      _Avatar(name: person.$1, radius: 34),
                      const SizedBox(height: 10),
                      Text(
                        person.$1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        person.$2,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11.5,
                          height: 1.3,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 34,
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
                            'Ikuti',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
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