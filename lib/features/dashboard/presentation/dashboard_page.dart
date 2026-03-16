import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stockguard_ai/localization/app_localizations.dart';
import 'package:stockguard_ai/core/theme/app_dimensions.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
              _SummaryCards(l10n: l10n),
              const SizedBox(height: 32),
              _ReorderTable(l10n: l10n),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final cards = <({String label, String value, IconData icon, Color color})>[
      (label: l10n.t('products_at_risk'), value: '12', icon: Icons.warning_amber_rounded, color: Colors.orange),
      (label: l10n.t('overstocked'), value: '5', icon: Icons.inventory_2_outlined, color: Colors.blue),
      (label: l10n.t('reorder_today'), value: '8', icon: Icons.reorder_rounded, color: Colors.teal),
      (label: l10n.t('inventory_value'), value: '€124.5k', icon: Icons.euro_rounded, color: Colors.green),
      (label: l10n.t('capital_locked'), value: '€38.2k', icon: Icons.lock_clock_rounded, color: Colors.amber),
      (label: l10n.t('supplier_risk'), value: '2', icon: Icons.local_shipping_outlined, color: Colors.red),
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
  }
}

class _ReorderTable extends StatelessWidget {
  const _ReorderTable({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
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
            Table(
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
                ...List.generate(5, (i) => TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: InkWell(
                        onTap: () => context.push('/app/products/demo-$i'),
                        child: Text('SKU-${1000 + i}'),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('45'),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('120'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Chip(
                        label: Text(i % 3 == 0 ? l10n.t('status_critical') : (i % 3 == 1 ? l10n.t('status_attention') : l10n.t('status_safe'))),
                        backgroundColor: i % 3 == 0
                            ? Colors.red.withValues(alpha: 0.15)
                            : (i % 3 == 1 ? Colors.orange.withValues(alpha: 0.15) : Colors.green.withValues(alpha: 0.15)),
                      ),
                    ),
                  ],
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
