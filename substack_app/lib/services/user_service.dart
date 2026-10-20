import '../core/network/api_client.dart';
import '../models/user_profile.dart';

class UserService {
  final ApiClient _apiClient;

  UserService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<UserProfile> fetchProfile(int userId) async {
    final result = await _apiClient.get('/users/$userId');

    if (result is! Map<String, dynamic>) {
      throw Exception('Format respons API tidak sesuai');
    }

    final data = result['data'];

    if (data is! Map) {
      throw Exception('Data profil tidak ditemukan');
    }

    return UserProfile.fromJson(Map<String, dynamic>.from(data));
  }
}
