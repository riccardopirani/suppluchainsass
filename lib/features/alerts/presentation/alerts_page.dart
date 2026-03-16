import 'package:flutter/material.dart';
import 'package:stockguard_ai/localization/app_localizations.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

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
                context.l10n.t('alerts'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: 6,
                  itemBuilder: (context, i) {
                    final types = ['Stockout risk', 'Overstock', 'Slow-moving', 'Supplier delay', 'Reorder', 'Billing'];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(
                          i % 3 == 0 ? Icons.warning_amber : Icons.info_outline,
                          color: i % 3 == 0 ? Colors.orange : Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(types[i % types.length]),
                        subtitle: Text('SKU-${1000 + i} • ${i + 1}h ago'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
