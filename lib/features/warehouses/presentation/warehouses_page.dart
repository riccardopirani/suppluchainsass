import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../features/app_shell/providers/workspace_provider.dart';

class WarehousesPage extends ConsumerStatefulWidget {
  const WarehousesPage({super.key});

  @override
  ConsumerState<WarehousesPage> createState() => _WarehousesPageState();
}

class _WarehousesPageState extends ConsumerState<WarehousesPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _capacityController = TextEditingController();
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _saveWarehouse(String? workspaceId) async {
    if (_formKey.currentState!.validate() && workspaceId != null) {
      setState(() => _isLoading = true);

      try {
        final supabase = Supabase.instance.client;
        final capacity = int.tryParse(_capacityController.text) ?? 0;

        await supabase.from('warehouses').insert({
          'workspace_id': workspaceId,
          'name': _nameController.text,
          'location': _locationController.text,
          'capacity': capacity,
          'is_default': _isDefault,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Warehouse created successfully')),
          );
          _nameController.clear();
          _locationController.clear();
          _capacityController.clear();
          setState(() => _isDefault = false);
          // Refresh the warehouses list
          ref.refresh(warehousesProvider);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteWarehouse(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Warehouse'),
        content: const Text('Are you sure? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final supabase = Supabase.instance.client;
        await supabase.from('warehouses').delete().eq('id', id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Warehouse deleted')),
          );
          // Refresh the warehouses list
          ref.refresh(warehousesProvider);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final warehousesAsync = ref.watch(warehousesProvider);
    final workspaceAsync = ref.watch(currentWorkspaceProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Warehouses',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: workspaceAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('Error: $err'),
                  data: (workspaceId) {
                    return warehousesAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Text('Error: $err'),
                      data: (warehouses) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FilledButton.icon(
                              onPressed: () => _showCreateDialog(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Warehouse'),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: warehouses.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No warehouses yet',
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: warehouses.length,
                                      itemBuilder: (context, i) {
                                        final w = warehouses[i];
                                        final isDefault = w['is_default'] as bool? ?? false;

                                        return Card(
                                          margin: const EdgeInsets.only(bottom: 12),
                                          child: ListTile(
                                            title: Text(w['name'] ?? 'Unknown'),
                                            subtitle: Text(w['location'] ?? 'No location'),
                                            trailing: PopupMenuButton(
                                              itemBuilder: (context) => [
                                                PopupMenuItem(
                                                  child: const Text('Delete'),
                                                  onTap: () => _deleteWarehouse(w['id']),
                                                ),
                                              ],
                                            ),
                                            leading: isDefault
                                                ? const Tooltip(
                                                    message: 'Default warehouse',
                                                    child: Icon(Icons.star, color: Colors.amber),
                                                  )
                                                : null,
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
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

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Warehouse'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(labelText: 'Capacity (units)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v ?? false),
                title: const Text('Set as default'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _isLoading ? null : () async {
              try {
                final workspaceId = await ref.read(currentWorkspaceProvider.future);
                if (Navigator.canPop(context)) Navigator.pop(context);
                _saveWarehouse(workspaceId);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: _isLoading ? const CircularProgressIndicator() : const Text('Create'),
          ),
        ],
      ),
    );
  }
}
