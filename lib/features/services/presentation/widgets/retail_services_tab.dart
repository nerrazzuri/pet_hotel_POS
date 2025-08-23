import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/services/domain/entities/service.dart';
import 'package:cat_hotel_pos/features/services/domain/entities/product.dart';
import 'package:cat_hotel_pos/core/services/service_dao.dart';
import 'package:cat_hotel_pos/core/services/product_dao.dart';

class RetailServicesTab extends ConsumerStatefulWidget {
  const RetailServicesTab({super.key});

  @override
  ConsumerState<RetailServicesTab> createState() => _RetailServicesTabState();
}

class _RetailServicesTabState extends ConsumerState<RetailServicesTab>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ServiceDao _serviceDao = ServiceDao();
  final ProductDao _productDao = ProductDao();
  
  List<Service> _services = [];
  List<Product> _products = [];
  List<Service> _filteredServices = [];
  List<Product> _filteredProducts = [];
  
  String _searchQuery = '';
  ServiceCategory? _selectedServiceCategory;
  ProductCategory? _selectedProductCategory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final services = await _serviceDao.getAll();
      final products = await _productDao.getAll();
      setState(() {
        _services = services;
        _products = products;
        _filteredServices = services;
        _filteredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  void _filterData() {
    setState(() {
      _filteredServices = _services.where((service) {
        final matchesCategory = _selectedServiceCategory == null || service.category == _selectedServiceCategory;
        final matchesSearch = _searchQuery.isEmpty ||
            service.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            service.serviceCode.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
      
      _filteredProducts = _products.where((product) {
        final matchesCategory = _selectedProductCategory == null || product.category == _selectedProductCategory;
        final matchesSearch = _searchQuery.isEmpty ||
            product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            product.productCode.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
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
              labelText: 'Search Services & Products',
              hintText: 'Search by name or code',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _searchQuery = value;
              _filterData();
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
              text: 'Services',
            ),
            Tab(
              icon: Icon(Icons.inventory),
              text: 'Products',
            ),
          ],
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildServicesTab(),
              _buildProductsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServicesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Retail Services',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddServiceDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Service'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category Filter
          DropdownButtonFormField<ServiceCategory>(
            decoration: const InputDecoration(
              labelText: 'Filter by Category',
              border: OutlineInputBorder(),
            ),
            value: _selectedServiceCategory,
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All Categories'),
              ),
              ...ServiceCategory.values.map((category) => DropdownMenuItem(
                value: category,
                child: Text(category.name.toUpperCase()),
              )),
            ],
            onChanged: (value) {
              _selectedServiceCategory = value;
              _filterData();
            },
          ),
          const SizedBox(height: 24),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredServices.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.miscellaneous_services, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No services found',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredServices.length,
                        itemBuilder: (context, index) {
                          final service = _filteredServices[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getCategoryColor(service.category),
                                child: Icon(
                                  _getCategoryIcon(service.category),
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                service.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(service.serviceCode),
                                  if (service.description != null)
                                    Text(
                                      service.description!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  Row(
                                    children: [
                                      Chip(
                                        label: Text(service.category.name.toUpperCase()),
                                        backgroundColor: _getCategoryColor(service.category).withOpacity(0.2),
                                        labelStyle: TextStyle(
                                          color: _getCategoryColor(service.category),
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (service.duration != null)
                                        Chip(
                                          label: Text('${service.duration} min'),
                                          backgroundColor: Colors.blue.withOpacity(0.2),
                                          labelStyle: const TextStyle(
                                            color: Colors.blue,
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
                                    '\$${service.price.toStringAsFixed(2)}',
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
                                        onPressed: () => _showAddServiceDialog(context, service: service),
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        tooltip: 'Edit',
                                      ),
                                      IconButton(
                                        onPressed: () => _deleteService(service),
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

  Widget _buildProductsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Retail Products',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddProductDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category Filter
          DropdownButtonFormField<ProductCategory>(
            decoration: const InputDecoration(
              labelText: 'Filter by Category',
              border: OutlineInputBorder(),
            ),
            value: _selectedProductCategory,
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All Categories'),
              ),
              ...ProductCategory.values.map((category) => DropdownMenuItem(
                value: category,
                child: Text(category.name.toUpperCase()),
              )),
            ],
            onChanged: (value) {
              _selectedProductCategory = value;
              _filterData();
            },
          ),
          const SizedBox(height: 24),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No products found',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getProductCategoryColor(product.category),
                                child: Icon(
                                  _getProductCategoryIcon(product.category),
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                product.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product.productCode),
                                  if (product.brand != null) Text('Brand: ${product.brand}'),
                                  if (product.description != null)
                                    Text(
                                      product.description!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  Row(
                                    children: [
                                      Chip(
                                        label: Text(product.category.name.toUpperCase()),
                                        backgroundColor: _getProductCategoryColor(product.category).withOpacity(0.2),
                                        labelStyle: TextStyle(
                                          color: _getProductCategoryColor(product.category),
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Chip(
                                        label: Text('Stock: ${product.stockQuantity}'),
                                        backgroundColor: _getStockColor(product.stockQuantity, product.reorderPoint).withOpacity(0.2),
                                        labelStyle: TextStyle(
                                          color: _getStockColor(product.stockQuantity, product.reorderPoint),
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
                                    '\$${product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    'Cost: \$${product.cost.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () => _showAddProductDialog(context, product: product),
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        tooltip: 'Edit',
                                      ),
                                      IconButton(
                                        onPressed: () => _deleteProduct(product),
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

  Color _getCategoryColor(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.grooming:
        return Colors.purple;
      case ServiceCategory.training:
        return Colors.orange;
      case ServiceCategory.wellness:
        return Colors.green;
      case ServiceCategory.medical:
        return Colors.red;
      case ServiceCategory.daycare:
        return Colors.blue;
      case ServiceCategory.addOns:
        return Colors.teal;
      case ServiceCategory.retail:
        return Colors.indigo;
      case ServiceCategory.boarding:
        return Colors.brown;
    }
  }

  IconData _getCategoryIcon(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.grooming:
        return Icons.content_cut;
      case ServiceCategory.training:
        return Icons.school;
      case ServiceCategory.wellness:
        return Icons.favorite;
      case ServiceCategory.medical:
        return Icons.medical_services;
      case ServiceCategory.daycare:
        return Icons.child_care;
      case ServiceCategory.addOns:
        return Icons.add_circle;
      case ServiceCategory.retail:
        return Icons.store;
      case ServiceCategory.boarding:
        return Icons.hotel;
    }
  }

  Color _getProductCategoryColor(ProductCategory category) {
    switch (category) {
      case ProductCategory.food:
        return Colors.orange;
      case ProductCategory.petFood:
        return Colors.amber;
      case ProductCategory.treats:
        return Colors.pink;
      case ProductCategory.toys:
        return Colors.purple;
      case ProductCategory.grooming:
        return Colors.blue;
      case ProductCategory.health:
        return Colors.green;
      case ProductCategory.accessories:
        return Colors.indigo;
      case ProductCategory.bedding:
        return Colors.brown;
      case ProductCategory.litter:
        return Colors.teal;
      case ProductCategory.supplements:
        return Colors.cyan;
      case ProductCategory.cleaning:
        return Colors.lime;
      case ProductCategory.retail:
        return Colors.deepPurple;
      case ProductCategory.services:
        return Colors.amber;
      case ProductCategory.other:
        return Colors.grey;
    }
  }

  IconData _getProductCategoryIcon(ProductCategory category) {
    switch (category) {
      case ProductCategory.food:
        return Icons.restaurant;
      case ProductCategory.petFood:
        return Icons.pets;
      case ProductCategory.treats:
        return Icons.cake;
      case ProductCategory.toys:
        return Icons.toys;
      case ProductCategory.grooming:
        return Icons.content_cut;
      case ProductCategory.health:
        return Icons.favorite;
      case ProductCategory.accessories:
        return Icons.style;
      case ProductCategory.bedding:
        return Icons.bed;
      case ProductCategory.litter:
        return Icons.cleaning_services;
      case ProductCategory.supplements:
        return Icons.medication;
      case ProductCategory.cleaning:
        return Icons.cleaning_services;
      case ProductCategory.retail:
        return Icons.shopping_bag;
      case ProductCategory.services:
        return Icons.miscellaneous_services;
      case ProductCategory.other:
        return Icons.miscellaneous_services;
    }
  }

  Color _getStockColor(int stockQuantity, int reorderPoint) {
    if (stockQuantity == 0) return Colors.red;
    if (stockQuantity <= reorderPoint) return Colors.orange;
    return Colors.green;
  }

  Future<void> _showAddServiceDialog(BuildContext context, {Service? service}) async {
    // This would show the same dialog as in ServicesManagementTab
    // For now, just show a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit service functionality - use the Services tab'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _showAddProductDialog(BuildContext context, {Product? product}) async {
    // This would show the same dialog as in ProductsManagementTab
    // For now, just show a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit product functionality - use the Products tab'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _deleteService(Service service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to delete "${service.name}"?'),
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
        await _serviceDao.delete(service.id);
        _loadData();
        _filterData();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting service: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
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
        await _productDao.delete(product.id);
        _loadData();
        _filterData();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
