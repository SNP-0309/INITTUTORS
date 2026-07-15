import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';

/// Thin HTTP layer for the auth endpoints (api.md §3.4). Returns the decoded
/// `data` envelope; error handling/mapping happens in the repository/controller.
class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await _client.dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> me() async {
    final res = await _client.dio.get('/auth/me');
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<void> logout({required String refreshToken}) async {
    await _client.dio.post(
      '/auth/logout',
      data: {'refresh_token': refreshToken},
    );
  }

  /// Extracts a human-readable message from the standard error envelope.
  static String messageFrom(Object error, String fallback) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['error'] is Map) {
        final msg = data['error']['message'];
        if (msg is String && msg.isNotEmpty) return msg;
      }
    }
    return fallback;
  }
}
