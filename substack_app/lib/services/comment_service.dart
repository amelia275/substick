import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/comment.dart';

class CommentService {
  final ApiClient _apiClient;

  CommentService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<Comment> createComment(int postId, String content) async {
    final result = await _apiClient.post(
      '/posts/$postId/comments',
      body: {'content': content},
    );

    if (result is! Map || result['data'] is! Map) {
      throw const ApiException('Format respons tidak sesuai');
    }

    return Comment.fromJson(Map<String, dynamic>.from(result['data'] as Map));
  }
}