import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stockguard_ai/localization/app_localizations.dart';
import 'package:stockguard_ai/core/theme/app_dimensions.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stockguard_ai/features/app_shell/providers/workspace_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.t('dashboard'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              _SummaryCards(l10n: l10n, ref: ref),
              const SizedBox(height: 32),
              _ReorderTable(l10n: l10n, ref: ref),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCards extends ConsumerWidget {
  const _SummaryCards({required this.l10n, required this.ref});
  final AppLocalizations l10n;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final reorderAsync = ref.watch(reorderRecommendationsProvider);

    return productsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Error: $err'),
      data: (products) {
        return reorderAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Error: $err'),
          data: (reorders) {
            // Calculate metrics
            final productsAtRisk = products
                .where((p) => (p['current_stock'] ?? 0) <= (p['reorder_point'] ?? 0))
                .length;
            final overstocked = products
                .where((p) => (p['current_stock'] ?? 0) > (p['reorder_point'] ?? 0) * 2)
                .length;
            final reorderToday = reorders
                .where((r) => (r['status'] ?? '') == 'pending')
                .length;
            final totalInventoryValue = products.fold<double>(
              0,
              (sum, p) => sum + ((p['current_stock'] ?? 0) * (p['unit_cost'] as num? ?? 0)).toDouble(),
            );

            final cards = <({String label, String value, IconData icon, Color color})>[
              (label: l10n.t('products_at_risk'), value: productsAtRisk.toString(), icon: Icons.warning_amber_rounded, color: Colors.orange),
              (label: l10n.t('overstocked'), value: overstocked.toString(), icon: Icons.inventory_2_outlined, color: Colors.blue),
              (label: l10n.t('reorder_today'), value: reorderToday.toString(), icon: Icons.reorder_rounded, color: Colors.teal),
              (label: l10n.t('inventory_value'), value: '€${(totalInventoryValue / 1000).toStringAsFixed(1)}k', icon: Icons.euro_rounded, color: Colors.green),
              (label: 'Total Products', value: products.length.toString(), icon: Icons.inventory_2_outlined, color: Colors.purple),
              (label: 'Pending Orders', value: reorders.where((r) => r['status'] == 'pending').length.toString(), icon: Icons.local_shipping_outlined, color: Colors.red),
            ];

            return LayoutBuilder(
              builder: (context, constraints) {
                final crossCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 500 ? 2 : 1);
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: List.generate(cards.length, (i) {
                    final c = cards[i];
                    return SizedBox(
                      width: (constraints.maxWidth - 16 * (crossCount - 1)) / crossCount - 8,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: c.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(c.icon, color: c.color, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.label,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      c.value,
                                      style: Theme.of(context).textTheme.headlineSmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: (50 * i).ms).slideX(begin: 0.05, end: 0, curve: Curves.easeOut),
                    );
                  }),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ReorderTable extends ConsumerWidget {
  const _ReorderTable({required this.l10n, required this.ref});
  final AppLocalizations l10n;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reorderAsync = ref.watch(reorderRecommendationsProvider);
    final productsAsync = ref.watch(productsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.t('reorder_suggestions'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () => context.push('/app/reorder'),
                  child: Text(l10n.t('view_all')),
                ),
              ],
            ),
            const SizedBox(height: 16),
            reorderAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
              data: (reorders) {
                return productsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('Error: $err'),
                  data: (products) {
                    final topReorders = reorders.take(5).toList();

                    if (topReorders.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'No reorder suggestions at the moment',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                      );
                    }

                    return Table(
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(1),
                        3: FlexColumnWidth(1),
                      },
                      children: [
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                l10n.t('sku'),
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                l10n.t('current_stock'),
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                l10n.t('recommended'),
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                l10n.t('status'),
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                            ),
                          ],
                        ),
                        ...topReorders.map((reorder) {
                          final product = products.firstWhere(
                            (p) => p['id'] == reorder['product_id'],
                            orElse: () => {'sku': 'Unknown', 'current_stock': 0},
                          );
                          final status = reorder['status'] ?? 'pending';

                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: InkWell(
                                  onTap: () => context.push('/app/products/${reorder['product_id']}'),
                                  child: Text(product['sku'] ?? 'Unknown'),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text((product['current_stock'] ?? 0).toString()),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text((reorder['recommended_quantity'] ?? 0).toString()),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Chip(
                                  label: Text(status),
                                  backgroundColor: status == 'pending'
                                      ? Colors.orange.withValues(alpha: 0.15)
                                      : Colors.green.withValues(alpha: 0.15),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
