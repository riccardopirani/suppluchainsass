import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SuppliersPage extends ConsumerStatefulWidget {
  const SuppliersPage({super.key});

  @override
  ConsumerState<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends ConsumerState<SuppliersPage> {
  bool _busy = false;

  Future<void> _createSupplier(String companyId) async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final reliabilityController = TextEditingController(text: '82');
    String complianceStatus = 'compliant';
    String riskLevel = 'medium';

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('New supplier'),
            content: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Supplier name',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Contact email',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reliabilityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Reliability score (0-100)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: complianceStatus,
                    items: const [
                      DropdownMenuItem(
                        value: 'compliant',
                        child: Text('Compliant'),
                      ),
                      DropdownMenuItem(
                        value: 'under_review',
                        child: Text('Under review'),
                      ),
                      DropdownMenuItem(
                        value: 'non_compliant',
                        child: Text('Non compliant'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() => complianceStatus = value);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Compliance status',
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: riskLevel,
                    items: const [
                      DropdownMenuItem(value: 'low', child: Text('Low risk')),
                      DropdownMenuItem(
                        value: 'medium',
                        child: Text('Medium risk'),
                      ),
                      DropdownMenuItem(value: 'high', child: Text('High risk')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() => riskLevel = value);
                    },
                    decoration: const InputDecoration(labelText: 'Risk level'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Create'),
              ),
            ],
          ),
        );
      },
    );

    if (ok != true || !mounted) return;
    if (nameController.text.trim().isEmpty) return;

    setState(() => _busy = true);
    try {
      await ref
          .read(fabricosRepositoryProvider)
          .createSupplier(
            companyId: companyId,
            name: nameController.text.trim(),
            reliabilityScore:
                (double.tryParse(reliabilityController.text) ?? 75).clamp(
                  0,
                  100,
                ),
            complianceStatus: complianceStatus,
            riskLevel: riskLevel,
            contactEmail: emailController.text.trim().isEmpty
                ? null
                : emailController.text.trim(),
          );
      ref.invalidate(suppliersProvider);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteSupplier(
    String companyId,
    Map<String, dynamic> supplier,
  ) async {
    final name = supplier['name']?.toString() ?? 'this supplier';
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete supplier'),
        content: Text(
          'Remove "$name"? Linked orders keep their history but lose this supplier reference.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(fabricosRepositoryProvider).deleteSupplier(
            companyId: companyId,
            supplierId: supplier['id'].toString(),
          );
      ref.invalidate(suppliersProvider);
      ref.invalidate(ordersProvider);
      ref.invalidate(dashboardSnapshotProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Supplier removed.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete supplier: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyIdAsync = ref.watch(currentCompanyIdProvider);
    final suppliersAsync = ref.watch(suppliersProvider);
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: companyIdAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) =>
                Center(child: Text('Unable to load company context: $err')),
            data: (companyId) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Supplier Monitoring',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _busy
                          ? null
                          : () => _createSupplier(companyId),
                      icon: const Icon(Icons.add),
                      label: const Text('New supplier'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Evaluate reliability, delay behavior and compliance signals for each supplier.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: suppliersAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (err, _) =>
                            Text('Failed to load suppliers: $err'),
                        data: (suppliers) {
                          if (suppliers.isEmpty) {
                            return const Center(
                              child: Text('No suppliers yet.'),
                            );
                          }

                          return ordersAsync.when(
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (err, _) =>
                                Text('Failed to load order data: $err'),
                            data: (orders) {
                              return ListView.separated(
                                itemCount: suppliers.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final supplier = suppliers[index];
                                  final supplierId = supplier['id'];
                                  final supplierOrders = orders
                                      .where(
                                        (order) =>
                                            order['supplier_id']?.toString() ==
                                            supplierId?.toString(),
                                      )
                                      .toList();
                                  final delayed = supplierOrders.where((o) {
                                    final fromDb =
                                        (o['delay_days'] as num?)?.toInt() ?? 0;
                                    if (fromDb > 0) return true;
                                    final expected = DateTime.tryParse(
                                      o['expected_delivery_date']?.toString() ??
                                          '',
                                    );
                                    if (expected == null) return false;
                                    return o['status'] != 'completed' &&
                                        DateTime.now().isAfter(expected);
                                  }).length;

                                  final reliability =
                                      (supplier['reliability_score'] as num?)
                                          ?.toDouble() ??
                                      75;
                                  final avgDelay =
                                      (supplier['avg_delay_days'] as num?)
                                          ?.toDouble() ??
                                      (supplierOrders.isEmpty
                                          ? 0
                                          : (delayed * 1.8));
                                  final performance =
                                      (reliability - (avgDelay * 6)).clamp(
                                        0,
                                        100,
                                      );
                                  final risk =
                                      supplier['risk_level']?.toString() ??
                                      (performance > 75
                                          ? 'low'
                                          : performance > 50
                                          ? 'medium'
                                          : 'high');

                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 6,
                                    ),
                                    leading: CircleAvatar(
                                      backgroundColor: _riskColor(
                                        risk,
                                      ).withValues(alpha: 0.15),
                                      child: Icon(
                                        Icons.local_shipping_outlined,
                                        color: _riskColor(risk),
                                      ),
                                    ),
                                    title: Text(
                                      supplier['name']?.toString() ?? '-',
                                    ),
                                    subtitle: Text(
                                      'Perf: ${performance.toStringAsFixed(0)}/100 · Delayed orders: $delayed · Compliance: ${supplier['compliance_status'] ?? 'n/a'}',
                                    ),
                                    trailing: Wrap(
                                      spacing: 8,
                                      children: [
                                        Chip(
                                          label: Text(risk.toUpperCase()),
                                          backgroundColor: _riskColor(
                                            risk,
                                          ).withValues(alpha: 0.15),
                                        ),
                                        if (supplier['contact_email'] != null)
                                          Tooltip(
                                            message: supplier['contact_email']
                                                .toString(),
                                            child: const Icon(
                                              Icons.mail_outline,
                                              size: 18,
                                            ),
                                          ),
                                        IconButton(
                                          tooltip: 'Delete supplier',
                                          onPressed: _busy
                                              ? null
                                              : () => _deleteSupplier(
                                                    companyId,
                                                    supplier,
                                                  ),
                                          icon: Icon(
                                            Icons.delete_outline,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.error,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
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
      ),
    );
  }

  static Color _riskColor(String risk) {
    switch (risk) {
      case 'high':
        return const Color(0xFFDC2626);
      case 'medium':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF15803D);
    }
  }
}
