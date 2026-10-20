import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'podcast_player_controller.dart';

const List<PodcastCommentData> _sampleComments = [
  PodcastCommentData(
    username: 'nanash',
    dateText: 'SEP 14',
    likedByAuthor: 'Disukai oleh Amelia Masayu',
    content:
        'Iseng-iseng dengerin dan baca ini karena gabut ehh malah relate banget sama keamanan chat yang kita pakai sehari-hari.',
    likesCount: 93,
    repliesSummary: '2 replies by Amelia Masayu and others',
    avatarColor: Color(0xFF3B4252),
  ),
  PodcastCommentData(
    username: 'claire',
    dateText: 'SEP 15',
    likedByAuthor: 'Disukai oleh Amelia Masayu',
    content:
        'Penjelasan perbandingan enkripsi Signal, WhatsApp, dan Telegram-nya sangat jelas dan mudah dipahami!',
    likesCount: 41,
    repliesSummary: '1 reply by Amelia Masayu',
    avatarColor: Color(0xFF9B2C2C),
  ),
];

class PodcastPlayerScreen extends StatefulWidget {
  const PodcastPlayerScreen({super.key});

  @override
  State<PodcastPlayerScreen> createState() => _PodcastPlayerScreenState();
}

class _PodcastPlayerScreenState extends State<PodcastPlayerScreen> {
  final PodcastPlayerController _controller = PodcastPlayerController.instance;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final GlobalKey _commentsKey = GlobalKey();

  bool _showArticleView = false;
  double _sheetExtent = 0.54;

