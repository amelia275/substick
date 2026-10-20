import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  static const Duration _timeout = Duration(seconds: 60);

  final http.Client _client;
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<dynamic> get(String path) => _send('GET', path);

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) =>
      _send('POST', path, body: body);

  Future<dynamic> delete(String path) => _send('DELETE', path);

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final headers = <String, String>{'Accept': 'application/json'};

    final token = await TokenStorage.read();
    if (token != null) headers['Authorization'] = 'Bearer $token';
    if (body != null) headers['Content-Type'] = 'application/json';

    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final http.Response response;

    try {
      final Future<http.Response> call;
      switch (method) {
        case 'POST':
          call = _client.post(
            uri,
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          );
        case 'DELETE':
          call = _client.delete(uri, headers: headers);
        default:
          call = _client.get(uri, headers: headers);
      }
      debugPrint('API REQUEST: $method $uri');
      response = await call.timeout(_timeout);
    } on TimeoutException {
      debugPrint('API TIMEOUT: $method $uri');
      throw const ApiException(
        'Server tidak merespons. Cek alamat API dan pastikan Laravel berjalan.',
      );
    } catch (_) {
      throw const ApiException(
        'Tidak bisa terhubung ke server. Pastikan Laravel berjalan dan alamat API benar.',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body);
      } on FormatException {
        throw ApiException(
          'Respons server bukan JSON yang valid',
          statusCode: response.statusCode,
        );
      }
    }

    throw ApiException(
      _messageFrom(response),
      statusCode: response.statusCode,
    );
  }

  String _messageFrom(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map) {
        final errors = body['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) return first.first.toString();
        }
        if (body['message'] is String) return body['message'] as String;
      }
    } catch (_) {
      // Body bukan JSON, pakai pesan bawaan.
    }
    return 'Request gagal';
  }

  void close() => _client.close();
}
