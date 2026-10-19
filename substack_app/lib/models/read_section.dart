// Simpan di: lib/models/read_section.dart
import 'post.dart';

/// Satu section di feed Bacaan, mis. "Romansa" beserta daftar post-nya.
/// Isi post memakai model [Post] milik tim tanpa perubahan.
class ReadSection {
  final String title;
  final List<Post> posts;

  const ReadSection({required this.title, required this.posts});

  factory ReadSection.fromJson(Map<String, dynamic> json) {
    final rawPosts = json['posts'];

    return ReadSection(
      title: json['category']?.toString() ?? '',
      posts: rawPosts is List
          ? rawPosts.map((item) {
              if (item is! Map) {
                throw Exception('Format data post tidak sesuai');
              }
              return Post.fromJson(Map<String, dynamic>.from(item));
            }).toList()
          : <Post>[],
    );
  }
}