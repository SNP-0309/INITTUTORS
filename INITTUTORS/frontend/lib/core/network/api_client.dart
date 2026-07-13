import 'package:dio/dio.dart';

import 'api_endpoints.dart';

/// Single configured [Dio] instance for talking to the AMS backend.
///
/// Mirrors frontend.md §10: base URL, auth-token attachment, and centralized
/// error handling live here so feature code never constructs raw HTTP calls.
/// The auth interceptor is scaffolded but does not yet read a real token — that
/// arrives with the auth feature. No endpoints/requests are defined here.
class ApiClient {
  ApiClient() : _dio = _build();

  final Dio _dio;

  Dio get dio => _dio;

  static Dio _build() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: 'application/json',
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // TODO(auth): attach `Authorization: Bearer <access_token>` from the
          // auth store once it exists (JWT per api.md §3).
          handler.next(options);
        },
        onError: (error, handler) {
          // TODO(auth): on 401, trigger silent refresh + redirect-to-login
          // (frontend.md §12.2). Centralized error normalization goes here.
          handler.next(error);
        },
      ),
    );

    return dio;
  }
}
