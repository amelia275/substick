import 'package:flutter/material.dart';
import '../features/podcast/podcast_player_controller.dart';

class Episode {
  final int id;
  final int podcastId;
  final String title;
  final String subtitle;
  final String captionSnippet;
  final String articleBody;
  final String thumbnailUrl;
  final String? audioUrl;
  final int durationSeconds;
  final int likesCount;
  final int restacksCount;
  final String timeAgo;
  final String publishedDateText;
  final bool isFeaturedVideo;
  final List<PodcastCommentData> comments;

  const Episode({
    required this.id,
    required this.podcastId,
    required this.title,
    required this.subtitle,
    required this.captionSnippet,
    required this.articleBody,
    required this.thumbnailUrl,
    this.audioUrl,
    required this.durationSeconds,
    required this.likesCount,
    required this.restacksCount,
    required this.timeAgo,
    required this.publishedDateText,
    required this.isFeaturedVideo,
    this.comments = const [],
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    final rawComments = json['comments'] as List<dynamic>? ?? const [];
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
            likedByAuthor: 'Disukai oleh Penulis',
            content: (item['content'] as String?) ?? '',
            likesCount: 12 + (i * 7),
            avatarColor: avatarColors[i % avatarColors.length],
          ),
        );
      }
    }

    final isFeatured = (json['is_featured_video'] as bool?) ?? false;

    return Episode(
      id: (json['id'] as num?)?.toInt() ?? 0,
      podcastId: (json['podcast_id'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?) ?? '',
      subtitle: (json['subtitle'] as String?) ?? '',
      captionSnippet: (json['caption_snippet'] as String?) ?? '',
      articleBody: (json['description'] as String?) ??
          (json['article_body'] as String?) ??
          '',
      thumbnailUrl: (json['thumbnail_url'] as String?) ?? '',
      audioUrl: json['audio_url'] as String?,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      restacksCount: (json['restacks_count'] as num?)?.toInt() ?? 0,
      timeAgo: (json['time_ago'] as String?) ??
          (isFeatured ? '1BLN YANG LALU' : '1TH YANG LALU'),
      publishedDateText: (json['published_date_text'] as String?) ??
          '1 Februari 2025 pukul 01.31',
      isFeaturedVideo: isFeatured,
      comments: parsedComments,
    );
  }

  PodcastEpisodeItem toPlayerItem({
    required String showTitle,
    required String publicationName,
    required String authorName,
    required String coverUrl,
  }) {
    return PodcastEpisodeItem(
      id: 'ep-$id',
      showTitle: showTitle,
      publicationName: publicationName,
      authorName: authorName,
      timeAgo: timeAgo,
      publishedDateText: publishedDateText,
      title: title,
      subtitle: subtitle,
      captionSnippet: captionSnippet,
      articleBody: articleBody,
      coverUrl: coverUrl,
      thumbnailUrl: thumbnailUrl.isNotEmpty ? thumbnailUrl : coverUrl,
      totalDurationSeconds: durationSeconds,
      likesCount: likesCount,
      restacksCount: restacksCount,
      comments: comments,
    );
  }
}
