import 'auth_user.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Immutable auth state held by the auth controller and read by the router
/// guard. `unknown` is the pre-bootstrap state shown behind the splash screen.
class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.isSubmitting = false,
    this.error,
  });

  final AuthStatus status;
  final AuthUser? user;
  final bool isSubmitting;
  final String? error;

  const AuthState.unknown() : this(status: AuthStatus.unknown);

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    bool? isSubmitting,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }
}
