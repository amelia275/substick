import 'package:flutter/material.dart';

const _orange = Color(0xFFFF6719);
const _grey = Color(0xFFF0F0F0);
const _greyDark = Color(0xFFE4E4E4);
const _greyText = Color(0xFF8A8A8A);

// Data dummy, nanti diganti data dari API
const _name = 'Kanalika';
const _username = '@heynana';
const _bio = 'better to speak';
const _linkCount = 1;
const _subscriptions = ['The Greatest Note', 'The Substack Post'];

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
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
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            const SliverToBoxAdapter(child: _ProfileHeader()),
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
                labelStyle:
                    TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
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
          body: const TabBarView(
            children: [
              _ActivityTab(),
              _EmptyState(
                icon: Icons.description_outlined,
                title: 'No posts yet',
                subtitle: 'Your posts will appear here',
              ),
              _EmptyState(
                icon: Icons.library_books_outlined,
                title: 'No replies yet',
                subtitle: 'Your replies will appear here',
              ),
              _LikesTab(),
              _SubscriptionsTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama, username, foto
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name,
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(_username,
                            style: TextStyle(fontSize: 16, color: _greyText)),
                        Text(' · ',
                            style: TextStyle(fontSize: 16, color: _greyText)),
                        Icon(Icons.link, size: 18, color: _greyText),
                        SizedBox(width: 2),
                        Text('$_linkCount',
                            style: TextStyle(fontSize: 16, color: _greyText)),
                      ],
                    ),
                  ],
                ),
              ),
              const CircleAvatar(
                radius: 42,
                backgroundColor: _grey,
                child: Icon(Icons.person, size: 40, color: _greyText),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(_bio, style: TextStyle(fontSize: 16, height: 1.4)),
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
          Row(
            children: const [
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

enum _ActivityType { note, restack }

class _ActivityItem {
  const _ActivityItem({
    required this.type,
    required this.author,
    required this.time,
    this.text,
    this.quote,
    this.quoteSource,
    this.pub,
    this.title,
    this.subtitle,
    this.snippet,
    this.cardColor = const Color(0xFF3B4435),
    this.likes = 0,
    this.comments = 0,
    this.restacks = 0,
    this.liked = false,
  });

  final _ActivityType type;
  final String author;
  final String time;
  final String? text; // teks catatan di atas kartu (opsional)
  final String? quote; // isi kartu kutipan (kalau diisi, tampil kartu kutipan)
  final String? quoteSource;
  final String? pub; // nama publikasi (kartu artikel)
  final String? title;
  final String? subtitle;
  final String? snippet;
  final Color cardColor;
  final int likes;
  final int comments;
  final int restacks;
  final bool liked;
}

// Data dummy, nanti diganti data dari API
const _activities = [
  _ActivityItem(
    type: _ActivityType.note,
    author: _name,
    time: '1mo',
    text: 'Well written!',
    pub: 'BUMANTARA J',
    title: 'Sampai Kapan Kau Diam di Kepala?',
    subtitle:
        'Tentang seorang anak yang takut kehilangan dirinya sendiri, kelak saat menyentuh umur 20-an',
    snippet:
        'Aku sering merasa hidupku terlalu cepat untuk memikirkan segalanya, entah kapan terjadinya...',
    cardColor: Color(0xFF244338),
    likes: 12,
    comments: 2,
    restacks: 1,
    liked: true,
  ),
  _ActivityItem(
    type: _ActivityType.note,
    author: _name,
    time: '2mo',
    text: 'Relateable :(',
    quote: 'Biarkan sebagian hal berjalan apa adanya.',
    quoteSource: 'cam.',
    cardColor: Color(0xFF3B4435),
  ),
  _ActivityItem(
    type: _ActivityType.restack,
    author: 'Priscilla',
    time: '3mo',
    pub: 'YOURS TRULY',
    title:
        'Orang Bilang Tanah Kita Tanah Surga, Tapi Hasil Buminya Entah Kemana',
    subtitle: 'Apakah kalian pernah berpikir sedemikian rupa?',
    snippet:
        'Sejak mula kita dicekoki dogma yang sama, dilantunkan di pelataran maktab hingga menjelma liturgi...',
    cardColor: Color(0xFF333333),
    likes: 69,
    comments: 14,
    restacks: 27,
    liked: true,
  ),
  _ActivityItem(
    type: _ActivityType.restack,
    author: 'Ismail bin Mail',
    time: '4mo',
    pub: 'MAIL TK B',
    title: 'Catatan Kecil dari Kamar Kos',
    subtitle: 'Hal-hal sederhana yang ternyata penting.',
    snippet: 'Sebelum kita mulai, satu hal perlu diluruskan...',
    cardColor: Color(0xFF4A3B2E),
  ),
];

class _ActivityTab extends StatelessWidget {
  const _ActivityTab();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: _activities.length,
      separatorBuilder: (_, __) => Container(height: 8, color: _grey),
      itemBuilder: (_, i) => _ActivityCard(item: _activities[i]),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.item});

  final _ActivityItem item;

  @override
  Widget build(BuildContext context) {
    final isRestack = item.type == _ActivityType.restack;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isRestack) ...[
            Row(
              children: const [
                Icon(Icons.repeat, size: 20, color: _greyText),
                SizedBox(width: 10),
                Text('$_name restacked',
                    style: TextStyle(fontSize: 16, color: _greyText)),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Baris penulis
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: _grey,
                child: Icon(Icons.person, color: _greyText),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.author,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    Row(
                      children: [
                        Text(item.time,
                            style: const TextStyle(color: _greyText)),
                        if (isRestack) ...const [
                          Text('  •  ', style: TextStyle(color: _greyText)),
                          Text('Subscribe', style: TextStyle(color: _orange)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_horiz, color: _greyText),
              if (isRestack) ...const [
                SizedBox(width: 12),
                Icon(Icons.close, color: _greyText),
              ],
            ],
          ),

          // Teks catatan (opsional)
          if (item.text != null) ...[
            const SizedBox(height: 12),
            Text(item.text!, style: const TextStyle(fontSize: 18, height: 1.4)),
          ],
          const SizedBox(height: 12),

          // Kartu: kutipan atau artikel
          if (item.quote != null)
            _QuoteCard(item: item)
          else
            _ArticleCard(item: item),
          const SizedBox(height: 12),

          _ActionBar(item: item),
        ],
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.item});

  final _ActivityItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: item.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote, size: 32, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            item.quote!,
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
                child: Text(item.quoteSource ?? '',
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
  const _ArticleCard({required this.item});

  final _ActivityItem item;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        color: item.cardColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder gambar sampul
            Container(
              height: 160,
              width: double.infinity,
              color: Colors.white24,
              child: const Icon(Icons.image_outlined,
                  size: 48, color: Colors.white54),
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
                      Text(item.pub ?? '',
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(item.title ?? '',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          height: 1.3)),
                  const SizedBox(height: 8),
                  Text(item.subtitle ?? '',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 12),
                  Text(item.snippet ?? '',
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

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.item});

  final _ActivityItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Action(
          icon: item.liked ? Icons.favorite : Icons.favorite_border,
          count: item.likes,
          active: item.liked,
        ),
        const SizedBox(width: 24),
        _Action(icon: Icons.chat_bubble_outline, count: item.comments),
        const SizedBox(width: 24),
        _Action(icon: Icons.repeat, count: item.restacks),
        const SizedBox(width: 24),
        const Icon(Icons.share_outlined, color: _greyText),
      ],
    );
  }
}

