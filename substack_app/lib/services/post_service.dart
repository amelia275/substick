import '../core/network/api_client.dart';
import '../models/post.dart';

class PostService {
  final ApiClient api;
  PostService(this.api);

  Future<List<Post>> getPosts({String type = 'note'}) async {
    final result = await api.get('/posts?type=$type') as Map<String, dynamic>;
    final items = result['data'] as List<dynamic>;
    return items.map((item) => Post.fromJson(item as Map<String, dynamic>)).toList();
  }
}
