import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';

class InteractionResult {
  final bool active;
  final int count;

  const InteractionResult({required this.active, required this.count});
}

class InteractionService {
  final ApiClient _apiClient;

  InteractionService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<InteractionResult> setLike(int postId, {required bool liked}) {
    return _send(
      '/posts/$postId/like',
      on: liked,
      activeKey: 'liked',
      countKey: 'likes_count',
    );
  }

  Future<InteractionResult> setRestack(int postId, {required bool restacked}) {
    return _send(
      '/posts/$postId/restack',
      on: restacked,
      activeKey: 'restacked',
      countKey: 'restacks_count',
    );
  }

  Future<InteractionResult> _send(
    String path, {
    required bool on,
    required String activeKey,
    required String countKey,
  }) async {
    final result =
        on ? await _apiClient.post(path) : await _apiClient.delete(path);

    if (result is! Map) {
      throw const ApiException('Format respons tidak sesuai');
    }

    return InteractionResult(
      active: result[activeKey] == true,
      count: (result[countKey] as num?)?.toInt() ?? 0,
    );
  }
}