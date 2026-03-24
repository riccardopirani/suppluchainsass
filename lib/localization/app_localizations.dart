import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_localizations_en.dart';

export 'app_localizations_en.dart';

class AppLocalizations {
  final Locale locale;
  final Map<String, String> _localizedStrings = {};

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('it'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('ru'),
    Locale('zh'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static List<LocalizationsDelegate<dynamic>> get localizationsDelegates => [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  Future<void> _mergeJsonAsset(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final Map<String, dynamic> map = jsonDecode(raw) as Map<String, dynamic>;
    for (final e in map.entries) {
      _localizedStrings[e.key] = e.value?.toString() ?? '';
    }
  }

  Future<bool> load() async {
    final langCode = locale.languageCode;
    try {
      await _mergeJsonAsset('assets/translations/$langCode.json');
    } catch (_) {
      for (final e in appLocalizationsEn.entries) {
        _localizedStrings[e.key] ??= e.value;
      }
    }
    // Public marketing site (home, pricing, contact, …) — overlay per locale
    try {
      await _mergeJsonAsset('assets/translations/pub_$langCode.json');
    } catch (_) {
      try {
        await _mergeJsonAsset('assets/translations/pub_en.json');
      } catch (_) {
        // pub overlay optional
      }
    }
    return true;
  }

  String translate(String key) => _localizedStrings[key] ?? key;
  String t(String key) => translate(key);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
    (l) => l.languageCode == locale.languageCode,
  );

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Extension for convenient access
extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
  String tr(String key) => l10n.translate(key);
}
