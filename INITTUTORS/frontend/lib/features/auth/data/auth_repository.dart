// lib/features/auth/data/auth_repository.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import 'auth_models.dart';

class AuthRepository {
  final Dio _dio = ApiClient.instance.dio;
  final _storage = SecureStorageService.instance;

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/auth/login', data: {
      'email':    email,
      'password': password,
    });
    final data = _dio.extractData(response) as Map<String, dynamic>;
    final loginResponse = LoginResponse.fromJson(data);

    await _storage.saveTokens(
      accessToken:  loginResponse.accessToken,
      refreshToken: loginResponse.refreshToken,
    );
    await _storage.saveUserJson(jsonEncode(loginResponse.user.toJson()));

    return loginResponse;
  }

  Future<User?> restoreSession() async {
    final userJson = await _storage.getUserJson();
    if (userJson == null) return null;
    try {
      return User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<User> getMe() async {
    final response = await _dio.get('/auth/me');
    final data = _dio.extractData(response) as Map<String, dynamic>;
    final user = User.fromJson(data);
    await _storage.saveUserJson(jsonEncode(user.toJson()));
    return user;
  }

  Future<void> logout() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken != null) {
      try {
        await _dio.post('/auth/logout', data: {'refresh_token': refreshToken});
      } catch (_) {}
    }
    await _storage.clearAll();
  }
}
