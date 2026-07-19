// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design-system tokens extracted from the stitch_bento_material_analytics
/// design files. Primary palette = Indigo (#3525cd), Material 3 surface system.
class AppTheme {
  AppTheme._();

  // ─── Seed / primary ──────────────────────────────────────────────────────
  static const Color primary            = Color(0xFF3525CD);
  static const Color onPrimary          = Color(0xFFFFFFFF);
  static const Color primaryContainer   = Color(0xFF4F46E5);
  static const Color onPrimaryContainer = Color(0xFFDAD7FF);
  static const Color primaryFixed       = Color(0xFFE2DFFF);
  static const Color primaryFixedDim    = Color(0xFFC3C0FF);

  // ─── Secondary ───────────────────────────────────────────────────────────
  static const Color secondary           = Color(0xFF505F76);
  static const Color secondaryContainer  = Color(0xFFD0E1FB);
  static const Color secondaryFixedDim   = Color(0xFFB7C8E1);

  // ─── Tertiary ────────────────────────────────────────────────────────────
  static const Color tertiary            = Color(0xFF004D70);
  static const Color tertiaryContainer   = Color(0xFF006693);
  static const Color onTertiary          = Color(0xFFFFFFFF);
  static const Color tertiaryFixedDim    = Color(0xFF89CEFF);

  // ─── Surface system ──────────────────────────────────────────────────────
  static const Color surface                   = Color(0xFFF7F9FB);
  static const Color surfaceBright             = Color(0xFFF7F9FB);
  static const Color surfaceContainerLowest    = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow       = Color(0xFFF2F4F6);
  static const Color surfaceContainer          = Color(0xFFECEEF0);
  static const Color surfaceContainerHigh      = Color(0xFFE6E8EA);
  static const Color surfaceContainerHighest   = Color(0xFFE0E3E5);
  static const Color surfaceDim                = Color(0xFFD8DADC);
  static const Color surfaceVariant            = Color(0xFFE0E3E5);

  // ─── On-surface ──────────────────────────────────────────────────────────
  static const Color onSurface        = Color(0xFF191C1E);
  static const Color onSurfaceVariant = Color(0xFF464555);
  static const Color onBackground     = Color(0xFF191C1E);

  // ─── Outline ─────────────────────────────────────────────────────────────
  static const Color outline        = Color(0xFF777587);
  static const Color outlineVariant = Color(0xFFC7C4D8);

  // ─── Error ───────────────────────────────────────────────────────────────
  static const Color error            = Color(0xFFBA1A1A);
  static const Color onError          = Color(0xFFFFFFFF);
  static const Color errorContainer   = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // ─── Semantic status colors ───────────────────────────────────────────────
  static const Color successGreen  = Color(0xFF1B7A4C); // Present
  static const Color warningAmber  = Color(0xFFB45309); // Late / Suspended
  static const Color infoBlue      = Color(0xFF1565C0); // Leave

  // ─── Typography ──────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme() {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 48, fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 48, height: 60 / 48, color: onSurface,
      ),
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 32, fontWeight: FontWeight.w700,
        letterSpacing: -0.01 * 32, height: 40 / 32, color: onSurface,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 24, fontWeight: FontWeight.w600,
        height: 32 / 24, color: onSurface,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 20, fontWeight: FontWeight.w600,
        height: 28 / 20, color: onSurface,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w600,
        height: 24 / 16, color: onSurface,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w600,
        letterSpacing: 0.05 * 14, height: 20 / 14, color: onSurface,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w400,
        height: 24 / 16, color: onSurface,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400,
        height: 20 / 14, color: onSurface,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w600,
        letterSpacing: 0.05 * 12, height: 16 / 12, color: onSurface,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w500,
        height: 14 / 11, color: onSurface,
      ),
    );
  }

  static ThemeData get lightTheme {
    final textTheme = _buildTextTheme();
    final colorScheme = const ColorScheme.light(
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      secondaryContainer: secondaryContainer,
      tertiary: tertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiary: onTertiary,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      surfaceContainerLowest: surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainerHighest: surfaceContainerHighest,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surfaceBright,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceContainerLowest,
        foregroundColor: onSurface,
        elevation: 0,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.headlineSmall,
      ),
      cardTheme: CardThemeData(
        color: surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: surfaceContainer),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: textTheme.titleMedium,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: outlineVariant),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: textTheme.titleMedium,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: onSurfaceVariant),
        hintStyle: textTheme.bodyMedium?.copyWith(color: outlineVariant),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceContainerLowest,
        indicatorColor: primaryContainer,
        labelTextStyle: WidgetStateProperty.all(textTheme.labelSmall),
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
      ),
      dividerTheme: const DividerThemeData(
        color: surfaceContainer,
        thickness: 1,
        space: 0,
      ),
    );
  }
}
