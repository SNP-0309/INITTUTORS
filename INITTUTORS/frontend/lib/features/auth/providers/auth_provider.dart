// lib/features/auth/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_models.dart';
import '../data/auth_repository.dart';

// ─── Repository provider ─────────────────────────────────────────────────────
final authRepositoryProvider = Provider<AuthRepository>((_) => AuthRepository());

// ─── Auth state ───────────────────────────────────────────────────────────────
sealed class AuthState {
  const AuthState();
}
class AuthInitial      extends AuthState { const AuthInitial(); }
class AuthLoading      extends AuthState { const AuthLoading(); }
class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);
}
class AuthUnauthenticated extends AuthState { const AuthUnauthenticated(); }
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

// ─── Notifier ─────────────────────────────────────────────────────────────────
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  AuthNotifier(this._repo) : super(const AuthInitial()) {
    _restore();
  }

  Future<void> _restore() async {
    final user = await _repo.restoreSession();
    if (user != null) {
      state = AuthAuthenticated(user);
    } else {
      state = const AuthUnauthenticated();
    }
  }

  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    try {
      final response = await _repo.login(email: email, password: password);
      state = AuthAuthenticated(response.user);
    } catch (e) {
      state = AuthError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthUnauthenticated();
  }

  User? get currentUser =>
      state is AuthAuthenticated ? (state as AuthAuthenticated).user : null;
}

// ─── Providers ────────────────────────────────────────────────────────────────
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

final currentUserProvider = Provider<User?>((ref) {
  final state = ref.watch(authNotifierProvider);
  return state is AuthAuthenticated ? state.user : null;
});
