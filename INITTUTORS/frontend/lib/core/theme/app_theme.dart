import 'package:flutter/material.dart';

import 'app_tokens.dart';

/// Builds the app's [ThemeData] from [AppTokens].
///
/// Theme configuration only — no widgets/screens. Buttons default to the
/// minimum 44px touch target required by the mobile-first spec (frontend.md
/// §13.2).
class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppTokens.primary,
      primary: AppTokens.primary,
      error: AppTokens.danger,
      surface: AppTokens.surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppTokens.background,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(
            AppTokens.minTouchTarget,
            AppTokens.minTouchTarget,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          ),
        ),
      ),
    );
  }
}
