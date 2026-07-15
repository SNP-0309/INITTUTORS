import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure, persistent storage for JWT tokens.
///
/// Backed by the platform keystore/keychain via `flutter_secure_storage` —
/// tokens are never written to plain shared-preferences. Enables auto-login
/// across app restarts.
class TokenStorage {
  TokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _accessKey = 'ams_access_token';
  static const _refreshKey = 'ams_refresh_token';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  Future<String?> readAccessToken() => _storage.read(key: _accessKey);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);

  Future<bool> hasTokens() async =>
      (await readAccessToken()) != null && (await readRefreshToken()) != null;

  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
