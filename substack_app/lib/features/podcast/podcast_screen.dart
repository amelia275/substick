import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/routing/app_navigation.dart';
import '../../core/theme/app_colors.dart';
import '../../models/podcast.dart';
import '../../widgets/app_bottom_navigation.dart';
import 'podcast_player_controller.dart';
import 'podcast_player_screen.dart';

class PodcastShowData {
  final String id;
  final String shortTitle;
  final String title;
  final String author;
  final String description;
  final String coverUrl;
  final Color accentColor;
  final List<PodcastEpisodeItem> episodes;

  const PodcastShowData({
    required this.id,
    required this.shortTitle,
    required this.title,
    required this.author,
    required this.description,
    required this.coverUrl,
    this.accentColor = const Color(0xFF539022),
    required this.episodes,
  });

  factory PodcastShowData.fromPodcast(Podcast podcast) {
    return PodcastShowData(
      id: 'podcast-${podcast.id}',
      shortTitle: podcast.shortTitle,
      title: podcast.title,
      author: podcast.author,
      description: podcast.description,
      coverUrl: podcast.coverUrl,
      accentColor: podcast.accentColor,
      episodes: podcast.episodes
          .map(
            (ep) => ep.toPlayerItem(
              showTitle: podcast.shortTitle,
              publicationName: podcast.shortTitle.toUpperCase(),
              authorName: podcast.author,
              coverUrl: podcast.coverUrl,
            ),
          )
          .toList(),
    );
  }
}

class ExplorePodcastData {
  final PodcastEpisodeItem episode;
  final String? publicationLogoUrl;
  final bool isFeaturedVideo;

  const ExplorePodcastData({
    required this.episode,
    this.publicationLogoUrl,
    this.isFeaturedVideo = false,
  });
}

void _playAndOpenPlayer(BuildContext context, PodcastEpisodeItem episode) {
  PodcastPlayerController.instance.playEpisode(episode);
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => const PodcastPlayerScreen(),
    ),
  );
}

class PodcastScreen extends StatefulWidget {
  const PodcastScreen({super.key});

  @override
  State<PodcastScreen> createState() => _PodcastScreenState();
}

class _PodcastScreenState extends State<PodcastScreen> {
  static const List<String> _filters = [
    'Untuk Anda',
    'Terbaru',
    'Berbayar',
    'Tersimpan',
    'Riwayat',
  ];

  final ApiClient _apiClient = ApiClient();
  int _selectedFilterIndex = 0;
  bool _isMuted = true;
  bool _isLoading = true;
  bool _hasError = false;
  List<PodcastShowData> _yourShows = const [];
  List<ExplorePodcastData> _exploreEpisodes = const [];

  @override
  void initState() {
    super.initState();
    _fetchPodcasts();
  }

  @override
  void dispose() {
    _apiClient.close();
    super.dispose();
  }

  Future<void> _fetchPodcasts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await _apiClient.get('/podcasts');
      final List<dynamic> rawList = response is Map<String, dynamic>
          ? (response['data'] as List<dynamic>? ?? const [])
          : (response is List<dynamic> ? response : const []);

      final podcasts = rawList
          .whereType<Map<String, dynamic>>()
          .map(Podcast.fromJson)
          .toList();

      if (!mounted) return;

      final subscribedShows = podcasts
          .where((p) => p.isSubscribed)
          .map(PodcastShowData.fromPodcast)
          .toList();

      final exploreItems = <ExplorePodcastData>[];
      for (final podcast in podcasts.where((p) => !p.isSubscribed)) {
        for (final ep in podcast.episodes) {
          exploreItems.add(
            ExplorePodcastData(
              isFeaturedVideo: ep.isFeaturedVideo,
              publicationLogoUrl: podcast.coverUrl,
              episode: ep.toPlayerItem(
                showTitle: podcast.shortTitle,
                publicationName: podcast.shortTitle.toUpperCase(),
                authorName: podcast.author,
                coverUrl: podcast.coverUrl,
              ),
            ),
          );
        }
      }

      setState(() {
        _yourShows = subscribedShows;
        _exploreEpisodes = exploreItems;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _openShowDetail(PodcastShowData show) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PodcastShowDetailScreen(show: show),
      ),
    );
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
          'Podcast',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            tooltip: 'Cari',
            icon: const Icon(
              Icons.search,
              size: 28,
              color: AppColors.textPrimary,
            ),
          ),
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Gagal memuat data podcast dari server.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _fetchPodcasts,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: EdgeInsets.zero,
                  children: [
          // Filter bar: Untuk Anda | Terbaru | Berbayar | Tersimpan | Riwayat
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
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
                        horizontal: 14,
                        vertical: 8,
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
                              isSelected ? FontWeight.w700 : FontWeight.w600,
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

          // Bagian: Acara Anda
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Acara Anda',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 186,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _yourShows.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final show = _yourShows[index];
                return GestureDetector(
                  onTap: () => _openShowDetail(show),
                  child: SizedBox(
                    width: 152,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            show.coverUrl,
                            width: 152,
                            height: 152,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 152,
                              height: 152,
                              color: const Color(0xFFDDE3DC),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.podcasts,
                                size: 48,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          show.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(
              height: 1,
              thickness: 0.8,
              color: AppColors.divider,
            ),
          ),

          // Bagian: Jelajahi lebih banyak podcast
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Jelajahi lebih banyak podcast',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 14),

          for (int i = 0; i < _exploreEpisodes.length; i++) ...[
            if (_exploreEpisodes[i].isFeaturedVideo)
              _FeaturedPodcastVideoCard(
                data: _exploreEpisodes[i],
                isMuted: _isMuted,
                onToggleMute: () {
                  setState(() {
                    _isMuted = !_isMuted;
                  });
                },
                onTap: () =>
                    _playAndOpenPlayer(context, _exploreEpisodes[i].episode),
              )
            else
              _EpisodeListTile(episode: _exploreEpisodes[i].episode),
            if (i < _exploreEpisodes.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Divider(
                  height: 1,
                  thickness: 0.8,
                  color: AppColors.divider,
                ),
              ),
          ],
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 2,
        onTap: (index) => AppNavigation.onTabSelected(context, index),
      ),
    );
  }
}

