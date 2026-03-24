import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:fabricos/features/app_shell/providers/workspace_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PurchaseOrdersPage extends ConsumerStatefulWidget {
  const PurchaseOrdersPage({super.key});

  @override
  ConsumerState<PurchaseOrdersPage> createState() => _PurchaseOrdersPageState();
}

class _PurchaseOrdersPageState extends ConsumerState<PurchaseOrdersPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _poNumberController = TextEditingController();
  final _supplierIdController = TextEditingController();
  final _expectedDeliveryController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedStatus = 'draft';
  bool _isLoading = false;
  Map<String, dynamic>? _editingPO;
  List<Map<String, dynamic>> _suppliers = [];

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    try {
      final workspaceId = await ref.read(currentWorkspaceProvider.future);
      final suppliers = await Supabase.instance.client
          .from('suppliers')
          .select()
          .eq('workspace_id', workspaceId);
      setState(() => _suppliers = List<Map<String, dynamic>>.from(suppliers));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading suppliers: $e')));
      }
    }
  }

  @override
  void dispose() {
    _poNumberController.dispose();
    _supplierIdController.dispose();
    _expectedDeliveryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _poNumberController.clear();
    _supplierIdController.clear();
    _expectedDeliveryController.clear();
    _notesController.clear();
    _selectedStatus = 'draft';
    _editingPO = null;
  }

  void _openDrawerForCreate() {
    _clearForm();
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _openDrawerForEdit(Map<String, dynamic> po) {
    _editingPO = po;
    _poNumberController.text = po['po_number'] ?? '';
    _supplierIdController.text = po['supplier_id'] ?? '';
    _expectedDeliveryController.text = po['expected_delivery_date'] ?? '';
    _notesController.text = po['notes'] ?? '';
    _selectedStatus = po['status'] ?? 'draft';
    _scaffoldKey.currentState?.openEndDrawer();
  }

  Future<void> _savePO() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      final workspaceId = await ref.read(currentWorkspaceProvider.future);

      if (_editingPO != null) {
        await supabase
            .from('purchase_orders')
            .update({
              'po_number': _poNumberController.text.trim(),
              'supplier_id': _supplierIdController.text.trim(),
              'expected_delivery_date':
                  _expectedDeliveryController.text.isNotEmpty
                  ? _expectedDeliveryController.text.trim()
                  : null,
              'notes': _notesController.text.trim(),
              'status': _selectedStatus,
            })
            .eq('id', _editingPO!['id']);
      } else {
        await supabase.from('purchase_orders').insert({
          'workspace_id': workspaceId,
          'po_number': _poNumberController.text.trim(),
          'supplier_id': _supplierIdController.text.trim(),
          'expected_delivery_date': _expectedDeliveryController.text.isNotEmpty
              ? _expectedDeliveryController.text.trim()
              : null,
          'notes': _notesController.text.trim(),
          'status': _selectedStatus,
        });
      }

      ref.refresh(purchaseOrdersProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _editingPO != null
                  ? 'Purchase order updated!'
                  : 'Purchase order created!',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePO(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Purchase Order?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await Supabase.instance.client
          .from('purchase_orders')
          .delete()
          .eq('id', id);
      ref.refresh(purchaseOrdersProvider);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Purchase order deleted')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  String _getSupplierName(String supplierId) {
    try {
      return _suppliers.firstWhere((s) => s['id'] == supplierId)['name'] ??
          'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'draft':
        return Colors.grey;
      case 'approved':
        return Colors.blue;
      case 'sent':
        return Colors.orange;
      case 'received':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final purchaseOrdersAsyncValue = ref.watch(purchaseOrdersProvider);

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: _buildPODrawer(),
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
                    context.l10n.t('purchase_orders'),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Builder(
                    builder: (context) => FilledButton.icon(
                      onPressed: _openDrawerForCreate,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('New PO'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: purchaseOrdersAsyncValue.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                  data: (purchaseOrders) {
                    if (purchaseOrders.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 64,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No purchase orders yet',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: purchaseOrders.length,
                      itemBuilder: (context, i) {
                        final po = purchaseOrders[i];
                        final status = po['status'] ?? 'draft';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(po['po_number'] ?? 'PO-Unknown'),
                            subtitle: Text(
                              '${_getSupplierName(po['supplier_id'] ?? '')} • ${po['expected_delivery_date'] ?? 'No date'}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Chip(
                                  label: Text(status),
                                  backgroundColor: _getStatusColor(
                                    status,
                                  ).withValues(alpha: 0.2),
                                  labelStyle: TextStyle(
                                    color: _getStatusColor(status),
                                  ),
                                ),
                                PopupMenuButton(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: const Text('Edit'),
                                      onTap: () => _openDrawerForEdit(po),
                                    ),
                                    PopupMenuItem(
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      onTap: () => _deletePO(po['id']),
                                    ),
                                  ],
                                ),
                              ],
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

  Widget _buildPODrawer() {
    return Drawer(
      width: 440,
      child: Container(
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _editingPO != null
                              ? 'Edit Purchase Order'
                              : 'New Purchase Order',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Fill in the details below',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _poNumberController,
                          decoration: InputDecoration(
                            labelText: 'PO Number *',
                            hintText: 'e.g., PO-2026-001',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(
                              Icons.shopping_cart_outlined,
                            ),
                          ),
                          validator: (v) => (v?.isEmpty ?? true)
                              ? 'PO Number required'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _supplierIdController.text.isNotEmpty
                              ? _supplierIdController.text
                              : null,
                          decoration: InputDecoration(
                            labelText: 'Supplier *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(
                              Icons.local_shipping_outlined,
                            ),
                          ),
                          items: _suppliers
                              .map(
                                (s) => DropdownMenuItem<String>(
                                  value: (s['id'] as String?) ?? '',
                                  child: Text(s['name'] ?? 'Unknown'),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              _supplierIdController.text = value;
                            }
                          },
                          validator: (v) =>
                              (v?.isEmpty ?? true) ? 'Supplier required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _expectedDeliveryController,
                          decoration: InputDecoration(
                            labelText: 'Expected Delivery Date',
                            hintText: 'YYYY-MM-DD',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(
                              Icons.calendar_today_outlined,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          decoration: InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.info_outlined),
                          ),
                          items:
                              [
                                    'draft',
                                    'approved',
                                    'sent',
                                    'received',
                                    'cancelled',
                                  ]
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s.toUpperCase()),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() => _selectedStatus = value ?? 'draft');
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _notesController,
                          decoration: InputDecoration(
                            labelText: 'Notes',
                            hintText: 'Additional details...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.notes_outlined),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),

              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _clearForm,
                        child: const Text('Clear'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _isLoading ? null : _savePO,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(_editingPO != null ? 'Update' : 'Create'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
