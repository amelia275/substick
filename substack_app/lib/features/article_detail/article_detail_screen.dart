import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/routing/app_navigation.dart';
import '../../core/theme/app_colors.dart';
import '../../models/post.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../podcast/podcast_player_controller.dart';
import '../podcast/podcast_player_screen.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Post post;

  const ArticleDetailScreen({
    super.key,
    required this.post,
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  static const List<String> _namaBulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  final ApiClient _apiClient = ApiClient();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _commentsKey = GlobalKey();

  late Post _post;
  List<PodcastCommentData> _comments = const [];

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _fetchPostDetail();
  }

  @override
  void dispose() {
    _apiClient.close();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchPostDetail() async {
    try {
      final res = await _apiClient.get('/posts/${_post.id}');
      if (!mounted) return;
      final data = res is Map<String, dynamic>
          ? (res['data'] as Map<String, dynamic>? ?? res)
          : null;
      if (data == null) return;

      final updatedPost = Post.fromJson(data);
      final rawComments = data['comments'] as List<dynamic>? ?? const [];
      final parsedComments = <PodcastCommentData>[];
      const avatarColors = [
        Color(0xFF3B4252),
        Color(0xFF9B2C2C),
        Color(0xFF2C7A7B),
        Color(0xFF6B46C1),
      ];

      for (var i = 0; i < rawComments.length; i++) {
        final item = rawComments[i];
        if (item is Map<String, dynamic>) {
          final userMap = item['user'] as Map<String, dynamic>?;
          final username = (userMap?['username'] as String?) ??
              (userMap?['name'] as String?) ??
              'user';
          parsedComments.add(
            PodcastCommentData(
              username: username,
              dateText: 'BARU SAJA',
              likedByAuthor:
                  'Disukai oleh ${updatedPost.authorName ?? 'Penulis'}',
              content: (item['content'] as String?) ?? '',
              likesCount: 12 + (i * 5),
              avatarColor: avatarColors[i % avatarColors.length],
            ),
          );
        }
      }

      setState(() {
        _post = updatedPost;
        _comments = parsedComments;
      });
    } catch (_) {
      // Gunakan data Post awal jika detail tambahan gagal dimuat
    }
  }

  String _formatPublishedDate(DateTime? date) {
    if (date == null) return '19 Oktober pukul 08.30';
    final d = date.toLocal();
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${_namaBulan[d.month - 1]} pukul $hh.$mm';
  }

  String _formatRelativeShort(DateTime? date) {
    if (date == null) return '1bln';
    final diff = DateTime.now().difference(date.toLocal());
    if (diff.inDays >= 30) {
      return '${(diff.inDays / 30).floor()}bln';
    }
    if (diff.inDays >= 1) {
      return '${diff.inDays}hr';
    }
    if (diff.inHours >= 1) {
      return '${diff.inHours}jam';
    }
    return 'baru saja';
  }

  String _compactNumber(int n) {
    if (n < 1000) return '$n';
    final v = (n / 1000).toStringAsFixed(1);
    final trimmed = v.endsWith('.0') ? v.substring(0, v.length - 2) : v;
    return '${trimmed.replaceAll('.', ',')}k';
  }

  (String subtitle, String body) _splitSubtitleAndBody(String rawContent) {
    final paragraphs = rawContent
        .split('\n\n')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    if (paragraphs.length >= 2 && paragraphs.first.length <= 140) {
      return (paragraphs.first, paragraphs.skip(1).join('\n\n'));
    }
    final firstSentence = rawContent.split('.').first.trim();
    final subtitle = firstSentence.length <= 110
        ? firstSentence
        : '${firstSentence.substring(0, 107)}...';
    return (subtitle, rawContent.trim());
  }

  void _openInPodcastPlayer() {
    final (subtitle, body) = _splitSubtitleAndBody(_post.content);
    final author = _post.authorName ?? _post.username ?? 'Penulis';
    final publication = _post.publicationName ?? author;
    final cover = _post.imageUrl ??
        'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=600&q=80';

    // Hitung estimasi durasi suara dari panjang artikel (minimal 6 menit)
    final wordCount =
        body.trim().isEmpty ? 120 : body.trim().split(RegExp(r'\s+')).length;
    final estimatedSeconds = (wordCount * 2).clamp(396, 1800);

    final episodeItem = PodcastEpisodeItem(
      id: 'post-${_post.id}',
      showTitle: publication,
      publicationName: publication.toUpperCase(),
      authorName: author,
      timeAgo: _formatRelativeShort(_post.publishedAt),
      publishedDateText: _formatPublishedDate(_post.publishedAt),
      title: _post.title ?? subtitle,
      subtitle: subtitle,
      articleBody: body,
      captionSnippet: subtitle,
      coverUrl: cover,
      thumbnailUrl: cover,
      totalDurationSeconds: estimatedSeconds,
      likesCount: _post.likesCount,
      restacksCount: _post.restacksCount,
      comments: _comments,
    );

    PodcastPlayerController.instance.playEpisode(episodeItem);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PodcastPlayerScreen(),
      ),
    );
  }

  void _scrollToComments() {
    final ctx = _commentsKey.currentContext;
    if (ctx != null && ctx.mounted) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final author = _post.authorName ?? _post.username ?? 'Penulis';
    final publication = (_post.publicationName ?? author).toUpperCase();
    final (subtitle, bodyText) = _splitSubtitleAndBody(_post.content);
    final paragraphs = bodyText
        .split('\n\n')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    final cover = _post.imageUrl ??
        'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=800&q=80';
    final commentsCount =
        _comments.isNotEmpty ? _comments.length : _post.commentsCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Center(
            child: SizedBox(
              height: 38,
              child: FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Berlangganan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            children: [
              // Nama publikasi / penulis huruf kapital
              Text(
                publication,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF757575),
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 8),

              // Judul utama artikel
              Text(
                _post.title ?? subtitle,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.2,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 10),

              // Subjudul / ringkasan
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 17,
                  color: Color(0xFF757575),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),

              // Baris Profil Penulis + Tombol "▶ Dengarkan" di kanan
              Row(
                children: [
                  CircleAvatar(
                    radius: 19,
                    backgroundColor: const Color(0xFFE6E6E6),
                    backgroundImage:
                        _post.imageUrl != null ? NetworkImage(cover) : null,
                    child: _post.imageUrl == null
                        ? const Icon(
                            Icons.person,
                            size: 21,
                            color: Color(0xFF777777),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          author,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatPublishedDate(_post.publishedAt),
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _openInPodcastPlayer,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_arrow,
                            size: 19,
                            color: AppColors.textPrimary,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Dengarkan',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(
                  height: 1,
                  thickness: 0.8,
                  color: AppColors.divider,
                ),
              ),

              // Isi paragraf artikel
              for (int i = 0; i < paragraphs.length; i++) ...[
                Text(
                  paragraphs[i],
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.textPrimary,
                    height: 1.62,
                    fontFamily: 'Georgia',
                  ),
                ),
                const SizedBox(height: 18),
                if (i == 0 && _post.imageUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _post.imageUrl!,
                      width: double.infinity,
                      height: 215,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ],

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(
                  height: 1,
                  thickness: 0.8,
                  color: AppColors.divider,
                ),
              ),

              // Bagian Komentar
              Container(
                key: _commentsKey,
                child: Text(
                  '$commentsCount komentar',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: Color(0xFFE6E6E6),
                      child: Icon(
                        Icons.person,
                        size: 17,
                        color: Color(0xFF777777),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Tinggalkan komentar',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              for (int i = 0; i < _comments.length; i++) ...[
                _ArticleCommentItem(comment: _comments[i]),
                if (i < _comments.length - 1) const SizedBox(height: 20),
              ],
            ],
          ),

          // Floating bar Like / Komentar / Restack / Share di bawah
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      size: 21,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _compactNumber(_post.likesCount),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 22),
                    GestureDetector(
                      onTap: _scrollToComments,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline,
                            size: 20,
                            color: AppColors.textPrimary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$commentsCount',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 22),
                    const Icon(
                      Icons.repeat,
                      size: 21,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _compactNumber(_post.restacksCount),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 22),
                    const Icon(
                      Icons.share_outlined,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 1,
        onTap: (index) => AppNavigation.onTabSelected(context, index),
      ),
    );
  }
}

class _ArticleCommentItem extends StatelessWidget {
  final PodcastCommentData comment;

  const _ArticleCommentItem({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: comment.avatarColor,
          child: const Icon(
            Icons.person,
            size: 19,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comment.username,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                comment.dateText,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF757575),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                comment.content,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
