import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockguard_ai/localization/app_localizations.dart';
import 'package:stockguard_ai/features/app_shell/providers/workspace_provider.dart';

class ReorderSuggestionsPage extends ConsumerWidget {
  const ReorderSuggestionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reorderAsyncValue = ref.watch(reorderRecommendationsProvider);

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
                child: reorderAsyncValue.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                    child: Text('Error: $err'),
                  ),
                  data: (reorders) {
                    if (reorders.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.reorder_rounded,
                              size: 64,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No reorder suggestions yet',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: reorders.length,
                      itemBuilder: (context, i) {
                        final reorder = reorders[i];
                        final status = (reorder['status'] ?? 'pending').toString();
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text('Product ${reorder['product_id'] ?? 'Unknown'}'),
                            subtitle: Text(
                              'Recommend: ${reorder['recommended_quantity'] ?? 0} units',
                            ),
                            trailing: Chip(
                              label: Text(status),
                              backgroundColor: status == 'pending'
                                  ? Colors.orange.withValues(alpha: 0.2)
                                  : Colors.green.withValues(alpha: 0.2),
                            ),
                          ),
                        );
                      },
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
