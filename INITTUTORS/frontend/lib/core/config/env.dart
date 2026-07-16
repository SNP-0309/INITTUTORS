import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized, typed access to environment configuration.
///
/// Values are sourced from a bundled `.env` file (via `flutter_dotenv`) with a
/// `--dart-define` override taking precedence, so the same build can be pointed
/// at different backends without code changes (mirrors frontend.md's Vite env
/// support). No secrets belong here — only client-safe config like the API URL.
class Env {
  const Env._();

  /// Loads the `.env` asset. Call once in `main()` before `runApp`.
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  static String _read(String key, {String fallback = ''}) {
    // Compile-time override wins over the runtime .env file.
    String? fromDefine;
    switch (key) {
      case 'API_BASE_URL':
        fromDefine = const String.fromEnvironment('API_BASE_URL');
        break;
      case 'ENVIRONMENT':
        fromDefine = const String.fromEnvironment('ENVIRONMENT');
        break;
      case 'USE_MOCK_API':
        fromDefine = const String.fromEnvironment('USE_MOCK_API');
        break;
    }
    if (fromDefine != null && fromDefine.isNotEmpty) return fromDefine;
    return dotenv.maybeGet(key) ?? fallback;
  }

  /// Base URL of the AMS backend, e.g. http://10.0.2.2:8000 (Android emulator).
  static String get apiBaseUrl =>
      _read('API_BASE_URL', fallback: 'http://localhost:8000');

  /// Current environment name: development | staging | production.
  static String get environment => _read('ENVIRONMENT', fallback: 'development');

  static bool get isProduction => environment == 'production';

  /// True if using mock API responses instead of a running backend.
  static bool get useMockApi => _read('USE_MOCK_API', fallback: 'false') == 'true';
}
