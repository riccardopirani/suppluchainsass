import 'package:flutter/material.dart';
import 'package:stockguard_ai/localization/app_localizations.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.productId});

  final String productId;

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
                '${context.l10n.t('product_detail')} — $productId',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Row(label: context.l10n.t('sku'), value: 'SKU-$productId'),
                      _Row(label: context.l10n.t('current_stock'), value: '85'),
                      _Row(label: context.l10n.t('reorder_point'), value: '30'),
                      _Row(label: context.l10n.t('lead_time_days'), value: '14'),
                      _Row(label: context.l10n.t('unit_cost'), value: '€12.50'),
                      _Row(label: context.l10n.t('selling_price'), value: '€24.00'),
                      _Row(label: context.l10n.t('stock_coverage_days'), value: '12 days'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}
