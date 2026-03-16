import 'package:flutter/material.dart';
import 'package:stockguard_ai/localization/app_localizations.dart';

class PurchaseOrdersPage extends StatelessWidget {
  const PurchaseOrdersPage({super.key});

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
                context.l10n.t('purchase_orders'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: 4,
                  itemBuilder: (context, i) {
                    final statuses = ['Draft', 'Approved', 'Sent', 'Received'];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text('PO-2026-${100 + i}'),
                        subtitle: Text('Supplier ${i + 1} • ${statuses[i]}'),
                        trailing: Chip(label: Text(statuses[i])),
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
