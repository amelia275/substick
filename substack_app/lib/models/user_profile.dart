import 'post.dart';
import 'user.dart';

Map<String, dynamic> _map(dynamic value) =>
    Map<String, dynamic>.from(value as Map);

DateTime? _date(dynamic value) =>
    value == null ? null : DateTime.tryParse(value.toString());

List<T> _list<T>(dynamic value, T Function(Map<String, dynamic>) parse) {
  if (value is! List) return <T>[];
  return value.whereType<Map>().map((e) => parse(_map(e))).toList();
}

/// Satu baris di tab Activity: postingan sendiri atau restack.
class ProfileActivity {
  final bool isRestack;
  final DateTime? at;
  final Post post;

  const ProfileActivity({
    required this.isRestack,
    required this.post,
    this.at,
  });

  factory ProfileActivity.fromJson(Map<String, dynamic> json) {
    return ProfileActivity(
      isRestack: json['kind'] == 'restack',
      at: _date(json['at']),
      post: Post.fromJson(_map(json['post'])),
    );
  }
}

/// Komentar yang ditulis user (tab Replies).
class ProfileReply {
  final int id;
  final String content;
  final DateTime? createdAt;
  final Post? post;

  const ProfileReply({
    required this.id,
    required this.content,
    this.createdAt,
    this.post,
  });

  factory ProfileReply.fromJson(Map<String, dynamic> json) {
    return ProfileReply(
      id: (json['id'] as num).toInt(),
      content: json['content'] as String? ?? '',
      createdAt: _date(json['created_at']),
      post: json['post'] is Map ? Post.fromJson(_map(json['post'])) : null,
    );
  }
}

/// Publikasi yang diikuti user (tab Subscriptions).
class ProfileSubscription {
  final int id;
  final String name;
  final String? logoUrl;
  final bool isOwner;

  const ProfileSubscription({
    required this.id,
    required this.name,
    this.logoUrl,
    this.isOwner = false,
  });
}

class UserProfile {
  final User user;
  final int postsCount;
  final List<ProfileActivity> activity;
  final List<Post> posts;
  final List<ProfileReply> replies;
  final List<Post> likes;
  final List<ProfileSubscription> subscriptions;

  const UserProfile({
    required this.user,
    required this.postsCount,
    required this.activity,
    required this.posts,
    required this.replies,
    required this.likes,
    required this.subscriptions,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final user = User.fromJson(_map(json['user']));

    return UserProfile(
      user: user,
      postsCount: (json['posts_count'] as num?)?.toInt() ?? 0,
      activity: _list(json['activity'], ProfileActivity.fromJson),
      posts: _list(json['posts'], Post.fromJson),
      replies: _list(json['replies'], ProfileReply.fromJson),
      likes: _list(json['likes'], Post.fromJson),
      subscriptions: _list(
        json['subscriptions'],
        (p) => ProfileSubscription(
          id: (p['id'] as num).toInt(),
          name: p['name'] as String? ?? '',
          logoUrl: p['logo_url'] as String?,
          isOwner: (p['owner_id'] as num?)?.toInt() == user.id,
        ),
      ),
    );
  }
}