class _FeaturedPodcastVideoCard extends StatelessWidget {
  final ExplorePodcastData data;
  final bool isMuted;
  final VoidCallback onToggleMute;
  final VoidCallback onTap;

  const _FeaturedPodcastVideoCard({
    required this.data,
    required this.isMuted,
    required this.onToggleMute,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final episode = data.episode;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kartu video / thumbnail besar
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Image.network(
                    episode.thumbnailUrl,
                    width: double.infinity,
                    height: 205,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: double.infinity,
                      height: 205,
                      color: const Color(0xFF2B2823),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.play_circle_fill,
                        size: 54,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  // Tombol mute di kanan atas
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: onToggleMute,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isMuted ? Icons.volume_off : Icons.volume_up,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Baris nama publikasi & waktu
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: data.publicationLogoUrl != null
                      ? Image.network(
                          data.publicationLogoUrl!,
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 24,
                            height: 24,
                            color: const Color(0xFF2B2823),
                            child: const Icon(
                              Icons.podcasts,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Container(
                          width: 24,
                          height: 24,
                          color: const Color(0xFF2B2823),
                          child: const Icon(
                            Icons.podcasts,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${episode.publicationName} · ${episode.timeAgo}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF757575),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Judul besar
            Text(
              episode.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                height: 1.25,
              ),
            ),
            if (episode.subtitle.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                episode.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF757575),
                  height: 1.3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PodcastShowDetailScreen extends StatelessWidget {
  final PodcastShowData show;

  const PodcastShowDetailScreen({
    super.key,
    required this.show,
  });

  @override
  Widget build(BuildContext context) {
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
        titleSpacing: 0,
        title: Text(
          show.shortTitle,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Center(
            child: SizedBox(
              height: 38,
              child: FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: show.accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Tingkatkan',
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
      body: ListView(
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        children: [
          // Header detail podcast (cover + judul + nama pembuat + deskripsi)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(
                        show.coverUrl,
                        width: 132,
                        height: 132,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 132,
                          height: 132,
                          color: const Color(0xFFDDE3DC),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.podcasts,
                            size: 48,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            show.title.replaceFirst(' ', '\n'),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.15,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            show.author,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF757575),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  show.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF757575),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Daftar episode
          for (int i = 0; i < show.episodes.length; i++) ...[
            _EpisodeListTile(episode: show.episodes[i]),
            if (i < show.episodes.length - 1) const SizedBox(height: 20),
          ],
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 2,
        onTap: (index) => AppNavigation.onTabSelected(context, index),
      ),
    );
  }
}

class _EpisodeListTile extends StatelessWidget {
  final PodcastEpisodeItem episode;

  const _EpisodeListTile({required this.episode});

  @override
  Widget build(BuildContext context) {
    final controller = PodcastPlayerController.instance;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final hasProgress = controller.hasProgressFor(episode.id);
        final progressValue = controller.progressFor(
          episode.id,
          episode.totalDurationSeconds,
        );
        final durationLabel = controller.remainingLabelFor(
          episode.id,
          episode.totalDurationSeconds,
        );

        return InkWell(
          onTap: () => _playAndOpenPlayer(context, episode),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    episode.thumbnailUrl,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 96,
                      height: 96,
                      color: const Color(0xFFEAEAEA),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.podcasts,
                        color: AppColors.iconSecondary,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${episode.publicationName} · ${episode.timeAgo}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF757575),
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        episode.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.play_arrow,
                                  size: 16,
                                  color: Color(0xFF757575),
                                ),
                                if (hasProgress) ...[
                                  const SizedBox(width: 4),
                                  SizedBox(
                                    width: 34,
                                    height: 4,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(2),
                                      child: LinearProgressIndicator(
                                        value: progressValue,
                                        backgroundColor:
                                            const Color(0xFFD6D6D6),
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                          Color(0xFF686868),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ] else
                                  const SizedBox(width: 3),
                                Text(
                                  durationLabel,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF757575),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {},
                            child: const Icon(
                              Icons.more_horiz,
                              size: 20,
                              color: Color(0xFF757575),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
