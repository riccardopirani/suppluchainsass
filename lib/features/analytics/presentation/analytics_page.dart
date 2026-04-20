import 'package:fabricos/core/theme/intelligence_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fabricos/localization/app_localizations.dart';
import '../../../features/app_shell/providers/workspace_provider.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final purchaseOrdersAsync = ref.watch(purchaseOrdersProvider);
    final reorderAsync = ref.watch(reorderRecommendationsProvider);

    return Scaffold(
      backgroundColor: IntelligenceTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.t('analytics'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: IntelligenceTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              productsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('Error: $err'),
                data: (products) {
                  return purchaseOrdersAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Text('Error: $err'),
                    data: (purchaseOrders) {
                      return reorderAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (err, stack) => Text('Error: $err'),
                        data: (reorderRecommendations) {
                          // Calculate inventory value
                          double inventoryValue = 0;
                          for (var p in products) {
                            final quantity =
                                (p['quantity'] as num?)?.toDouble() ?? 0;
                            final unitPrice =
                                (p['unit_price'] as num?)?.toDouble() ?? 0;
                            inventoryValue += quantity * unitPrice;
                          }

                          // Calculate capital locked (pending POs)
                          double capitalLocked = 0;
                          for (var po in purchaseOrders) {
                            final status = po['status'] as String? ?? '';
                            if (status != 'delivered' &&
                                status != 'cancelled') {
                              final quantity =
                                  (po['quantity'] as num?)?.toDouble() ?? 0;
                              final unitPrice =
                                  (po['unit_price'] as num?)?.toDouble() ?? 0;
                              capitalLocked += quantity * unitPrice;
                            }
                          }

                          // Count risky SKUs (with low stock)
                          int riskySKUs = reorderRecommendations.length;

                          return Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              _StatCard(
                                title: context.l10n.t('inventory_value'),
                                value:
                                    '€${(inventoryValue / 1000).toStringAsFixed(1)}k',
                              ),
                              _StatCard(
                                title: context.l10n.t('capital_locked'),
                                value:
                                    '€${(capitalLocked / 1000).toStringAsFixed(1)}k',
                              ),
                              _StatCard(
                                title: 'Top risky SKUs',
                                value: riskySKUs.toString(),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: IntelligenceTheme.panel,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: IntelligenceTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: IntelligenceTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: IntelligenceTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
