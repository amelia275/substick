import 'package:flutter/material.dart';
import '../../core/routing/app_navigation.dart';
import '../../core/theme/app_colors.dart';
import '../../models/post.dart';
import '../../models/read_section.dart';
import '../../services/read_service.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../widgets/app_top_bar.dart';
import '../article_detail/article_detail_screen.dart';

void _openArticleDetail(BuildContext context, Post article) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ArticleDetailScreen(post: article),
    ),
  );
}

// ───────────────────────── Gaya tampilan section ─────────────────────────
// Nama section datang dari API (field `category`). Di sini hanya menentukan
// gaya tampilannya; section yang tidak terdaftar tampil sebagai daftar biasa.
enum _SectionStyle { carousel, list, featuredAndList }

const _sectionStyles = <String, _SectionStyle>{
  'Romansa': _SectionStyle.carousel,
  'Pengembangan diri': _SectionStyle.list,
  'Kesehatan mental': _SectionStyle.featuredAndList,
  'Iman & Spiritualitas': _SectionStyle.carousel,
  'Isu Sosial': _SectionStyle.list,
};

/// Model Post belum punya status "sudah dibaca", jadi semua artikel
/// ditampilkan dengan titik oranye seperti di screenshot.
const _showUnreadDot = true;

// ───────────────────────── Screen ─────────────────────────
class ReadScreen extends StatefulWidget {
  const ReadScreen({super.key});

  @override
  State<ReadScreen> createState() => _ReadScreenState();
}

class _ReadScreenState extends State<ReadScreen> {
  static const _tabs = ['Untuk Anda', 'Terbaru', 'Berbayar', 'Tersimpan', 'Riwayat'];

  final ReadService _readService = ReadService();
  late Future<List<ReadSection>> _sectionsFuture;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _sectionsFuture = _readService.fetchSections();
  }

  void _reload() {
    setState(() {
      _sectionsFuture = _readService.fetchSections();
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
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Bacaan',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          _TabChips(
            tabs: _tabs,
            selected: _tab,
            onSelected: (i) => setState(() => _tab = i),
          ),
          Expanded(
            child: _tab == 0
                ? FutureBuilder<List<ReadSection>>(
                    future: _sectionsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        );
                      }
                      if (snapshot.hasError) {
                        return _ErrorState(onRetry: _reload);
                      }
                      return _ForYouFeed(sections: snapshot.data ?? const []);
                    },
                  )
                : Builder(
                    builder: (context) {
                      final msg = _emptyMessages[_tabs[_tab]];
                      return _EmptyTabState(
                        title: msg?.$1 ?? 'Belum ada konten',
                        subtitle: msg?.$2 ?? '',
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) return; // sudah di halaman Bacaan
          AppNavigation.onTabSelected(context, index);
        },
      ),
    );
  }
}

// ───────────────────────── Helper turunan dari Post ─────────────────────────
// Post tidak punya field khusus untuk hal-hal ini, jadi dihitung di UI.
const _bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

/// Nama yang ditampilkan: nama publikasi, kalau tidak ada nama penulis.
String _authorLabel(Post p) => p.publicationName ?? p.authorName ?? p.username ?? '';

/// Kutipan = baris pertama konten, dipotong sekitar 120 karakter.
String _excerpt(Post p) {
  final firstLine = p.content
      .split('\n')
      .map((l) => l.trim())
      .firstWhere((l) => l.isNotEmpty, orElse: () => '');
  if (firstLine.length <= 120) return firstLine;
  final cut = firstLine.substring(0, 120);
  final lastSpace = cut.lastIndexOf(' ');
  return '${lastSpace > 60 ? cut.substring(0, lastSpace) : cut}...';
}

bool _hasTitle(Post p) => (p.title ?? '').trim().isNotEmpty;

/// Judul; kalau kosong pakai kutipan.
String _titleOf(Post p) => _hasTitle(p) ? p.title!.trim() : _excerpt(p);

/// Perkiraan waktu baca (± 200 kata per menit), minimal 1 menit.
int _readMinutes(Post p) {
  final text = p.content.trim();
  if (text.isEmpty) return 1;
  final words = text.split(RegExp(r'\s+')).length;
  final minutes = (words / 200).ceil();
  return minutes < 1 ? 1 : minutes;
}

/// 15 Agu → "Agu 15"
String _formatDate(DateTime? date) {
  if (date == null) return '';
  final d = date.toLocal();
  return '${_bulan[d.month - 1]} ${d.day}';
}

