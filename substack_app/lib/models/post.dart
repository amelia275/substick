class Post {
  final int id;
  final int userId;
  final int? publicationId;
  final String type;
  final String? title;
  final String content;
  final String? imageUrl;
  final String status;
  final String? authorName;
  final String? username;
  final String? publicationName;
  final String? restackedBy;
  final int likesCount;
  final int commentsCount;
  final int restacksCount;
  final DateTime? publishedAt;

  const Post({
    required this.id,
    required this.userId,
    this.publicationId,
    required this.type,
    this.title,
    required this.content,
    this.imageUrl,
    this.status = 'published',
    this.authorName,
    this.username,
    this.publicationName,
    this.restackedBy,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.restacksCount = 0,
    this.publishedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : <String, dynamic>{};

    final publication = json['publication'] is Map
        ? Map<String, dynamic>.from(json['publication'] as Map)
        : <String, dynamic>{};

    final restacks = json['restacks'] is List
        ? json['restacks'] as List
        : <dynamic>[];

    String? restackerName;

    if (restacks.isNotEmpty && restacks.first is Map) {
      final restack = Map<String, dynamic>.from(
        restacks.first as Map,
      );
      final restacker = restack['user'];

      if (restacker is Map) {
        final restackerUser = Map<String, dynamic>.from(restacker);
        restackerName = restackerUser['name'] as String?;
      }
    }

    return Post(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      publicationId: (json['publication_id'] as num?)?.toInt(),
      type: json['type'] as String? ?? 'note',
      title: json['title'] as String?,
      content: json['content'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      status: json['status'] as String? ?? 'published',
      authorName: user['name'] as String?,
      username: user['username'] as String?,
      publicationName: publication['name'] as String?,
      restackedBy: restackerName,
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
      restacksCount: (json['restacks_count'] as num?)?.toInt() ?? 0,
      publishedAt: json['published_at'] == null
          ? null
          : DateTime.tryParse(json['published_at'] as String),
    );
  }
}
