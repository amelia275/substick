import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../models/user.dart';

/// Menyimpan akun yang sedang login. Layar yang butuh nama atau avatar
/// cukup mendengarkan [user].
class CurrentUserState {
  CurrentUserState._();

  static final ValueNotifier<User?> user = ValueNotifier<User?>(null);

  /// Ambil data akun dari server kalau belum ada.
  static Future<void> ensureLoaded() async {
    if (user.value != null) return;

    try {
      final result = await ApiClient().get('/me');
      if (result is Map && result['user'] is Map) {
        user.value =
            User.fromJson(Map<String, dynamic>.from(result['user'] as Map));
      }
    } catch (_) {
      // Dibiarkan kosong. Layar yang butuh akan memakai tampilan cadangan.
    }
  }

  static void clear() => user.value = null;
}