/// 12800 → "12,8k", 10000 → "10k", 950 → "950"
String _compact(int n) {
  if (n < 1000) return '$n';
  final v = (n / 1000).toStringAsFixed(1);
  final trimmed = v.endsWith('.0') ? v.substring(0, v.length - 2) : v;
  return '${trimmed.replaceAll('.', ',')}k';
}

// Warna placeholder kalau post belum punya gambar / gagal dimuat.
const _placeholderColors = <Color>[
  Color(0xFFB5523B),
  Color(0xFF8A7466),
  Color(0xFF2B3F8F),
  Color(0xFF4F6B5A),
  Color(0xFF6B5B73),
  Color(0xFF3A4A5C),
];
Color _placeholderColor(int id) => _placeholderColors[id % _placeholderColors.length];

// ───────────────────────── Tab chips ─────────────────────────
class _TabChips extends StatelessWidget {
  const _TabChips({
    required this.tabs,
    required this.selected,
    required this.onSelected,
  });

  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 4),
        itemBuilder: (_, i) {
          final active = i == selected;
          return GestureDetector(
            onTap: () => onSelected(i),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: active ? AppColors.divider : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                tabs[i],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  color: active ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ───────────────────────── Error state ─────────────────────────
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Gagal memuat bacaan',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonPrimary,
              foregroundColor: AppColors.buttonText,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Empty state tab ─────────────────────────
const _emptyMessages = <String, (String, String)>{
  'Terbaru': (
    'Anda sudah mengejar ketertinggalan!',
    'Cari atau kunjungi Notes untuk menemukan lebih banyak tulisan bagus',
  ),
  'Berbayar': (
    'Belum ada tulisan berbayar',
    'Tulisan dari kreator yang Anda dukung akan muncul di sini',
  ),
  'Tersimpan': (
    'Belum ada tulisan tersimpan',
    'Simpan tulisan untuk dibaca nanti, dan semuanya akan muncul di sini',
  ),
  'Riwayat': (
    'Riwayat bacaan masih kosong',
    'Tulisan yang sudah Anda baca akan muncul di sini',
  ),
};

class _EmptyTabState extends StatelessWidget {
  const _EmptyTabState({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Feed "Untuk Anda" ─────────────────────────
class _ForYouFeed extends StatelessWidget {
  const _ForYouFeed({required this.sections});
  final List<ReadSection> sections;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      const _SectionHeader('Kotak masuk', showSeeAll: false),
      const _EmptyInbox(),
      const _SectionDivider(),
    ];

    var firstSection = true;
    for (final section in sections) {
      if (section.posts.isEmpty) continue; // section kosong tidak ditampilkan

      if (!firstSection) children.add(const _SectionDivider());
      firstSection = false;

      children.add(_SectionHeader(section.title));

      final style = _sectionStyles[section.title] ?? _SectionStyle.list;
      switch (style) {
        case _SectionStyle.carousel:
          children.add(_HorizontalList(items: section.posts));
        case _SectionStyle.list:
          children.addAll(section.posts.map((p) => _ArticleTile(article: p)));
        case _SectionStyle.featuredAndList:
          children.add(_FeaturedCard(article: section.posts.first));
          children.addAll(
            section.posts.skip(1).map((p) => _ArticleTile(article: p)),
          );
      }
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: children,
    );
  }
}

// ───────────────────────── Komponen kecil ─────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title, {this.showSeeAll = true});
  final String title;
  final bool showSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (showSeeAll)
            GestureDetector(
              onTap: () {},
              child: const Text(
                'Lihat semua',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Pemisah antar-section, ketebalannya sama dengan pemisah di HomeScreen.
class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 5, thickness: 5, color: AppColors.divider);
}

class _EmptyInbox extends StatelessWidget {
  const _EmptyInbox();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 42, color: AppColors.textPrimary),
          SizedBox(height: 14),
          Text(
            'Kotak masuk Anda kosong',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Temukan lebih banyak kreator dan berlangganan',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

/// Gambar persegi dengan sudut membulat. Pakai placeholder berwarna
/// kalau [imageUrl] null atau gagal dimuat.
class _Thumb extends StatelessWidget {
  const _Thumb({required this.color, required this.size, this.imageUrl, this.radius = 12});
  final Color color;
  final String? imageUrl;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, Color.lerp(color, Colors.black, 0.5)!],
        ),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: imageUrl == null
            ? placeholder
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => placeholder,
              ),
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.likes, required this.comments, this.readTime = ''});
  final String likes;
  final String comments;
  final String readTime;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(color: AppColors.textSecondary, fontSize: 13);
    const icon = 16.0;
    return Row(
      children: [
        if (readTime.isNotEmpty) ...[
          Text(readTime, style: style),
          const SizedBox(width: 14),
        ],
        const Icon(Icons.favorite_border, size: icon, color: AppColors.iconSecondary),
        const SizedBox(width: 4),
        Text(likes, style: style),
        const SizedBox(width: 14),
        const Icon(Icons.chat_bubble_outline, size: icon, color: AppColors.iconSecondary),
        const SizedBox(width: 4),
        Text(comments, style: style),
      ],
    );
  }
}

