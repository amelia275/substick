import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../models/post.dart';
import '../../models/user_profile.dart';
import '../../services/user_service.dart';
import '../../widgets/user_avatar.dart';

const _orange = Color(0xFFFF6719);
const _grey = Color(0xFFF0F0F0);
const _greyDark = Color(0xFFE4E4E4);
const _greyText = Color(0xFF8A8A8A);

// Warna kartu dipilih dari id post supaya konsisten tiap dibuka
const _cardColors = [
  Color(0xFF244338),
  Color(0xFF3B4435),
  Color(0xFF333333),
  Color(0xFF4A3B2E),
  Color(0xFF6B4A38),
];

Color _cardColor(Post post) => _cardColors[post.id % _cardColors.length];

String _timeAgo(DateTime? date) {
  if (date == null) return '';
  final diff = DateTime.now().difference(date.toLocal());

  if (diff.inMinutes < 1) return 'now';
  if (diff.inHours < 1) return '${diff.inMinutes}m';
  if (diff.inDays < 1) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w';
  if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo';
  return '${(diff.inDays / 365).floor()}y';
}

String _fmt(int n) {
  if (n >= 1000) {
    final v = (n / 1000).toStringAsFixed(1);
    return '${v.endsWith('.0') ? v.substring(0, v.length - 2) : v}k';
  }
  return '$n';
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.userId = AppConstants.currentUserId});

  final int userId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  late Future<UserProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _userService.fetchProfile(widget.userId);
  }

  void _reload() {
    setState(() {
      _profileFuture = _userService.fetchProfile(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: FutureBuilder<UserProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: _orange),
            );
          }
          if (snapshot.hasError || snapshot.data == null) {
            return _ErrorState(onRetry: _reload);
          }
          return _ProfileContent(profile: snapshot.data!);
        },
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final likedIds = profile.likes.map((p) => p.id).toSet();
    final name = profile.user.name;

    return DefaultTabController(
      length: 5,
      child: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverToBoxAdapter(child: _ProfileHeader(profile: profile)),
          SliverAppBar(
            primary: false,
            pinned: true,
            toolbarHeight: 0,
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            bottom: const TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: Colors.black87,
              unselectedLabelColor: _greyText,
              indicatorColor: Colors.black87,
              dividerColor: Color(0xFFE0E0E0),
              overlayColor: WidgetStatePropertyAll(Colors.transparent),
              labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              unselectedLabelStyle: TextStyle(fontSize: 16),
              tabs: [
                Tab(text: 'Activity'),
                Tab(text: 'Posts'),
                Tab(text: 'Replies'),
                Tab(text: 'Likes'),
                Tab(text: 'Subscriptions'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          children: [
            // Activity: postingan sendiri + restack
            profile.activity.isEmpty
                ? const _EmptyState(
                    icon: Icons.bolt_outlined,
                    title: 'No activity yet',
                    subtitle: 'Your activity will appear here',
                  )
                : _PostList(
                    itemCount: profile.activity.length,
                    itemBuilder: (i) {
                      final item = profile.activity[i];
                      return _PostTile(
                        post: item.post,
                        liked: likedIds.contains(item.post.id),
                        at: item.at,
                        label: item.isRestack ? '$name restacked' : null,
                        labelIcon: Icons.repeat,
                      );
                    },
                  ),

            // Posts
            profile.posts.isEmpty
                ? const _EmptyState(
                    icon: Icons.description_outlined,
                    title: 'No posts yet',
                    subtitle: 'Your posts will appear here',
                  )
                : _PostList(
                    itemCount: profile.posts.length,
                    itemBuilder: (i) => _PostTile(
                      post: profile.posts[i],
                      liked: likedIds.contains(profile.posts[i].id),
                    ),
                  ),

            // Replies
            profile.replies.isEmpty
                ? const _EmptyState(
                    icon: Icons.library_books_outlined,
                    title: 'No replies yet',
                    subtitle: 'Your replies will appear here',
                  )
                : _PostList(
                    itemCount: profile.replies.length,
                    itemBuilder: (i) => _ReplyTile(
                      reply: profile.replies[i],
                      profile: profile,
                    ),
                  ),

            // Likes
            profile.likes.isEmpty
                ? const _EmptyState(
                    icon: Icons.favorite_border,
                    title: 'No likes yet',
                    subtitle: 'Posts you like will appear here',
                  )
                : _PostList(
                    itemCount: profile.likes.length,
                    itemBuilder: (i) => _PostTile(
                      post: profile.likes[i],
                      liked: true,
                      label: '$name liked',
                      labelIcon: Icons.favorite,
                    ),
                  ),

            // Subscriptions
            profile.subscriptions.isEmpty
                ? const _EmptyState(
                    icon: Icons.mail_outline,
                    title: 'No subscriptions yet',
                    subtitle: 'Publications you join will appear here',
                  )
                : _SubscriptionsTab(items: profile.subscriptions),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final user = profile.user;
    final bio = user.bio;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama, username, foto
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${user.username} · ${profile.postsCount} posts',
                      style: const TextStyle(fontSize: 16, color: _greyText),
                    ),
                  ],
                ),
              ),
              UserAvatar(
                size: 84,
                name: user.name,
                imageUrl: user.avatarUrl,
              ),
            ],
          ),
          if (bio != null && bio.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(bio, style: const TextStyle(fontSize: 16, height: 1.4)),
          ],
          const SizedBox(height: 16),

          // Add recommendation
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add recommendation'),
              style: FilledButton.styleFrom(
                backgroundColor: _grey,
                foregroundColor: Colors.black87,
                shape: const StadiumBorder(),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // See subscribers
          const Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: _greyDark,
                child: Icon(Icons.person, size: 16, color: _greyText),
              ),
              SizedBox(width: 8),
              Text('See subscribers',
                  style: TextStyle(fontSize: 16, color: _greyText)),
            ],
          ),
          const SizedBox(height: 16),

          // Share & Edit
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _orange,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {},
                  child: const Text('Share',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _grey,
                    foregroundColor: Colors.black87,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {},
                  child: const Text('Edit',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Creator stats
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _grey,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _greyDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.grid_view_outlined),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Creator stats',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                        Text('View stats',
                            style: TextStyle(fontSize: 16, color: _greyText)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: _greyText),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostList extends StatelessWidget {
  const _PostList({required this.itemCount, required this.itemBuilder});

  final int itemCount;
  final Widget Function(int index) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: itemCount,
      separatorBuilder: (_, __) => Container(height: 8, color: _grey),
      itemBuilder: (_, i) => itemBuilder(i),
    );
  }
}

