import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockguard_ai/localization/app_localizations.dart';
import 'package:stockguard_ai/features/app_shell/providers/workspace_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SuppliersPage extends ConsumerStatefulWidget {
  const SuppliersPage({super.key});

  @override
  ConsumerState<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends ConsumerState<SuppliersPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _leadTimeDaysController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;
  Map<String, dynamic>? _editingSupplier;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _leadTimeDaysController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _leadTimeDaysController.text = '7';
    _notesController.clear();
    _editingSupplier = null;
  }

  void _openDrawerForCreate() {
    _clearForm();
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _openDrawerForEdit(Map<String, dynamic> supplier) {
    _editingSupplier = supplier;
    _nameController.text = supplier['name'] ?? '';
    _emailController.text = supplier['contact_email'] ?? '';
    _phoneController.text = supplier['contact_phone'] ?? '';
    _leadTimeDaysController.text = (supplier['lead_time_days'] ?? 7).toString();
    _notesController.text = supplier['notes'] ?? '';
    _scaffoldKey.currentState?.openEndDrawer();
  }

  Future<void> _saveSupplier() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      final workspaceId = await ref.read(currentWorkspaceProvider.future);

      if (_editingSupplier != null) {
        // Update existing
        await supabase.from('suppliers').update({
          'name': _nameController.text.trim(),
          'contact_email': _emailController.text.trim(),
          'contact_phone': _phoneController.text.trim(),
          'lead_time_days': int.tryParse(_leadTimeDaysController.text) ?? 7,
          'notes': _notesController.text.trim(),
        }).eq('id', _editingSupplier!['id']);
      } else {
        // Create new
        await supabase.from('suppliers').insert({
          'workspace_id': workspaceId,
          'name': _nameController.text.trim(),
          'contact_email': _emailController.text.trim(),
          'contact_phone': _phoneController.text.trim(),
          'lead_time_days': int.tryParse(_leadTimeDaysController.text) ?? 7,
          'notes': _notesController.text.trim(),
          'active': true,
        });
      }

      // Refresh list
      ref.refresh(suppliersProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _editingSupplier != null ? 'Supplier updated!' : 'Supplier created!',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSupplier(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Supplier?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await Supabase.instance.client.from('suppliers').delete().eq('id', id);
      ref.refresh(suppliersProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Supplier deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final suppliersAsyncValue = ref.watch(suppliersProvider);

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: _buildSupplierDrawer(),
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
                    context.l10n.t('suppliers'),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Builder(
                    builder: (context) => FilledButton.icon(
                      onPressed: _openDrawerForCreate,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('New Supplier'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: suppliersAsyncValue.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                    child: Text('Error: $err'),
                  ),
                  data: (suppliers) {
                    if (suppliers.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_shipping_outlined,
                              size: 64,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No suppliers yet',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: suppliers.length,
                      itemBuilder: (context, i) {
                        final supplier = suppliers[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(supplier['name'] ?? 'Unknown'),
                            subtitle: Text(
                              'Lead time: ${supplier['lead_time_days'] ?? 7} days${supplier['contact_email'] != null ? ' • ${supplier['contact_email']}' : ''}',
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: const Text('Edit'),
                                  onTap: () => _openDrawerForEdit(supplier),
                                ),
                                PopupMenuItem(
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                  onTap: () => _deleteSupplier(supplier['id']),
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

  Widget _buildSupplierDrawer() {
    return Drawer(
      width: 440,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _editingSupplier != null ? 'Edit Supplier' : 'Add New Supplier',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Fill in the details below',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
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

              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Supplier Name *',
                            hintText: 'e.g., Acme Supply Co.',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.local_shipping_outlined),
                          ),
                          validator: (v) => (v?.isEmpty ?? true) ? 'Name required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'contact@supplier.com',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone',
                            hintText: '+1 (555) 123-4567',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.phone_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _leadTimeDaysController,
                          decoration: InputDecoration(
                            labelText: 'Lead Time (days)',
                            hintText: '7',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.schedule_outlined),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _notesController,
                          decoration: InputDecoration(
                            labelText: 'Notes',
                            hintText: 'Additional information...',
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

              // Footer
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
                        onPressed: _isLoading ? null : _saveSupplier,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(_editingSupplier != null ? 'Update' : 'Create'),
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
