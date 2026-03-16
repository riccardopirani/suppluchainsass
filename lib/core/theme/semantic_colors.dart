import 'package:flutter/material.dart';

class SemanticColors {
  const SemanticColors._();

  static Color danger(BuildContext context) =>
      Theme.of(context).colorScheme.error;
  static Color success(BuildContext context) =>
      _resolve(context, light: const Color(0xFF059669), dark: const Color(0xFF34D399));
  static Color warning(BuildContext context) =>
      _resolve(context, light: const Color(0xFFD97706), dark: const Color(0xFFFBBF24));
  static Color info(BuildContext context) =>
      _resolve(context, light: const Color(0xFF0284C7), dark: const Color(0xFF38BDF8));

  static Color _resolve(BuildContext context, {required Color light, required Color dark}) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }
}
