// lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  ApiClient._();
  static ApiClient? _instance;
  static ApiClient get instance => _instance ??= ApiClient._();

  late final Dio _dio = _buildDio();

  Dio get dio => _dio;

  Dio _buildDio() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeoutMs),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeoutMs),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      validateStatus: (s) => s != null && s < 500,
    ));

    dio.interceptors.add(_AuthInterceptor(dio));
    return dio;
  }
}

/// Intercepts every request to:
///   1. Attach the Bearer access token.
///   2. On 401, silently refresh the token and retry.
///   3. On refresh failure, clear storage and throw UnauthorizedException.
class _AuthInterceptor extends Interceptor {
  final Dio dio;
  bool _isRefreshing = false;

  _AuthInterceptor(this.dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureStorageService.instance.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    if (statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await SecureStorageService.instance.getRefreshToken();
        if (refreshToken == null) throw const UnauthorizedException();

        final refreshDio = Dio(BaseOptions(
          baseUrl: AppConstants.baseUrl,
          headers: {'Content-Type': 'application/json'},
        ));
        final response = await refreshDio.post(
          '/auth/refresh',
          data: {'refresh_token': refreshToken},
        );

        final data = response.data['data'] as Map<String, dynamic>;
        await SecureStorageService.instance.saveTokens(
          accessToken:  data['access_token'] as String,
          refreshToken: data['refresh_token'] as String,
        );

        // Retry original request with new token
        err.requestOptions.headers['Authorization'] =
            'Bearer ${data['access_token']}';
        final retryResponse = await dio.fetch(err.requestOptions);
        return handler.resolve(retryResponse);
      } catch (_) {
        await SecureStorageService.instance.clearAll();
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const UnauthorizedException(),
            type: DioExceptionType.badResponse,
          ),
        );
      } finally {
        _isRefreshing = false;
      }
    }

    // Map non-401 errors to AppException
    final responseData = err.response?.data;
    if (responseData is Map<String, dynamic>) {
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: AppException.fromJson(responseData),
          response: err.response,
          type: err.type,
        ),
      );
    }

    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown) {
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const NetworkException(),
          type: err.type,
        ),
      );
    }

    return handler.next(err);
  }
}

/// Helper extension so feature repositories can call dio cleanly.
extension ApiClientExt on Dio {
  dynamic extractData(Response response) {
    final body = response.data as Map<String, dynamic>?;
    if (body == null || body['success'] != true) {
      throw AppException.fromJson(response.data as Map<String, dynamic>);
    }
    return body['data'];
  }
}