String _fmt(int n) {
  if (n >= 1000) {
    final v = (n / 1000).toStringAsFixed(1);
    return '${v.endsWith('.0') ? v.substring(0, v.length - 2) : v}k';
  }
  return '$n';
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

// Data dummy, nanti diganti data dari API
const _likedPosts = [
  _ActivityItem(
    type: _ActivityType.note,
    author: 'Kino',
    time: '4d',
    text: 'Bacaan hari ini, saya rekomendasikan untuk teman-teman.',
    pub: 'AKSARA M',
    title: 'Paksa Iblis Turun Dari Kursi',
    subtitle: 'Apa yang anda pikirkan perihal menafsir lirik lagu?',
    snippet:
        'Tak saya sangka, ada secarik lirik lagu yang menyita waktu saya, hanya untuk berpikir sejenak...',
    cardColor: Color(0xFF6B4A38),
    likes: 2300,
    restacks: 660,
    liked: true,
  ),
  _ActivityItem(
    type: _ActivityType.note,
    author: 'isaya',
    time: '3w',
    text: 'Menulis itu tidak perlu sempurna.\n\nTulis saja dulu.',
    likes: 22000,
    comments: 215,
    restacks: 2900,
    liked: true,
  ),
  _ActivityItem(
    type: _ActivityType.note,
    author: 'Audrey Z',
    time: '1w',
    text: 'Terkadang, tulisan yang jujur lebih berharga daripada yang rapi.',
    likes: 2200,
    comments: 22,
    restacks: 348,
    liked: true,
  ),
  _ActivityItem(
    type: _ActivityType.note,
    author: 'Auryn Lenggana',
    time: '1mo',
    pub: 'AURRRYYYY',
    title: 'Catatan dari Pinggir Kota',
    subtitle: 'Cerita kecil tentang hal-hal yang sering terlewat.',
    snippet: 'Mari Bercerita.',
    cardColor: Color(0xFF244338),
    likes: 2600,
    restacks: 925,
    liked: true,
  ),
];

class _LikesTab extends StatelessWidget {
  const _LikesTab();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: _likedPosts.length,
      separatorBuilder: (_, __) => const Divider(
          height: 1, indent: 16, endIndent: 16, color: Color(0xFFE0E0E0)),
      itemBuilder: (_, i) => _LikedPost(item: _likedPosts[i]),
    );
  }
}

