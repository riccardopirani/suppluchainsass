import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Collapsed = icon-only rail (Stripe / Linear style).
final sidebarCollapsedProvider = StateProvider<bool>((ref) => false);

/// Workspace theme follows this; persisted UX can be added later.
final appThemeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
