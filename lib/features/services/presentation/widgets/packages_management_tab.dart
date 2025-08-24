import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/services/domain/entities/service.dart';
import 'package:cat_hotel_pos/features/services/domain/entities/product.dart';
import 'package:cat_hotel_pos/core/services/service_package_dao.dart';
import 'package:cat_hotel_pos/core/services/product_bundle_dao.dart';

class PackagesManagementTab extends ConsumerStatefulWidget {
  const PackagesManagementTab({super.key});

  @override
  ConsumerState<PackagesManagementTab> createState() => _PackagesManagementTabState();
}

class _PackagesManagementTabState extends ConsumerState<PackagesManagementTab>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ServicePackageDao _servicePackageDao = ServicePackageDao();
  final ProductBundleDao _productBundleDao = ProductBundleDao();
  
  List<ServicePackage> _servicePackages = [];
  List<ProductBundle> _productBundles = [];
  List<ServicePackage> _filteredServicePackages = [];
  List<ProductBundle> _filteredProductBundles = [];
  
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPackages();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPackages() async {
    setState(() => _isLoading = true);
    try {
      final servicePackages = await _servicePackageDao.getAll();
      final productBundles = await _productBundleDao.getAll();
      setState(() {
        _servicePackages = servicePackages;
        _productBundles = productBundles;
        _filteredServicePackages = servicePackages;
        _filteredProductBundles = productBundles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading packages: $e')),
        );
      }
    }
  }

  void _filterPackages() {
    setState(() {
      _filteredServicePackages = _servicePackages.where((package) =>
        _searchQuery.isEmpty ||
        package.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (package.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
      
      _filteredProductBundles = _productBundles.where((bundle) =>
        _searchQuery.isEmpty ||
        bundle.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (bundle.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Search Packages',
              hintText: 'Search by name or description',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _searchQuery = value;
              _filterPackages();
            },
          ),
        ),

        // Tab Bar
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(
              icon: Icon(Icons.miscellaneous_services),
              text: 'Service Packages',
            ),
            Tab(
              icon: Icon(Icons.inventory),
              text: 'Product Bundles',
            ),
          ],
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildServicePackagesTab(),
              _buildProductBundlesTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServicePackagesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Service Packages',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddEditServicePackageDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Package'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredServicePackages.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.card_giftcard, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No service packages found',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredServicePackages.length,
                        itemBuilder: (context, index) {
                          final package = _filteredServicePackages[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.purple,
                                child: const Icon(Icons.card_giftcard, color: Colors.white),
                              ),
                              title: Text(
                                package.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (package.description != null)
                                    Text(
                                      package.description!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      Chip(
                                        label: Text('${package.validityDays} days'),
                                        backgroundColor: Colors.blue.withOpacity(0.2),
                                        labelStyle: const TextStyle(
                                          color: Colors.blue,
                                          fontSize: 12,
                                        ),
                                      ),
                                      if (package.discountPercentage != null)
                                        Chip(
                                          label: Text('${package.discountPercentage}% off'),
                                          backgroundColor: Colors.green.withOpacity(0.2),
                                          labelStyle: const TextStyle(
                                            color: Colors.green,
                                            fontSize: 12,
                                          ),
                                        ),
                                      if (package.maxUses != null)
                                        Chip(
                                          label: Text('Max: ${package.maxUses}'),
                                          backgroundColor: Colors.orange.withOpacity(0.2),
                                          labelStyle: const TextStyle(
                                            color: Colors.orange,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${package.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () => _showAddEditServicePackageDialog(context, package: package),
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        tooltip: 'Edit',
                                      ),
                                      IconButton(
                                        onPressed: () => _deleteServicePackage(package),
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        tooltip: 'Delete',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductBundlesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Product Bundles',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddEditProductBundleDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Bundle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProductBundles.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No product bundles found',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredProductBundles.length,
                        itemBuilder: (context, index) {
                          final bundle = _filteredProductBundles[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.indigo,
                                child: const Icon(Icons.inventory, color: Colors.white),
                              ),
                              title: Text(
                                bundle.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (bundle.description != null)
                                    Text(
                                      bundle.description!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      if (bundle.productIds != null)
                                        Chip(
                                          label: Text('${bundle.productIds!.length} products'),
                                          backgroundColor: Colors.indigo.withOpacity(0.2),
                                          labelStyle: const TextStyle(
                                            color: Colors.indigo,
                                            fontSize: 12,
                                          ),
                                        ),
                                      const SizedBox(width: 8),
                                      if (bundle.discountPercentage != null)
                                        Chip(
                                          label: Text('${bundle.discountPercentage}% off'),
                                          backgroundColor: Colors.green.withOpacity(0.2),
                                          labelStyle: const TextStyle(
                                            color: Colors.green,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${bundle.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () => _showAddEditProductBundleDialog(context, bundle: bundle),
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        tooltip: 'Edit',
                                      ),
                                      IconButton(
                                        onPressed: () => _deleteProductBundle(bundle),
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        tooltip: 'Delete',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddEditServicePackageDialog(BuildContext context, {ServicePackage? package}) async {
    final isEditing = package != null;
    final nameController = TextEditingController(text: package?.name ?? '');
    final descriptionController = TextEditingController(text: package?.description ?? '');
    final priceController = TextEditingController(text: package?.price.toString() ?? '');
    final validityController = TextEditingController(text: package?.validityDays.toString() ?? '');
    final maxUsesController = TextEditingController(text: package?.maxUses?.toString() ?? '');
    final discountController = TextEditingController(text: package?.discountPercentage?.toString() ?? '');
    
    bool isActive = package?.isActive ?? true;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Service Package' : 'Add New Service Package'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Package Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: validityController,
                      decoration: const InputDecoration(labelText: 'Validity (days)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: maxUsesController,
                      decoration: const InputDecoration(labelText: 'Max Uses'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: discountController,
                      decoration: const InputDecoration(labelText: 'Discount %'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: isActive,
                    onChanged: (value) => isActive = value!,
                  ),
                  const Text('Active'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final newPackage = ServicePackage(
                  id: package?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  description: descriptionController.text.isNotEmpty ? descriptionController.text : 'No description',
                  price: double.tryParse(priceController.text) ?? 0.0,
                  validityDays: int.tryParse(validityController.text) ?? 30,
                  isActive: isActive,
                  createdAt: package?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                  maxUses: int.tryParse(maxUsesController.text),
                  discountPercentage: double.tryParse(discountController.text),
                );

                if (isEditing) {
                  await _servicePackageDao.update(newPackage);
                } else {
                  await _servicePackageDao.insert(newPackage);
                }

                Navigator.of(context).pop();
                _loadPackages();
                _filterPackages();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Service package ${isEditing ? 'updated' : 'added'} successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddEditProductBundleDialog(BuildContext context, {ProductBundle? bundle}) async {
    final isEditing = bundle != null;
    final nameController = TextEditingController(text: bundle?.name ?? '');
    final descriptionController = TextEditingController(text: bundle?.description ?? '');
    final priceController = TextEditingController(text: bundle?.price.toString() ?? '');
    final discountController = TextEditingController(text: bundle?.discountPercentage?.toString() ?? '');
    
    bool isActive = bundle?.isActive ?? true;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Product Bundle' : 'Add New Product Bundle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Bundle Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: discountController,
                      decoration: const InputDecoration(labelText: 'Discount %'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: isActive,
                    onChanged: (value) => isActive = value!,
                  ),
                  const Text('Active'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final newBundle = ProductBundle(
                  id: bundle?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  description: descriptionController.text.isNotEmpty ? descriptionController.text : 'No description',
                  price: double.tryParse(priceController.text) ?? 0.0,
                  isActive: isActive,
                  createdAt: bundle?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                  discountPercentage: double.tryParse(discountController.text),
                );

                if (isEditing) {
                  await _productBundleDao.update(newBundle);
                } else {
                  await _productBundleDao.insert(newBundle);
                }

                Navigator.of(context).pop();
                _loadPackages();
                _filterPackages();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Product bundle ${isEditing ? 'updated' : 'added'} successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteServicePackage(ServicePackage package) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service Package'),
        content: Text('Are you sure you want to delete "${package.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _servicePackageDao.delete(package.id);
        _loadPackages();
        _filterPackages();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service package deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting service package: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteProductBundle(ProductBundle bundle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product Bundle'),
        content: Text('Are you sure you want to delete "${bundle.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _productBundleDao.delete(bundle.id);
        _loadPackages();
        _filterPackages();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product bundle deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting product bundle: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
