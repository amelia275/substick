class Comment {
  final int id;
  final int postId;
  final int userId;
  final String content;
  final String? authorName;
  final String? username;
  final String? authorAvatarUrl;
  final DateTime? createdAt;

  const Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    this.authorName,
    this.username,
    this.authorAvatarUrl,
    this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : <String, dynamic>{};

    return Comment(
      id: (json['id'] as num).toInt(),
      postId: (json['post_id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      content: (json['content'] ?? '') as String,
      authorName: user['name'] as String?,
      username: user['username'] as String?,
      authorAvatarUrl: user['avatar_url'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
    );
  }
}