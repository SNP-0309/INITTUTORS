import 'package:flutter/material.dart';

/// Design tokens — the single source of colour, radius, and spacing values.
///
/// Mirrors the token approach in frontend.md §15 (no hardcoded hex in widgets)
/// and the status colour/symbol semantics in §7.4. Dark mode is intentionally
/// not implemented in this version, but tokens are structured to allow it later.
class AppTokens {
  const AppTokens._();

  // --- Brand / semantic colours ---
  static const Color primary = Color(0xFF2563EB);
  static const Color success = Color(0xFF16A34A); // Present / Active
  static const Color danger = Color(0xFFDC2626); // Absent
  static const Color warning = Color(0xFFD97706); // Late / Suspended
  static const Color info = Color(0xFF0284C7); // Leave
  static const Color neutral = Color(0xFF6B7280); // Left / Inactive

  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);

  // --- Radius (frontend.md §15) ---
  static const double radiusSm = 4;
  static const double radiusMd = 8;
  static const double radiusLg = 12;

  // --- Spacing (4px base scale) ---
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;

  /// Minimum touch target — 44x44 per frontend.md §13.2 / WCAG 2.5.5.
  static const double minTouchTarget = 44;
}