  static const double _minSheetExtent = 0.54;
  static const double _maxSheetExtent = 0.90;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onPlayerChanged);
    _sheetController.addListener(_onSheetChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onPlayerChanged);
    _sheetController.removeListener(_onSheetChanged);
    _sheetController.dispose();
    super.dispose();
  }

  void _onPlayerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onSheetChanged() {
    if (!_sheetController.isAttached) return;
    final nextExtent = _sheetController.size;
    if ((nextExtent - _sheetExtent).abs() > 0.005 && mounted) {
      setState(() {
        _sheetExtent = nextExtent;
      });
    }
  }

  void _toggleSheetExpand() {
    if (!_sheetController.isAttached) return;
    final isExpanded = _sheetExtent > 0.72;
    _sheetController.animateTo(
      isExpanded ? _minSheetExtent : _maxSheetExtent,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrollToComments() {
    if (!_showArticleView) {
      setState(() {
        _showArticleView = true;
        _sheetExtent = _maxSheetExtent;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_sheetController.isAttached) {
          _sheetController.jumpTo(_maxSheetExtent);
        }
        final ctx = _commentsKey.currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
          );
        }
      });
      return;
    }

    if (_sheetController.isAttached && _sheetExtent < _maxSheetExtent) {
      _sheetController.animateTo(
        _maxSheetExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      final ctx = _commentsKey.currentContext;
      if (ctx != null && ctx.mounted) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  String _formatSpeed(double speed) {
    if (speed == speed.roundToDouble()) {
      return '${speed.toInt()}x';
    }
    return '${speed}x';
  }

  @override
  Widget build(BuildContext context) {
    final episode = _controller.currentEpisode;
    if (episode == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF1F201C),
        body: Center(
          child: Text(
            'Tidak ada episode yang sedang diputar',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1F201C),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF393B33),
              Color(0xFF252621),
              Color(0xFF1A1B17),
            ],
          ),
        ),
        child: SafeArea(
          bottom: !_showArticleView,
          child: _showArticleView
              ? _buildInteractiveArticleSheetView(context, episode)
              : _buildFullPlayerView(context, episode),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (_showArticleView) {
                setState(() {
                  _showArticleView = false;
                  _sheetExtent = _minSheetExtent;
                });
              } else {
                Navigator.of(context).maybePop();
              }
            },
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 32,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.cast,
              color: Colors.white,
              size: 23,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_horiz,
              color: Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  // Tampilan penuh (Screenshot 1)
  Widget _buildFullPlayerView(
    BuildContext context,
    PodcastEpisodeItem episode,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < 680;
        final coverSize = isCompact ? 156.0 : 192.0;
        final playBtnSize = isCompact ? 64.0 : 74.0;

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  _buildTopBar(context),
                  const Spacer(),
                  _CoverWithWaveform(
                    coverUrl: episode.coverUrl,
                    size: coverSize,
                    isPlaying: _controller.isPlaying,
                  ),
                  SizedBox(height: isCompact ? 16 : 24),
                  _buildTransportControls(buttonSize: playBtnSize),
                  const Spacer(),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        episode.captionSnippet,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isCompact ? 12 : 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            episode.coverUrl,
                            width: 34,
                            height: 34,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 34,
                              height: 34,
                              color: Colors.white24,
                              child: const Icon(
                                Icons.podcasts,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            episode.showTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          episode.timeAgo,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Tingkatkan',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            episode.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showArticleView = true;
                                _sheetExtent = _minSheetExtent;
                              });
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Baca selengkapnya',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.65),
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.chevron_right,
                                  size: 20,
                                  color: Colors.white.withValues(alpha: 0.65),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isCompact ? 10 : 14),
                  _buildProgressBar(),
                  SizedBox(height: isCompact ? 10 : 14),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: _controller.cycleSpeed,
                          child: SizedBox(
                            width: 44,
                            child: Text(
                              _formatSpeed(_controller.playbackSpeed),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.favorite_border,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${episode.likesCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 18),
                              GestureDetector(
                                onTap: _scrollToComments,
                                child: Icon(
                                  Icons.chat_bubble_outline,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  size: 19,
                                ),
                              ),
                              const SizedBox(width: 18),
                              const Icon(
                                Icons.repeat,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${episode.restacksCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 18),
                              const Icon(
                                Icons.share_outlined,
                                color: Colors.white,
                                size: 19,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.format_list_bulleted,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Tampilan Baca Selengkapnya yang bisa ditarik ke atas & ke bawah (DraggableScrollableSheet)
  Widget _buildInteractiveArticleSheetView(
    BuildContext context,
    PodcastEpisodeItem episode,
  ) {
    // 0.0 saat setengah layar (0.54), 1.0 saat ditarik penuh ke atas (0.90)
    final collapseProgress = ((_sheetExtent - _minSheetExtent) /
            (_maxSheetExtent - _minSheetExtent))
        .clamp(0.0, 1.0);
    final isTopBarCollapsed = collapseProgress > 0.65;

    return Stack(
      children: [
        // Bagian atas: berubah dari Medium Player ke Compact Mini Header saat sheet ditarik ke atas
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isTopBarCollapsed
                ? _buildCollapsedTopPlayerBar(episode)
                : Column(
                    key: const ValueKey('expanded-top-player'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTopBar(context),
                      const SizedBox(height: 2),
                      _CoverWithWaveform(
                        coverUrl: episode.coverUrl,
                        size: 112,
                        isPlaying: _controller.isPlaying,
                      ),
                      const SizedBox(height: 10),
                      _buildTransportControls(buttonSize: 58),
                      const SizedBox(height: 6),
                      _buildProgressBar(),
                    ],
                  ),
          ),
        ),

        // DraggableScrollableSheet untuk artikel + komentar yang bisa digeser naik-turun
        NotificationListener<DraggableScrollableNotification>(
          onNotification: (notification) {
            if ((notification.extent - _sheetExtent).abs() > 0.005) {
              setState(() {
                _sheetExtent = notification.extent;
              });
            }
            return false;
          },
          child: DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: _minSheetExtent,
            minChildSize: 0.45,
            maxChildSize: _maxSheetExtent,
            snap: true,
            snapSizes: const [_minSheetExtent, _maxSheetExtent],
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    // Baris atas sheet (handle bar yang bisa diklik/ditarik + tombol Terjemahkan)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _toggleSheetExpand,
                      onVerticalDragUpdate: (details) {
                        if (!_sheetController.isAttached) return;
                        final screenHeight = MediaQuery.of(context).size.height;
                        final delta = -details.primaryDelta! / screenHeight;
                        final target = (_sheetController.size + delta)
                            .clamp(0.45, _maxSheetExtent);
                        _sheetController.jumpTo(target);
                      },
                      onVerticalDragEnd: (details) {
                        if (!_sheetController.isAttached) return;
                        final velocity = details.primaryVelocity ?? 0;
                        if (velocity > 600 &&
                            _sheetController.size <= _minSheetExtent + 0.05) {
                          setState(() {
                            _showArticleView = false;
                            _sheetExtent = _minSheetExtent;
                          });
                          return;
                        }
                        final snapTarget = _sheetController.size > 0.70
                            ? _maxSheetExtent
                            : _minSheetExtent;
                        _sheetController.animateTo(
                          snapTarget,
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFF1D74B8),
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.translate,
                                      size: 14,
                                      color: Color(0xFF1D74B8),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Terjemahkan >',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1D74B8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 44,
                              height: 4.5,
                              decoration: BoxDecoration(
                                color: const Color(0xFF888888),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Isi artikel & komentar (scrollable)
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 100),
                        children: [
                          Text(
                            episode.publicationName.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF757575),
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            episode.title,
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            episode.subtitle,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF757575),
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: const Color(0xFF2B3A29),
                                backgroundImage: NetworkImage(episode.coverUrl),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      episode.authorName,
                                      style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      episode.publishedDateText,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        color: Color(0xFF757575),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: _controller.togglePlayPause,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
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
                                        size: 18,
                                        color: AppColors.textPrimary,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Dengarkan',
                                        style: TextStyle(
                                          fontSize: 14,
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

                          // Paragraf 1 artikel
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 17.5,
                                color: AppColors.textPrimary,
                                height: 1.6,
                                fontFamily: 'Georgia',
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      'Choosing the right messaging app is more important than ever. With increasing concerns over how data is handled, many users turn to secure messaging platforms to protect their communication. Among the most popular are ',
                                ),
                                TextSpan(
                                  text: 'Signal, WhatsApp,',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Telegram,',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                TextSpan(
                                  text:
                                      ' all of which offer some level of end-to-end encryption. However, the depth of their security features, encryption implementation, and overall privacy protections vary widely.',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Gambar ilustrasi di dalam artikel (sesuai Screenshot 1)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              episode.thumbnailUrl,
                              width: double.infinity,
                              height: 210,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: double.infinity,
                                height: 210,
                                color: const Color(0xFFEAEAEA),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.image_outlined,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Paragraf lanjutan
                          Text(
                            episode.articleBody,
                            style: const TextStyle(
                              fontSize: 17.5,
                              color: AppColors.textPrimary,
                              height: 1.6,
                              fontFamily: 'Georgia',
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Kutipan bergaris vertikal ungu di sebelah kiri (sesuai Screenshot 2)
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  width: 3.5,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7B2CBF),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Text(
                                    'Mungkin keamanan terbaik bukan ketika aplikasi menjanjikan privasi sempurna, tetapi ketika arsitektur enkripsinya terbuka untuk diuji siapa saja.',
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: AppColors.textPrimary,
                                      height: 1.55,
                                      fontFamily: 'Georgia',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Kartu profil penulis + tombol Berlangganan & Bagikan Postingan (sesuai Screenshot 2)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F6F6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        episode.coverUrl,
                                        width: 54,
                                        height: 54,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 54,
                                          height: 54,
                                          color: const Color(0xFFDDE3DC),
                                          child: const Icon(Icons.person),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          episode.showTitle,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Oleh ${episode.authorName}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF757575),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'A knowledge-sharing platform for those interested in cybersecurity.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF757575),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  height: 44,
                                  child: FilledButton(
                                    onPressed: () {},
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Berlangganan',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  height: 44,
                                  child: OutlinedButton(
                                    onPressed: () {},
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColors.textPrimary,
                                      side: const BorderSide(
                                        color: Color(0xFFE0E0E0),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Bagikan Postingan',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Baris avatar penyuka & jumlah Suka • Restack
                          Row(
                            children: [
                              SizedBox(
                                width: 92,
                                height: 28,
                                child: Stack(
                                  children: List.generate(4, (idx) {
                                    const colors = [
                                      Color(0xFFE05360),
                                      Color(0xFF3182CE),
                                      Color(0xFF38A169),
                                      Color(0xFFD69E2E),
                                    ];
                                    return Positioned(
                                      left: idx * 19.0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          radius: 12,
                                          backgroundColor: colors[idx],
                                          child: const Icon(
                                            Icons.person,
                                            size: 13,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${episode.likesCount} Suka • ${episode.restacksCount} Restack',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF757575),
                                    fontWeight: FontWeight.w500,
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

                          // Bagian Komentar (sesuai Screenshot 2)
                          Container(
                            key: _commentsKey,
                            child: Text(
                              '${(episode.comments.isNotEmpty ? episode.comments : _sampleComments).length} komentar',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Kotak input "Tinggalkan komentar"
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
                                  backgroundColor: Color(0xFF1F1F1F),
                                  child: Icon(
                                    Icons.person,
                                    size: 17,
                                    color: Colors.white70,
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

                          // Daftar komentar
                          for (int i = 0;
                              i <
                                  (episode.comments.isNotEmpty
                                          ? episode.comments
                                          : _sampleComments)
                                      .length;
                              i++) ...[
                            _PodcastCommentItem(
                              comment: (episode.comments.isNotEmpty
                                  ? episode.comments
                                  : _sampleComments)[i],
                            ),
                            if (i <
                                (episode.comments.isNotEmpty
                                            ? episode.comments
                                            : _sampleComments)
                                        .length -
                                    1)
                              const SizedBox(height: 20),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Floating bar putih di bagian bawah artikel
        Positioned(
          bottom: 18,
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
                    '${episode.likesCount}',
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
                          '${(episode.comments.isNotEmpty ? episode.comments : _sampleComments).length}',
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
                    '${episode.restacksCount}',
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
    );
  }

  // Bar hitam ringkas di bagian paling atas saat sheet artikel ditarik penuh ke atas (sesuai Screenshot 1 & 2)
  Widget _buildCollapsedTopPlayerBar(PodcastEpisodeItem episode) {
    return GestureDetector(
      key: const ValueKey('collapsed-top-player'),
      onTap: _toggleSheetExpand,
      child: Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        color: const Color(0xFF0A0A0A),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                episode.coverUrl,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 44,
                  height: 44,
                  color: const Color(0xFFDDE3DC),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.podcasts,
                    color: Colors.black87,
                    size: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    episode.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    episode.authorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF9E9E9E),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _controller.togglePlayPause,
              icon: Icon(
                _controller.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportControls({required double buttonSize}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _controller.skipBackward10,
          icon: const Icon(
            Icons.replay_10,
            color: Colors.white,
            size: 34,
          ),
        ),
        const SizedBox(width: 24),
        GestureDetector(
          onTap: _controller.togglePlayPause,
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _controller.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: buttonSize * 0.5,
            ),
          ),
        ),
        const SizedBox(width: 24),
        IconButton(
          onPressed: _controller.skipForward30,
          icon: const Icon(
            Icons.forward_30,
            color: Colors.white,
            size: 34,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    final pos = _controller.positionSeconds;
    final total = _controller.totalSeconds;
    final remaining = (total - pos).clamp(0, total);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.25),
              thumbColor: Colors.white,
            ),
            child: Slider(
              value: pos.toDouble().clamp(0, total > 0 ? total.toDouble() : 1),
              min: 0,
              max: total > 0 ? total.toDouble() : 1,
              onChanged: (val) => _controller.seekToSeconds(val.round()),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                PodcastPlayerController.formatClock(pos),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                PodcastPlayerController.formatClock(remaining),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PodcastCommentItem extends StatelessWidget {
  final PodcastCommentData comment;

  const _PodcastCommentItem({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: comment.avatarColor,
              child: const Icon(
                Icons.person,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.username,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  comment.dateText,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF888888),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (comment.likedByAuthor != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              comment.likedByAuthor!,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF757575),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          comment.content,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textPrimary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(
              Icons.favorite_border,
              size: 16,
              color: Color(0xFF757575),
            ),
            const SizedBox(width: 5),
            Text(
              'LIKE (${comment.likesCount})',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF757575),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '·',
              style: TextStyle(color: Color(0xFF757575)),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.reply,
              size: 16,
              color: Color(0xFF757575),
            ),
            const SizedBox(width: 4),
            const Text(
              'BALAS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF757575),
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.more_vert,
              size: 18,
              color: Color(0xFF757575),
            ),
          ],
        ),
        if (comment.repliesSummary != null) ...[
          const SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              children: [
                const SizedBox(width: 12),
                Container(
                  width: 2,
                  color: const Color(0xFFE0E0E0),
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    comment.repliesSummary!,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF757575),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CoverWithWaveform extends StatelessWidget {
  final String coverUrl;
  final double size;
  final bool isPlaying;

  const _CoverWithWaveform({
    required this.coverUrl,
    required this.size,
    required this.isPlaying,
  });

  static const List<double> _leftHeights = [4, 14, 10, 22, 8, 18, 28, 12];
  static const List<double> _rightHeights = [10, 18, 12, 6, 4, 12, 20, 14];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _leftHeights
                .map(
                  (h) => Container(
                    width: 3,
                    height: isPlaying ? h : 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(width: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Image.network(
            coverUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: size,
              height: size,
              color: const Color(0xFFDDE3DC),
              alignment: Alignment.center,
              child: const Icon(
                Icons.podcasts,
                size: 56,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _rightHeights
                .map(
                  (h) => Container(
                    width: 3,
                    height: isPlaying ? h : 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
