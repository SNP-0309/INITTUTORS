import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/config/env.dart';

/// Secure, persistent storage for JWT tokens.
///
/// Backed by the platform keystore/keychain via `flutter_secure_storage` —
/// tokens are never written to plain shared-preferences. Enables auto-login
/// across app restarts.
class TokenStorage {
  TokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? ((kIsWeb || Env.useMockApi) ? null : const FlutterSecureStorage());

  final FlutterSecureStorage? _storage;

  static const _accessKey = 'ams_access_token';
  static const _refreshKey = 'ams_refresh_token';

  // In-memory fallback for Mock / Web local testing environments
  String? _mockAccessToken;
  String? _mockRefreshToken;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    if (Env.useMockApi || _storage == null) {
      _mockAccessToken = accessToken;
      _mockRefreshToken = refreshToken;
      return;
    }
    try {
      await _storage!.write(key: _accessKey, value: accessToken);
      await _storage!.write(key: _refreshKey, value: refreshToken);
    } catch (_) {
      // Fallback to in-memory on Web / unsupported platforms
      _mockAccessToken = accessToken;
      _mockRefreshToken = refreshToken;
    }
  }

  Future<String?> readAccessToken() async {
    if (Env.useMockApi || _storage == null) {
      return _mockAccessToken;
    }
    try {
      return await _storage!.read(key: _accessKey);
    } catch (_) {
      return _mockAccessToken;
    }
  }

  Future<String?> readRefreshToken() async {
    if (Env.useMockApi || _storage == null) {
      return _mockRefreshToken;
    }
    try {
      return await _storage!.read(key: _refreshKey);
    } catch (_) {
      return _mockRefreshToken;
    }
  }


  Future<bool> hasTokens() async =>
      (await readAccessToken()) != null && (await readRefreshToken()) != null;

  Future<void> clear() async {
    _mockAccessToken = null;
    _mockRefreshToken = null;
    if (Env.useMockApi || _storage == null) return;
    try {
      await _storage!.delete(key: _accessKey);
      await _storage!.delete(key: _refreshKey);
    } catch (_) {}
  }
}

