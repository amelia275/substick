class Post {
  final int id;
  final int userId;
  final String type;
  final String? title;
  final String body;
  final String? coverUrl;
  final String? authorName;
  final int likesCount;
  final int commentsCount;

  const Post({
    required this.id, required this.userId, required this.type,
    this.title, required this.body, this.coverUrl, this.authorName,
    this.likesCount = 0, this.commentsCount = 0,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json['id'] as int,
    userId: json['user_id'] as int,
    type: json['type'] as String? ?? 'note',
    title: json['title'] as String?,
    body: json['body'] as String? ?? '',
    coverUrl: json['cover_url'] as String?,
    authorName: json['author_name'] as String?,
    likesCount: json['likes_count'] as int? ?? 0,
    commentsCount: json['comments_count'] as int? ?? 0,
  );
}
