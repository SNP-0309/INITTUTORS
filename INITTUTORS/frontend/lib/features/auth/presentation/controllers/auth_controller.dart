import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/app_providers.dart';
import '../../data/auth_api.dart';
import '../../domain/auth_state.dart';

/// Owns authentication state for the whole app: bootstrap (auto-login), login,
/// and logout. The router guard reads this to decide where to send the user.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState.unknown();

  /// Auto-login on launch: restore a session from securely stored tokens.
  Future<void> bootstrap() async {
    final repo = ref.read(authRepositoryProvider);
    final user = await repo.restoreSession();
    state = user != null
        ? AuthState(status: AuthStatus.authenticated, user: user)
        : const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (error) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: AuthApi.messageFrom(error, 'Login failed. Please try again.'),
      );
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
