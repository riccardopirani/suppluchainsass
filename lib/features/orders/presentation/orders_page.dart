import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  bool _busy = false;

  Future<void> _createOrder(String companyId) async {
    final suppliers = await ref.read(suppliersProvider.future);
    if (!mounted) return;

    if (suppliers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one supplier before creating an order.'),
        ),
      );
      return;
    }

    final orderController = TextEditingController(
      text: 'ORD-${DateTime.now().millisecondsSinceEpoch % 100000}',
    );
    final amountController = TextEditingController(text: '15000');
    DateTime expectedDelivery = DateTime.now().add(const Duration(days: 12));
    String status = 'pending';
    String selectedSupplier = suppliers.first['id'].toString();

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('New order'),
              content: SizedBox(
                width: 460,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: orderController,
                      decoration: const InputDecoration(
                        labelText: 'Order number',
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: selectedSupplier,
                      items: suppliers
                          .map(
                            (s) => DropdownMenuItem<String>(
                              value: s['id'].toString(),
                              child: Text(s['name']?.toString() ?? 'Supplier'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() => selectedSupplier = value);
                      },
                      decoration: const InputDecoration(labelText: 'Supplier'),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: status,
                      items: const [
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: 'in_progress',
                          child: Text('In progress'),
                        ),
                        DropdownMenuItem(
                          value: 'completed',
                          child: Text('Completed'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() => status = value);
                      },
                      decoration: const InputDecoration(labelText: 'Status'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Amount (€)',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Expected: ${_fmt(expectedDelivery)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              firstDate: DateTime.now().subtract(
                                const Duration(days: 365),
                              ),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365 * 3),
                              ),
                              initialDate: expectedDelivery,
                            );
                            if (picked != null) {
                              setDialogState(() => expectedDelivery = picked);
                            }
                          },
                          child: const Text('Choose date'),
                        ),
                      ],
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
            );
          },
        );
      },
    );

    if (ok != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await ref
          .read(fabricosRepositoryProvider)
          .createOrder(
            companyId: companyId,
            supplierId: selectedSupplier,
            orderNumber: orderController.text.trim(),
            status: status,
            expectedDelivery: expectedDelivery,
            amount: double.tryParse(amountController.text) ?? 0,
          );
      ref.invalidate(ordersProvider);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _runRiskScan(String companyId) async {
    setState(() => _busy = true);
    try {
      final created = await ref
          .read(fabricosRepositoryProvider)
          .analyzeOrderRisks(companyId: companyId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI risk scan completed. New alerts: $created'),
          ),
        );
      }
      ref.invalidate(ordersProvider);
      ref.invalidate(alertsProvider);
      ref.invalidate(suppliersProvider);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _updateStatus(String orderId, String newStatus) async {
    setState(() => _busy = true);
    try {
      await ref
          .read(fabricosRepositoryProvider)
          .updateOrderStatus(orderId: orderId, status: newStatus);
      ref.invalidate(ordersProvider);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyIdAsync = ref.watch(currentCompanyIdProvider);
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
                        'Orders & Supply Chain',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : () => _runRiskScan(companyId),
                      icon: const Icon(Icons.auto_fix_high_outlined),
                      label: const Text('Run AI risk scan'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _busy ? null : () => _createOrder(companyId),
                      icon: const Icon(Icons.add),
                      label: const Text('New order'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Track execution status, expected delivery and delay risks for each supplier order.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ordersAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (err, _) => Text('Failed to load orders: $err'),
                        data: (orders) {
                          if (orders.isEmpty) {
                            return const Center(
                              child: Text('No orders available yet.'),
                            );
                          }

                          return SingleChildScrollView(
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Order')),
                                DataColumn(label: Text('Supplier')),
                                DataColumn(label: Text('Status')),
                                DataColumn(label: Text('Expected delivery')),
                                DataColumn(label: Text('Delay')),
                                DataColumn(label: Text('Amount')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: orders.map((order) {
                                final supplier =
                                    order['suppliers'] as Map<String, dynamic>?;
                                final status =
                                    order['status']?.toString() ?? 'pending';
                                final expected = DateTime.tryParse(
                                  order['expected_delivery_date']?.toString() ??
                                      '',
                                );
                                final delayDays = _calcDelay(
                                  expected,
                                  status,
                                  order['delay_days'],
                                );

                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        order['order_number']?.toString() ??
                                            '-',
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        supplier?['name']?.toString() ?? '-',
                                      ),
                                    ),
                                    DataCell(_statusChip(status)),
                                    DataCell(
                                      Text(
                                        expected != null ? _fmt(expected) : '-',
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        delayDays > 0 ? '$delayDays d' : '-',
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '€${((order['amount'] as num?)?.toDouble() ?? 0).toStringAsFixed(0)}',
                                      ),
                                    ),
                                    DataCell(
                                      PopupMenuButton<String>(
                                        onSelected: (value) => _updateStatus(
                                          order['id'].toString(),
                                          value,
                                        ),
                                        itemBuilder: (_) => const [
                                          PopupMenuItem(
                                            value: 'pending',
                                            child: Text('Set pending'),
                                          ),
                                          PopupMenuItem(
                                            value: 'in_progress',
                                            child: Text('Set in progress'),
                                          ),
                                          PopupMenuItem(
                                            value: 'completed',
                                            child: Text('Set completed'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
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

  static int _calcDelay(DateTime? expected, String status, dynamic delayValue) {
    if (status == 'completed') return 0;
    final fromDb = (delayValue as num?)?.toInt() ?? 0;
    if (fromDb > 0) return fromDb;
    if (expected == null) return 0;
    final diff = DateTime.now().difference(expected).inDays;
    return diff > 0 ? diff : 0;
  }

  static Chip _statusChip(String status) {
    final label = switch (status) {
      'in_progress' => 'IN PROGRESS',
      'completed' => 'COMPLETED',
      _ => 'PENDING',
    };

    final color = switch (status) {
      'in_progress' => const Color(0xFF0E7490),
      'completed' => const Color(0xFF15803D),
      _ => const Color(0xFFD97706),
    };

    return Chip(
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.15),
    );
  }

  static String _fmt(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
