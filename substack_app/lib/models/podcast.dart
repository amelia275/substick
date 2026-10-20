import 'package:flutter/material.dart';
import 'episode.dart';

class Podcast {
  final int id;
  final String shortTitle;
  final String title;
  final String author;
  final String description;
  final String coverUrl;
  final String accentColorHex;
  final bool isSubscribed;
  final List<Episode> episodes;

  const Podcast({
    required this.id,
    required this.shortTitle,
    required this.title,
    required this.author,
    required this.description,
    required this.coverUrl,
    required this.accentColorHex,
    required this.isSubscribed,
    required this.episodes,
  });

  factory Podcast.fromJson(Map<String, dynamic> json) {
    final rawEpisodes = json['episodes'] as List<dynamic>? ?? const [];
    final parsedEpisodes = rawEpisodes
        .whereType<Map<String, dynamic>>()
        .map(Episode.fromJson)
        .toList();

    final hasFeaturedVideo = parsedEpisodes.any((e) => e.isFeaturedVideo);

    return Podcast(
      id: (json['id'] as num?)?.toInt() ?? 0,
      shortTitle: (json['short_title'] as String?) ??
          (json['title'] as String?) ??
          '',
      title: (json['title'] as String?) ?? '',
      author: (json['author_name'] as String?) ??
          (json['author'] as String?) ??
          '',
      description: (json['description'] as String?) ?? '',
      coverUrl: (json['cover_url'] as String?) ?? '',
      accentColorHex: (json['accent_color'] as String?) ?? '#539022',
      isSubscribed: (json['is_subscribed'] as bool?) ?? !hasFeaturedVideo,
      episodes: parsedEpisodes,
    );
  }

  Color get accentColor {
    final hex = accentColorHex.replaceAll('#', '');
    if (hex.length == 6) {
      final parsed = int.tryParse('FF$hex', radix: 16);
      if (parsed != null) return Color(parsed);
    }
    return const Color(0xFF539022);
  }
}