/// Satu post (note / quote / article) lengkap dengan penulis dan aksi.
class _PostTile extends StatelessWidget {
  const _PostTile({
    required this.post,
    required this.liked,
    this.at,
    this.label,
    this.labelIcon,
  });

  final Post post;
  final bool liked;
  final DateTime? at;
  final String? label; // contoh: "Amelia restacked"
  final IconData? labelIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Row(
              children: [
                Icon(labelIcon, size: 20, color: _greyText),
                const SizedBox(width: 10),
                Text(label!,
                    style: const TextStyle(fontSize: 16, color: _greyText)),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              UserAvatar(size: 40, name: post.authorName),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.authorName ?? '',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    Text(_timeAgo(at ?? post.publishedAt),
                        style: const TextStyle(color: _greyText)),
                  ],
                ),
              ),
              const Icon(Icons.more_horiz, color: _greyText),
            ],
          ),
          const SizedBox(height: 12),
          _PostBody(post: post),
          const SizedBox(height: 12),
          Row(
            children: [
              _Action(
                icon: liked ? Icons.favorite : Icons.favorite_border,
                count: post.likesCount,
                active: liked,
              ),
              const SizedBox(width: 24),
              _Action(
                  icon: Icons.chat_bubble_outline, count: post.commentsCount),
              const SizedBox(width: 24),
              _Action(icon: Icons.repeat, count: post.restacksCount),
              const SizedBox(width: 24),
              const Icon(Icons.share_outlined, color: _greyText),
            ],
          ),
        ],
      ),
    );
  }
}

class _PostBody extends StatelessWidget {
  const _PostBody({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    switch (post.type) {
      case 'quote':
        return _QuoteCard(
          quote: post.content,
          source: post.publicationName ?? post.authorName ?? '',
          color: _cardColor(post),
        );
      case 'article':
        return _ArticleCard(post: post);
      default:
        // Note: teks biasa, gambar kalau ada
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.content,
                style: const TextStyle(fontSize: 18, height: 1.4)),
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  post.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ],
          ],
        );
    }
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({
    required this.quote,
    required this.source,
    required this.color,
  });

  final String quote;
  final String source;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote, size: 32, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            quote,
            style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 22,
                height: 1.4,
                color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(source,
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),
              const Icon(Icons.bookmark_border, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final hasCover = post.imageUrl != null && post.imageUrl!.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        color: _cardColor(post),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasCover)
              Image.network(
                post.imageUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                          radius: 12, backgroundColor: Colors.white24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          post.publicationName ?? post.authorName ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  if (post.title != null && post.title!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(post.title!,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            height: 1.3)),
                  ],
                  const SizedBox(height: 12),
                  Text(post.content,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.bookmark_border, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.count, this.active = false});

  final IconData icon;
  final int count;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? _orange : _greyText;
    return Row(
      children: [
        Icon(icon, color: color),
        if (count > 0) ...[
          const SizedBox(width: 6),
          Text(_fmt(count), style: TextStyle(fontSize: 16, color: color)),
        ],
      ],
    );
  }
}

class _ReplyTile extends StatelessWidget {
  const _ReplyTile({required this.reply, required this.profile});

  final ProfileReply reply;
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final parentAuthor = reply.post?.authorName;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(
                size: 40,
                name: profile.user.name,
                imageUrl: profile.user.avatarUrl,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.user.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    Text(
                      parentAuthor == null
                          ? _timeAgo(reply.createdAt)
                          : '${_timeAgo(reply.createdAt)}  •  Replying to $parentAuthor',
                      style: const TextStyle(color: _greyText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(reply.content,
              style: const TextStyle(fontSize: 18, height: 1.4)),
        ],
      ),
    );
  }
}

class _SubscriptionsTab extends StatelessWidget {
  const _SubscriptionsTab({required this.items});

  final List<ProfileSubscription> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        final hasLogo = item.logoUrl != null && item.logoUrl!.isNotEmpty;

        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 52,
              height: 52,
              color: _grey,
              alignment: Alignment.center,
              child: hasLogo
                  ? Image.network(
                      item.logoUrl!,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    )
                  : Text(
                      item.name.isEmpty ? '?' : item.name[0].toUpperCase(),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _greyText),
                    ),
            ),
          ),
          title: Text(item.name,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          subtitle: Text(item.isOwner ? 'Owner' : 'Free Subscriber',
              style: const TextStyle(fontSize: 16, color: _greyText)),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40),
          const SizedBox(height: 12),
          Text(title,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(fontSize: 16, color: _greyText)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 40, color: _greyText),
          const SizedBox(height: 12),
          const Text('Gagal memuat profil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Pastikan server Laravel sedang berjalan',
              style: TextStyle(fontSize: 14, color: _greyText)),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(backgroundColor: _orange),
            child: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }
}
