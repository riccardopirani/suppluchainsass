import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stockguard_ai/localization/app_localizations.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.t('products'),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.upload_file, size: 18),
                    label: Text(context.l10n.t('import_csv')),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                decoration: InputDecoration(
                  hintText: context.l10n.t('search'),
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: List.generate(
                    10,
                    (i) => ListTile(
                      title: Text('Product ${i + 1}'),
                      subtitle: Text('SKU-${1000 + i} • ${20 + i * 5} units'),
                      trailing: Chip(
                        label: Text(
                          i % 3 == 0 ? context.l10n.t('status_critical') : (i % 3 == 1 ? context.l10n.t('status_attention') : context.l10n.t('status_safe')),
                        ),
                      ),
                      onTap: () => context.push('/app/products/product-$i'),
                    ),
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
