// lib/core/storage/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class SecureStorageService {
  SecureStorageService._();
  static final SecureStorageService instance = SecureStorageService._();

  static final _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: AppConstants.keyAccessToken,  value: accessToken),
      _storage.write(key: AppConstants.keyRefreshToken, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken()  => _storage.read(key: AppConstants.keyAccessToken);
  Future<String?> getRefreshToken() => _storage.read(key: AppConstants.keyRefreshToken);

  Future<void> saveUserJson(String json) =>
      _storage.write(key: AppConstants.keyUserJson, value: json);

  Future<String?> getUserJson() => _storage.read(key: AppConstants.keyUserJson);

  Future<void> clearAll() => _storage.deleteAll();
}
