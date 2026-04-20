import 'package:flutter/material.dart';

abstract final class IntelligenceTheme {
  IntelligenceTheme._();

  static const Color background = Color(0xFF040A14);
  static const Color panel = Color(0xFF0B1220);
  static const Color panelAlt = Color(0xFF101A2E);
  static const Color panelStrong = Color(0xFF162238);
  static const Color border = Color(0xFF24324A);
  static const Color borderStrong = Color(0xFF334863);
  static const Color textPrimary = Color(0xFFF4F8FF);
  static const Color textSecondary = Color(0xFFD7E2F2);
  static const Color textMuted = Color(0xFFA9BDD4);
  static const Color textDim = Color(0xFF7F95AF);
  static const Color accent = Color(0xFF7DD3FC);
  static const Color accentStrong = Color(0xFF38BDF8);
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color danger = Color(0xFFFB7185);

  static const LinearGradient panelGradient = LinearGradient(
    colors: [panelAlt, panel],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF08111F), Color(0xFF0B1627), Color(0xFF12314A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
