import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stockguard_ai/localization/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _skuController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _unitCostController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _currentStockController = TextEditingController();
  final _reorderPointController = TextEditingController();
  final _safetyStockController = TextEditingController();
  final _leadTimeDaysController = TextEditingController();

  bool _isLoading = false;
  List<Map<String, dynamic>> _products = [];
  bool _isLoadingProducts = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void dispose() {
    _skuController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _unitCostController.dispose();
    _sellingPriceController.dispose();
    _currentStockController.dispose();
    _reorderPointController.dispose();
    _safetyStockController.dispose();
    _leadTimeDaysController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoadingProducts = true);
    try {
      final supabase = Supabase.instance.client;
      
      // Get current user's workspace
      final workspaceResult = await supabase
          .from('workspace_members')
          .select('workspace_id')
          .eq('user_id', supabase.auth.currentUser!.id)
          .limit(1)
          .single();
      
      final workspaceId = workspaceResult['workspace_id'];

      final response = await supabase
          .from('products')
          .select()
          .eq('workspace_id', workspaceId)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _products = List<Map<String, dynamic>>.from(response);
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingProducts = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading products: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _createProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      
      // Get current user's workspace
      final workspaceResult = await supabase
          .from('workspace_members')
          .select('workspace_id')
          .eq('user_id', supabase.auth.currentUser!.id)
          .limit(1)
          .single();
      
      final workspaceId = workspaceResult['workspace_id'];

      await supabase.from('products').insert({
        'workspace_id': workspaceId,
        'sku': _skuController.text.trim(),
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _categoryController.text.trim(),
        'unit_cost': double.tryParse(_unitCostController.text) ?? 0,
        'selling_price': double.tryParse(_sellingPriceController.text) ?? 0,
        'current_stock': int.tryParse(_currentStockController.text) ?? 0,
        'reorder_point': int.tryParse(_reorderPointController.text) ?? 0,
        'safety_stock': int.tryParse(_safetyStockController.text) ?? 0,
        'lead_time_days': int.tryParse(_leadTimeDaysController.text) ?? 7,
        'active': true,
      });

      // Clear form
      _skuController.clear();
      _nameController.clear();
      _descriptionController.clear();
      _categoryController.clear();
      _unitCostController.clear();
      _sellingPriceController.clear();
      _currentStockController.clear();
      _reorderPointController.clear();
      _safetyStockController.clear();
      _leadTimeDaysController.clear();

      // Refresh products list
      await _fetchProducts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.t('product_created_successfully') ?? 'Product created!')),
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

  Widget _buildCreateProductDrawer(BuildContext context) {
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
                          'Add New Product',
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

              // Form Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Basic Info Section
                        _buildSectionHeader(context, 'Basic Information'),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _skuController,
                          decoration: InputDecoration(
                            labelText: 'SKU *',
                            hintText: 'e.g., PROD-001',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.inventory_2_outlined),
                          ),
                          validator: (v) => (v?.isEmpty ?? true) ? 'SKU required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Product Name *',
                            hintText: 'e.g., Premium Widget',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.label_outlined),
                          ),
                          validator: (v) => (v?.isEmpty ?? true) ? 'Name required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _categoryController,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            hintText: 'e.g., Electronics',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.category_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            hintText: 'Add product details...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.description_outlined),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),

                        // Pricing Section
                        _buildSectionHeader(context, 'Pricing'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _unitCostController,
                                decoration: InputDecoration(
                                  labelText: 'Unit Cost',
                                  hintText: '0.00',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(Icons.attach_money_outlined),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _sellingPriceController,
                                decoration: InputDecoration(
                                  labelText: 'Selling Price',
                                  hintText: '0.00',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(Icons.attach_money_outlined),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Inventory Section
                        _buildSectionHeader(context, 'Inventory'),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _currentStockController,
                          decoration: InputDecoration(
                            labelText: 'Current Stock *',
                            hintText: '0',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.warehouse_outlined),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) => (v?.isEmpty ?? true) ? 'Stock required' : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _reorderPointController,
                                decoration: InputDecoration(
                                  labelText: 'Reorder Point',
                                  hintText: '0',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(Icons.notifications_outlined),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _safetyStockController,
                                decoration: InputDecoration(
                                  labelText: 'Safety Stock',
                                  hintText: '0',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(Icons.security_outlined),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
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
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),

              // Footer with Action Buttons
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _skuController.clear();
                          _nameController.clear();
                          _descriptionController.clear();
                          _categoryController.clear();
                          _unitCostController.clear();
                          _sellingPriceController.clear();
                          _currentStockController.clear();
                          _reorderPointController.clear();
                          _safetyStockController.clear();
                          _leadTimeDaysController.clear();
                        },
                        child: const Text('Clear'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _isLoading ? null : _createProduct,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Create Product'),
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: _buildCreateProductDrawer(context),
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
                  Row(
                    children: [
                      Builder(
                        builder: (context) => FilledButton.icon(
                          onPressed: () => Scaffold.of(context).openEndDrawer(),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('New Product'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.upload_file, size: 18),
                        label: Text(context.l10n.t('import_csv')),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                decoration: InputDecoration(
                  hintText: context.l10n.t('search'),
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _isLoadingProducts
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : _products.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No products yet',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Click "New Product" to add your first product',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          )
                        : ListView(
                            children: _products
                                .where((p) =>
                                    (p['name']?.toString().toLowerCase().contains(_searchQuery) ?? false) ||
                                    (p['sku']?.toString().toLowerCase().contains(_searchQuery) ?? false))
                                .map(
                                  (product) {
                                    final currentStock = product['current_stock'] ?? 0;
                                    final reorderPoint = product['reorder_point'] ?? 0;
                                    final safetyStock = product['safety_stock'] ?? 0;

                                    String status = context.l10n.t('status_safe');
                                    if (currentStock <= safetyStock) {
                                      status = context.l10n.t('status_critical');
                                    } else if (currentStock <= reorderPoint) {
                                      status = context.l10n.t('status_attention');
                                    }

                                    return ListTile(
                                      title: Text(product['name'] ?? 'Unknown'),
                                      subtitle: Text('${product['sku'] ?? 'N/A'} • $currentStock units'),
                                      trailing: Chip(
                                        label: Text(status),
                                        backgroundColor: status == context.l10n.t('status_critical')
                                            ? Colors.red.withValues(alpha: 0.2)
                                            : status == context.l10n.t('status_attention')
                                                ? Colors.orange.withValues(alpha: 0.2)
                                                : Colors.green.withValues(alpha: 0.2),
                                      ),
                                      onTap: () => context.push('/app/products/${product['id']}'),
                                    );
                                  },
                                )
                                .toList(),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
