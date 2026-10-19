import '../core/network/api_client.dart';
import '../models/notification_item.dart';

class NotificationService {
  final ApiClient _apiClient;

  NotificationService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<NotificationItem>> fetchNotifications() async {
    final result = await _apiClient.get('/notifications');

    if (result is! Map<String, dynamic>) {
      throw Exception('Format respons API tidak sesuai');
    }

    final data = result['data'];

    if (data is! List) {
      throw Exception('Data notifikasi tidak ditemukan');
    }

    return data.map((item) {
      if (item is! Map) {
        throw Exception('Format data notifikasi tidak sesuai');
      }

      return NotificationItem.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }
}
