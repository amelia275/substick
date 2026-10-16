
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../widgets/app_top_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        onSearchTap: () {},
        onProfileTap: () {},
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: const [
          // Quote berbentuk gambar
          _NoteItem(
            username: 'wordsloftupsaid',
            time: '2mo',
            imageUrl: 'https://placehold.co/800x450/ffffff/2b2823.png?text=What+words+are+better+than+I+love+you%3F',
            likes: '13.5k',
            comments: '48',
            restacks: '4.3k',
          ),

          // Note berupa teks panjang
          _NoteItem(
            username: 'nanash',
            time: '1d',
            content:
                'baru sadar kehilangan spark tuh ternyata ga selalu '
                'kelihatan kayak sedih, kadang kita masih ketawa, '
                'masih kerja, masih ngobrol, masih main, masih jadi '
                'diri sendiri, tapi rasanya ada bagian dari diri kita '
                'yang pelan-pelan mati, and somehow, losing your spark '
                'slowly is scarier than being sad all at once.',
            likes: '1k',
            comments: '11',
            restacks: '275',
          ),

          // Rekomendasi akun di tengah feed
          _PeopleToFollow(),

          // Note dengan teks pengantar dan kartu quote
          _NoteItem(
            username: 'Arwa',
            time: '3w',
            content: 'ayo kita cari tahu bareng',
            quote: 'Saya ingin pendidikan membuat saya lebih mampu '
                'memahami manusia tanpa buru-buru merendahkannya.',
            publication: 'Unheard Things in Closed Rooms',
            likes: '9.9k',
            comments: '2',
            restacks: '1.6k',
          ),

          // Contoh Restack
          _NoteItem(
            username: 'claire',
            time: '3w',
            content: 'letter for you',
            restackedBy: 'Arwa',
            likes: '284',
            comments: '12',
            restacks: '35',
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 64,
        height: 64,
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: const Color(0xFFFF6719),
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(Icons.add, size: 29),
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
                radius: 20,
                backgroundColor: Color(0xFFEAEAEA),
                child: Icon(Icons.person, color: Colors.grey),
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
              const Icon(Icons.more_horiz, color: AppColors.iconSecondary),
              const SizedBox(width: 12),
              const Icon(Icons.close, color: AppColors.iconSecondary),
            ],
          ),
          if (content != null) ...[
            const SizedBox(height: 14),
            Text(
              content!,
              style: const TextStyle(
                fontSize: 16,
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
              constraints: const BoxConstraints(minHeight: 250),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF79300E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.format_quote,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    quote!,
                    style: const TextStyle(
                      fontSize: 22,
                      height: 1.4,
                      fontFamily: 'serif',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (publication != null) ...[
                    Text(
                      publication!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                      ),
                    ),
                  ],
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
        padding: const EdgeInsets.only(right: 20, top: 5, bottom: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: AppColors.iconSecondary),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'People to follow',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Text(
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
            height: 185,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: people.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final person = people[index];

                return Container(
                  width: 155,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 32,
                        backgroundColor: Color(0xFFEAEAEA),
                        child: Icon(
                          Icons.person,
                          size: 34,
                          color: AppColors.iconSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        person.$1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
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
                          fontSize: 9,
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
                            style: TextStyle(fontSize: 10),
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