class _LikedPost extends StatelessWidget {
  const _LikedPost({required this.item});

  final _ActivityItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris "... liked"
          Row(
            children: [
              const Icon(Icons.favorite, size: 20, color: _greyText),
              const SizedBox(width: 10),
              Text('$_name liked',
                  style: const TextStyle(fontSize: 16, color: _greyText)),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: _grey,
                child: Icon(Icons.person, color: _greyText),
              ),
              const SizedBox(width: 12),
              // Semua konten menjorok sejajar dengan nama
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.author,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700)),
                              Row(
                                children: [
                                  Text(item.time,
                                      style: const TextStyle(color: _greyText)),
                                  const Text('  •  ',
                                      style: TextStyle(color: _greyText)),
                                  const Text('Subscribe',
                                      style: TextStyle(color: _orange)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.more_horiz, color: _greyText),
                        const SizedBox(width: 12),
                        const Icon(Icons.close, color: _greyText),
                      ],
                    ),
                    if (item.text != null) ...[
                      const SizedBox(height: 8),
                      Text(item.text!,
                          style: const TextStyle(fontSize: 18, height: 1.4)),
                    ],
                    if (item.title != null) ...[
                      const SizedBox(height: 12),
                      _ArticleCard(item: item),
                    ],
                    const SizedBox(height: 12),
                    _ActionBar(item: item),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubscriptionsTab extends StatelessWidget {
  const _SubscriptionsTab();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _subscriptions.length,
      itemBuilder: (context, i) => ListTile(
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: _grey,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        title: Text(_subscriptions[i],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        subtitle: const Text('Free Subscriber',
            style: TextStyle(fontSize: 16, color: _greyText)),
      ),
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
