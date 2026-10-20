import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/storage/token_storage.dart';
import '../models/user.dart';
import '../state/current_user_state.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<User> login({required String email, required String password}) async {
    final result = await _apiClient.post(
      '/login',
      body: {'email': email, 'password': password},
    );
    return _saveSession(result);
  }

  Future<User> register({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    final result = await _apiClient.post(
      '/register',
      body: {
        'name': name,
        'username': username,
        'email': email,
        'password': password,
      },
    );
    return _saveSession(result);
  }

  Future<User> fetchMe() async {
    final result = await _apiClient.get('/me');
    if (result is! Map || result['user'] is! Map) {
      throw const ApiException('Format respons akun tidak sesuai');
    }
    final user =
        User.fromJson(Map<String, dynamic>.from(result['user'] as Map));
    CurrentUserState.user.value = user;
    return user;
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/logout');
    } on ApiException {
      // Token mungkin sudah tidak valid di server. Tetap hapus token lokal.
    } finally {
      await TokenStorage.clear();
      CurrentUserState.clear();
    }
  }

  Future<User> _saveSession(dynamic result) async {
    if (result is! Map || result['token'] is! String || result['user'] is! Map) {
      throw const ApiException('Format respons login tidak sesuai');
    }
    await TokenStorage.save(result['token'] as String);
    final user =
        User.fromJson(Map<String, dynamic>.from(result['user'] as Map));
    CurrentUserState.user.value = user;
    return user;
  }
}