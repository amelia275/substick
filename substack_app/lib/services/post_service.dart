import '../core/network/api_client.dart';
import '../models/post.dart';
import '../core/network/api_exception.dart';

class PostService {
  final ApiClient _apiClient;

  PostService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();
      
  Future<Post> fetchPost(int id) async {
    final result = await _apiClient.get('/posts/$id');

    if (result is! Map || result['data'] is! Map) {
      throw const ApiException('Format respons tidak sesuai');
    }

    return Post.fromJson(Map<String, dynamic>.from(result['data'] as Map));
  }
  Future<List<Post>> fetchPosts() async {
    final result = await _apiClient.get('/posts');

    if (result is! Map<String, dynamic>) {
      throw Exception('Format respons API tidak sesuai');
    }

    final data = result['data'];

    if (data is! List) {
      throw Exception('Data post tidak ditemukan');
    }

    return data.map((item) {
      if (item is! Map) {
        throw Exception('Format data post tidak sesuai');
      }

      return Post.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }

    Future<Post> createNote(String content) async {
    final result = await _apiClient.post(
      '/posts',
      body: {'content': content},
    );

    if (result is! Map || result['data'] is! Map) {
      throw const ApiException('Format respons tidak sesuai');
    }

    return Post.fromJson(Map<String, dynamic>.from(result['data'] as Map));
  }
}
