import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockguard_ai/localization/app_localizations.dart';
import 'package:stockguard_ai/localization/locale_provider.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  static const Map<String, String> _flags = {
    'en': '🇬🇧',
    'it': '🇮🇹',
    'es': '🇪🇸',
    'fr': '🇫🇷',
    'de': '🇩🇪',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider)?.languageCode ?? 'en';

    return PopupMenuButton<String>(
      tooltip: context.l10n.t('language'),
      initialValue: current,
      onSelected: (code) {
        ref.read(localeProvider.notifier).setLocale(Locale(code));
      },
      itemBuilder: (context) => _flags.entries
          .map(
            (e) => PopupMenuItem<String>(
              value: e.key,
              child: Row(
                children: [
                  Text(e.value, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(e.key.toUpperCase()),
                ],
              ),
            ),
          )
          .toList(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_flags[current] ?? '🌐', style: const TextStyle(fontSize: 20)),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }
}
