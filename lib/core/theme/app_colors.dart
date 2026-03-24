import 'package:flutter/material.dart';

abstract class AppColorsLight {
  static const Color primary = Color(0xFF0F766E);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF0D9488);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color onSurface = Color(0xFF0F172A);
  static const Color onSurfaceVariant = Color(0xFF64748B);
  static const Color error = Color(0xFFDC2626);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF059669);
  static const Color warning = Color(0xFFD97706);
  static const Color info = Color(0xFF0284C7);
  static const Color outline = Color(0xFFE2E8F0);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F766E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

abstract class AppColorsDark {
  static const Color primary = Color(0xFF2DD4BF);
  static const Color onPrimary = Color(0xFF0F172A);
  static const Color secondary = Color(0xFF14B8A6);
  static const Color onSecondary = Color(0xFF0F172A);
  static const Color background = Color(0xFF0F172A);
  static const Color surface = Color(0xFF1E293B);
  static const Color surfaceVariant = Color(0xFF334155);
  static const Color onSurface = Color(0xFFF8FAFC);
  static const Color onSurfaceVariant = Color(0xFF94A3B8);
  static const Color error = Color(0xFFEF4444);
  static const Color onError = Color(0xFF0F172A);
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color info = Color(0xFF38BDF8);
  static const Color outline = Color(0xFF475569);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2DD4BF), Color(0xFF14B8A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF134E4A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
