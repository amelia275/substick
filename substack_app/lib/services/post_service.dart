import '../core/network/api_client.dart';

class PostService {
  final ApiClient _apiClient;

  PostService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<dynamic>> fetchPosts() async {
    final result = await _apiClient.get('/posts');

    if (result is! Map<String, dynamic>) {
      throw Exception('Format respons API tidak sesuai');
    }

    final data = result['data'];

    if (data is! List) {
      throw Exception('Data post tidak ditemukan');
    }

    return data;
  }
}
