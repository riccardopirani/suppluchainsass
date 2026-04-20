import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VendorPortalPage extends ConsumerStatefulWidget {
  const VendorPortalPage({super.key});

  @override
  ConsumerState<VendorPortalPage> createState() => _VendorPortalPageState();
}

class _VendorPortalPageState extends ConsumerState<VendorPortalPage> {
  final _qtyController = TextEditingController(text: '100');
  final _notesController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _qtyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _confirmOrder() async {
    final companyId = await ref.read(currentCompanyIdProvider.future);
    final suppliers = ref.read(suppliersProvider).valueOrNull ?? const [];
    final orders = ref.read(ordersProvider).valueOrNull ?? const [];
    if (suppliers.isEmpty || orders.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Servono almeno un supplier e un ordine')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(fabricosRepositoryProvider).createVendorConfirmation(
            companyId: companyId,
            supplierId: suppliers.first['id'].toString(),
            orderId: orders.first['id'].toString(),
            confirmedQuantity: double.tryParse(_qtyController.text.trim()) ?? 0,
            notes: _notesController.text.trim(),
          );
      ref.invalidate(vendorOrderConfirmationsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conferma fornitore inviata')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final confirmations = ref.watch(vendorOrderConfirmationsProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Vendor Portal',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _qtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Confirmed quantity',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes / delivery update',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _saving ? null : _confirmOrder,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Conferma ordine'),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Card(
                  child: confirmations.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Errore: $e')),
                    data: (rows) => ListView.separated(
                      itemCount: rows.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final row = rows[index];
                        return ListTile(
                          leading: const Icon(Icons.local_shipping_outlined),
                          title: Text(
                            'Status: ${row['status']} · qty ${row['confirmed_quantity']}',
                          ),
                          subtitle: Text(row['notes']?.toString() ?? '-'),
                        );
                      },
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