// ───────────────────────── Carousel horizontal ─────────────────────────
class _HorizontalList extends StatelessWidget {
  const _HorizontalList({required this.items});
  final List<Post> items;

  @override
  Widget build(BuildContext context) {
    const cardWidth = 140.0;
    return SizedBox(
      height: 270,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, i) {
          final a = items[i];
          return GestureDetector(
            onTap: () => _openArticleDetail(context, a),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: cardWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Thumb(
                    color: _placeholderColor(a.id),
                    imageUrl: a.imageUrl,
                    size: cardWidth,
                  ),
                  const SizedBox(height: 10),
                  // tinggi dikunci 2 baris supaya semua kartu sejajar
                  SizedBox(
                    height: 40,
                    child: Text(
                      _titleOf(a),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _authorLabel(a),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _Stats(
                    likes: _compact(a.likesCount),
                    comments: _compact(a.commentsCount),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ───────────────────────── Item artikel (list) ─────────────────────────
class _ArticleTile extends StatelessWidget {
  const _ArticleTile({required this.article});
  final Post article;

  @override
  Widget build(BuildContext context) {
    final a = article;
    final color = _placeholderColor(a.id);
    final excerpt = _hasTitle(a) ? _excerpt(a) : ''; // kalau tanpa judul, kutipan sudah jadi judul

    return InkWell(
      onTap: () => _openArticleDetail(context, a),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Post belum membawa foto penulis, jadi placeholder dulu.
                          _Thumb(color: color, size: 22, radius: 5),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _authorLabel(a),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 14),
                            ),
                          ),
                          Text(_formatDate(a.publishedAt),
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _titleOf(a),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      if (excerpt.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          excerpt,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              height: 1.3),
                        ),
                      ],
                      const SizedBox(height: 10),
                      _Stats(
                        likes: '${a.likesCount}',
                        comments: '${a.commentsCount}',
                        readTime: '${_readMinutes(a)} menit membaca',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: _Thumb(
                    color: color,
                    imageUrl: a.imageUrl,
                    size: 60,
                    radius: 8,
                  ),
                ),
              ],
            ),
          ),
          // titik oranye = belum dibaca
          if (_showUnreadDot)
            Positioned(
              left: 6,
              top: 22,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ───────────────────────── Kartu featured ─────────────────────────
class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.article});
  final Post article;

  @override
  Widget build(BuildContext context) {
    final a = article;
    final color = _placeholderColor(a.id);
    const white = Colors.white;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: GestureDetector(
        onTap: () => _openArticleDetail(context, a),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 245,
            child: Stack(
              children: [
                Positioned.fill(
                  child: a.imageUrl == null
                      ? DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [color, const Color(0xFF1B2A1B)],
                            ),
                          ),
                        )
                      : Image.network(
                          a.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: color),
                        ),
                ),
                // overlay gelap supaya teks putih terbaca
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withAlpha(40),
                          Colors.black.withAlpha(150),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const _Thumb(color: Colors.white38, size: 26, radius: 6),
                            const SizedBox(width: 8),
                            Text(_authorLabel(a),
                                style: const TextStyle(
                                    color: white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _titleOf(a),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: white,
                            fontFamily: 'serif', // sama seperti kartu quote di HomeScreen
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _hasTitle(a) ? _excerpt(a) : '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: white, fontSize: 14, height: 1.3),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Text(_formatDate(a.publishedAt),
                                style: const TextStyle(color: white, fontSize: 14)),
                            const SizedBox(width: 8),
                            const Text('·', style: TextStyle(color: white)),
                            const SizedBox(width: 8),
                            const Icon(Icons.favorite_border, size: 16, color: white),
                            const SizedBox(width: 4),
                            Text(_compact(a.likesCount),
                                style: const TextStyle(color: white, fontSize: 14)),
                            const SizedBox(width: 12),
                            const Icon(Icons.chat_bubble_outline, size: 16, color: white),
                            const SizedBox(width: 4),
                            Text(_compact(a.commentsCount),
                                style: const TextStyle(color: white, fontSize: 14)),
                            const Spacer(),
                            Material(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {},
                                child: const SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Icon(Icons.bookmark_border, color: white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
