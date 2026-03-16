import 'package:flutter/material.dart';
import 'package:stockguard_ai/localization/app_localizations.dart';

class ForecastingPage extends StatelessWidget {
  const ForecastingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.t('forecasting'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    height: 200,
                    child: Center(
                      child: Icon(
                        Icons.trending_up_rounded,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Demand forecast (next 30/60/90 days). Chart placeholder.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
