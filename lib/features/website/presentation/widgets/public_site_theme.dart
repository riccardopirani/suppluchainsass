import 'package:flutter/material.dart';

class PublicSiteTheme {
  PublicSiteTheme._();

  static const background = Color(0xFFFFFFFF);
  static const foreground = Color(0xFF0F172A);
  static const border = Color(0xFFE2E8F0);
  static const primary = Color(0xFF2563EB);
  static const secondary = Color(0xFFF1F5F9);
  static const muted = Color(0xFFF8FAFC);
  static const mutedForeground = Color(0xFF64748B);
  static const accent = Color(0xFF38BDF8);

  static ThemeData get theme {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: foreground,
      error: Color(0xFFB91C1C),
      onError: Colors.white,
      surface: background,
      onSurface: foreground,
    );

    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      dividerColor: border,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: background,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: border),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          side: const BorderSide(color: border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
