// lib/core/errors/app_exception.dart

class AppException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  const AppException(this.message, {this.code, this.statusCode});

  factory AppException.fromJson(Map<String, dynamic> json) {
    final error = json['error'] as Map<String, dynamic>?;
    return AppException(
      error?['message'] as String? ?? 'An unexpected error occurred.',
      code: error?['code'] as String?,
    );
  }

  @override
  String toString() => 'AppException[$code]: $message';
}

class UnauthorizedException extends AppException {
  const UnauthorizedException() : super('Session expired. Please log in again.', code: 'UNAUTHORIZED', statusCode: 401);
}

class NetworkException extends AppException {
  const NetworkException() : super('No network connection. Please check your internet.', code: 'NETWORK_ERROR');
}
