import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';

/// Global Riverpod providers (app-wide singletons and cross-page state).
///
/// State management is Riverpod (frontend.md maps server/UI state to
/// TanStack Query + Zustand; Riverpod is the Flutter equivalent for both).
/// Feature-scoped providers live in each `features/<domain>/` folder.

/// The shared, configured HTTP client. Injected into feature repositories.
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
