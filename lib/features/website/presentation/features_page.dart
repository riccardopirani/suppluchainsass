import 'package:flutter/material.dart';
import 'package:stockguard_ai/localization/app_localizations.dart';

class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.t('nav_features'),
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 24),
              Text(
                'Forecasting, reorder intelligence, supplier visibility, alerts, and analytics—all in one place.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
