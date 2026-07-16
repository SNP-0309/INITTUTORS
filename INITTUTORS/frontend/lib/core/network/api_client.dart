import 'package:dio/dio.dart';

import '../../features/auth/data/token_storage.dart';
import '../config/env.dart';
import 'api_endpoints.dart';
import 'mock_interceptor.dart';

/// Single configured [Dio] instance for talking to the AMS backend.
///
/// Mirrors frontend.md §10: base URL, auth-token attachment, and a single
/// silent refresh-on-401 (frontend.md §12.2). Feature code never constructs
/// raw HTTP calls — it goes through repositories that use this client.
class ApiClient {
  ApiClient(this._tokens) : _dio = Dio(_baseOptions()) {
    if (Env.useMockApi) {
      _dio.interceptors.add(MockInterceptor());
    } else {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: _onRequest,
          onError: _onError,
        ),
      );
    }
  }

  final TokenStorage _tokens;
  final Dio _dio;
  bool _isRefreshing = false;

  Dio get dio => _dio;

  static BaseOptions _baseOptions() => BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: 'application/json',
      );

  bool _isAuthPath(String path) =>
      path.contains('/auth/login') || path.contains('/auth/refresh');

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isAuthPath(options.path)) {
      final access = await _tokens.readAccessToken();
      if (access != null) {
        options.headers['Authorization'] = 'Bearer $access';
      }
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final response = error.response;
    final path = error.requestOptions.path;
    final alreadyRetried = error.requestOptions.extra['retried'] == true;

    final shouldRefresh = response?.statusCode == 401 &&
        !_isAuthPath(path) &&
        !alreadyRetried &&
        !_isRefreshing;

    if (!shouldRefresh) {
      return handler.next(error);
    }

    final refreshed = await _tryRefresh();
    if (!refreshed) {
      await _tokens.clear();
      return handler.next(error);
    }

    // Retry the original request once with the new access token.
    try {
      final access = await _tokens.readAccessToken();
      final opts = error.requestOptions
        ..headers['Authorization'] = 'Bearer $access'
        ..extra['retried'] = true;
      final retryResponse = await _dio.fetch(opts);
      return handler.resolve(retryResponse);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  Future<bool> _tryRefresh() async {
    _isRefreshing = true;
    try {
      final refresh = await _tokens.readRefreshToken();
      if (refresh == null) return false;

      // Use a bare Dio so this call skips the interceptors above.
      final bare = Dio(_baseOptions());
      final res = await bare.post(
        '/auth/refresh',
        data: {'refresh_token': refresh},
      );
      final data = res.data['data'] as Map<String, dynamic>;
      await _tokens.saveTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );
      return true;
    } on DioException {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }
}
