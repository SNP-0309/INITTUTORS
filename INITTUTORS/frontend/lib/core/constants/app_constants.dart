// lib/core/constants/app_constants.dart

class AppConstants {
  AppConstants._();

  // ─── API ─────────────────────────────────────────────────────────────────
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1'; // Android emulator
  // For physical device or deployed backend, change to your actual URL:
  // static const String baseUrl = 'http://192.168.x.x:8000/api/v1';

  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 30000;

  // ─── Storage keys ────────────────────────────────────────────────────────
  static const String keyAccessToken  = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserJson     = 'user_json';

  // ─── Pagination ───────────────────────────────────────────────────────────
  static const int defaultPageSize = 10;

  // ─── App name ─────────────────────────────────────────────────────────────
  static const String appName = 'Academy IQ';
}
