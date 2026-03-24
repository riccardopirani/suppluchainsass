import 'package:fabricos/config/env.dart';
import 'package:fabricos/core/theme/app_theme.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:fabricos/localization/locale_provider.dart';
import 'package:fabricos/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FabricOSApp extends ConsumerWidget {
  const FabricOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final env = ref.watch(envProvider);

    return MaterialApp.router(
      title: 'FabricOS',
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
