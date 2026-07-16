import '../domain/auth_user.dart';
import 'auth_api.dart';
import 'token_storage.dart';

/// Orchestrates the auth API and secure token storage. The controller talks to
/// this repository, never to the API/storage directly.
class AuthRepository {
  AuthRepository(this._api, this._tokens);

  final AuthApi _api;
  final TokenStorage _tokens;

  /// Logs in, persists tokens securely, returns the user.
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final data = await _api.login(email: email, password: password);
    await _tokens.saveTokens(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
    );
    return AuthUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  /// Restores a session on app launch (auto-login). Returns the user if stored
  /// tokens are still valid (the client refreshes transparently on 401), else
  /// null.
  Future<AuthUser?> restoreSession() async {
    if (!await _tokens.hasTokens()) return null;
    try {
      final data = await _api.me();
      return AuthUser.fromJson(data);
    } catch (_) {
      await _tokens.clear();
      return null;
    }
  }

  /// Clears local tokens and best-effort blacklists the refresh token server
  /// side. Local logout always succeeds even if the network call fails.
  Future<void> logout() async {
    final refresh = await _tokens.readRefreshToken();
    if (refresh != null) {
      try {
        await _api.logout(refreshToken: refresh);
      } catch (_) {
        // Ignore — local sign-out must not depend on network availability.
      }
    }
    await _tokens.clear();
  }
}
