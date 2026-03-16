import 'package:flutter/material.dart';
import 'package:stockguard_ai/localization/app_localizations.dart';

class ReorderSuggestionsPage extends StatelessWidget {
  const ReorderSuggestionsPage({super.key});

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
                context.l10n.t('reorder_suggestions'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: 8,
                  itemBuilder: (context, i) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text('SKU-${1000 + i}'),
                        subtitle: Text(
                          'Recommended: ${50 + i * 10} units • Order by: in ${3 + i} days',
                        ),
                        trailing: Chip(
                          label: Text(
                            i % 2 == 0 ? 'Critical' : 'Attention',
                          ),
                        ),
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
