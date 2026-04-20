import 'package:fabricos/core/theme/intelligence_theme.dart';
import 'package:flutter/material.dart';
import 'package:fabricos/localization/app_localizations.dart';

class ForecastingPage extends StatelessWidget {
  const ForecastingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IntelligenceTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.t('forecasting'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: IntelligenceTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                color: IntelligenceTheme.panel,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: IntelligenceTheme.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    height: 200,
                    child: Center(
                      child: Icon(
                        Icons.trending_up_rounded,
                        size: 64,
                        color: IntelligenceTheme.accent,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Demand forecast (next 30/60/90 days). Chart placeholder.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: IntelligenceTheme.textSecondary,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
