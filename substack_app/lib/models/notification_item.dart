class NotificationItem {
  final int id;
  final int recipientId;
  final int? actorId;
  final int? postId;
  final int? commentId;
  final String type;
  final String? message;
  final bool isRead;
  final DateTime? createdAt;

  final String? actorName;
  final String? actorUsername;
  final String? actorBio;
  final String? actorAvatarUrl;

  final String? postTitle;
  final String? postContent;
  final String? postType;
  final String? postImageUrl;
  final String? publicationName;

  final String? commentContent;

  const NotificationItem({
    required this.id,
    required this.recipientId,
    this.actorId,
    this.postId,
    this.commentId,
    required this.type,
    this.message,
    this.isRead = false,
    this.createdAt,
    this.actorName,
    this.actorUsername,
    this.actorBio,
    this.actorAvatarUrl,
    this.postTitle,
    this.postContent,
    this.postType,
    this.postImageUrl,
    this.publicationName,
    this.commentContent,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final actor = json['actor'] is Map
        ? Map<String, dynamic>.from(json['actor'] as Map)
        : <String, dynamic>{};

    final post = json['post'] is Map
        ? Map<String, dynamic>.from(json['post'] as Map)
        : <String, dynamic>{};

    final publication = post['publication'] is Map
        ? Map<String, dynamic>.from(post['publication'] as Map)
        : <String, dynamic>{};

    final comment = json['comment'] is Map
        ? Map<String, dynamic>.from(json['comment'] as Map)
        : <String, dynamic>{};

    return NotificationItem(
      id: (json['id'] as num).toInt(),
      recipientId: (json['recipient_id'] as num?)?.toInt() ?? 0,
      actorId: (json['actor_id'] as num?)?.toInt(),
      postId: (json['post_id'] as num?)?.toInt(),
      commentId: (json['comment_id'] as num?)?.toInt(),
      type: json['type'] as String? ?? 'like',
      message: json['message'] as String?,
      isRead: json['is_read'] == true || json['is_read'] == 1,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'] as String),
      actorName: actor['name'] as String?,
      actorUsername: actor['username'] as String?,
      actorBio: actor['bio'] as String?,
      actorAvatarUrl: actor['avatar_url'] as String?,
      postTitle: post['title'] as String?,
      postContent: post['content'] as String?,
      postType: post['type'] as String?,
      postImageUrl: post['image_url'] as String?,
      publicationName: publication['name'] as String?,
      commentContent: comment['content'] as String?,
    );
  }

  String get displayActionText {
    if (message != null && message!.trim().isNotEmpty) {
      return message!.trim();
    }
    switch (type) {
      case 'like':
        return postType == 'article' ? 'liked your post' : 'liked your note';
      case 'restack':
        return 'restacked your note';
      case 'comment':
        return 'replied to your note';
      case 'follow':
        return 'followed you';
      case 'new_post':
        return 'published a new post';
      default:
        return 'interacted with your post';
    }
  }

  String? get displayContentPreview {
    if (type == 'comment' &&
        commentContent != null &&
        commentContent!.isNotEmpty) {
      return commentContent;
    }
    if (type == 'follow') {
      return actorBio;
    }
    if (postTitle != null && postTitle!.isNotEmpty) {
      return postTitle;
    }
    if (postContent != null && postContent!.isNotEmpty) {
      return postContent;
    }
    return null;
  }
}
