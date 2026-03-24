import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColorsLight.primary,
        onPrimary: AppColorsLight.onPrimary,
        secondary: AppColorsLight.secondary,
        onSecondary: AppColorsLight.onSecondary,
        surface: AppColorsLight.surface,
        onSurface: AppColorsLight.onSurface,
        surfaceContainerHighest: AppColorsLight.surfaceVariant,
        error: AppColorsLight.error,
        onError: AppColorsLight.onError,
        outline: AppColorsLight.outline,
      ),
      scaffoldBackgroundColor: AppColorsLight.background,
      textTheme: _textTheme(AppColorsLight.onSurface),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: AppColorsLight.surface,
        foregroundColor: AppColorsLight.onSurface,
        titleTextStyle: GoogleFonts.ibmPlexSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColorsLight.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        color: AppColorsLight.surface,
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsLight.surfaceVariant.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide(
            color: AppColorsLight.outline.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColorsLight.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
          vertical: AppDimensions.spacingSm,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingLg,
            vertical: AppDimensions.spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingLg,
            vertical: AppDimensions.spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColorsLight.outline.withValues(alpha: 0.3),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColorsDark.primary,
        onPrimary: AppColorsDark.onPrimary,
        secondary: AppColorsDark.secondary,
        onSecondary: AppColorsDark.onSecondary,
        surface: AppColorsDark.surface,
        onSurface: AppColorsDark.onSurface,
        surfaceContainerHighest: AppColorsDark.surfaceVariant,
        error: AppColorsDark.error,
        onError: AppColorsDark.onError,
        outline: AppColorsDark.outline,
      ),
      scaffoldBackgroundColor: AppColorsDark.background,
      textTheme: _textTheme(AppColorsDark.onSurface),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: AppColorsDark.surface,
        foregroundColor: AppColorsDark.onSurface,
        titleTextStyle: GoogleFonts.ibmPlexSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColorsDark.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        color: AppColorsDark.surface,
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsDark.surfaceVariant.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide(
            color: AppColorsDark.outline.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColorsDark.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
          vertical: AppDimensions.spacingSm,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingLg,
            vertical: AppDimensions.spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingLg,
            vertical: AppDimensions.spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColorsDark.outline.withValues(alpha: 0.3),
      ),
    );
  }

  static TextTheme _textTheme(Color onSurface) {
    return TextTheme(
      displayLarge: GoogleFonts.ibmPlexSans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      displayMedium: GoogleFonts.ibmPlexSans(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      displaySmall: GoogleFonts.ibmPlexSans(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      headlineMedium: GoogleFonts.ibmPlexSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleLarge: GoogleFonts.ibmPlexSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleMedium: GoogleFonts.ibmPlexSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: onSurface,
      ),
      bodyLarge: GoogleFonts.ibmPlexSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      bodyMedium: GoogleFonts.ibmPlexSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      bodySmall: GoogleFonts.ibmPlexSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      labelLarge: GoogleFonts.ibmPlexSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: onSurface,
      ),
    );
  }
}
