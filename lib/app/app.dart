import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockguard_ai/config/env.dart';
import 'package:stockguard_ai/core/theme/app_theme.dart';
import 'package:stockguard_ai/localization/app_localizations.dart';
import 'package:stockguard_ai/localization/locale_provider.dart';
import 'package:stockguard_ai/routing/app_router.dart';

class StockGuardApp extends ConsumerWidget {
  const StockGuardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final env = ref.watch(envProvider);

    return MaterialApp.router(
      title: 'StockGuard AI',
      debugShowCheckedModeBanner: env.isDevelopment,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      locale: ref.watch(localeProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: router,
    );
  }
}
