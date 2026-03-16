import 'package:flutter/material.dart';
import 'package:stockguard_ai/localization/app_localizations.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('How does reorder suggestion work?', 'We use your sales history, lead times, and safety stock to calculate when and how much to reorder.'),
      ('Can I import from Excel?', 'Yes. CSV upload is supported. More integrations are coming.'),
      ('Is there a free trial?', 'Yes. Start with a free trial and upgrade when you need more SKUs or users.'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              Text(
                context.l10n.t('nav_faq'),
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 32),
              ...items.map(
                (e) => ExpansionTile(
                  title: Text(e.$1),
                  children: [Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(e.$2),
                  )],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
