import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/services/domain/entities/product.dart';
import 'package:cat_hotel_pos/core/services/product_dao.dart';

class ProductsManagementTab extends ConsumerStatefulWidget {
  const ProductsManagementTab({super.key});

  @override
  ConsumerState<ProductsManagementTab> createState() => _ProductsManagementTabState();
}

class _ProductsManagementTabState extends ConsumerState<ProductsManagementTab> {
  final ProductDao _productDao = ProductDao();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  ProductCategory? _selectedCategory;
  ProductStatus? _selectedStatus;
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    try {
      final products = await _productDao.getAll();
      if (mounted) {
        setState(() {
          _products = products;
          _filteredProducts = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading products: $e')),
        );
      }
    }
  }

  void _filterProducts() {
    if (_products.isEmpty) return;
    
    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesCategory = _selectedCategory == null || product.category == _selectedCategory;
        final matchesStatus = _selectedStatus == null || product.status == _selectedStatus;
        final matchesSearch = _searchQuery.isEmpty ||
            product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            product.productCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (product.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
            (product.brand?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
        return matchesCategory && matchesStatus && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Add error boundary
    if (_products.isEmpty && !_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No products available',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              Text(
                'Please check if data has been properly loaded',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Products Management',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddEditProductDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filters
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Search Products',
                            hintText: 'Search by name, code, brand, or description',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            _searchQuery = value;
                            _filterProducts();
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      DropdownButtonFormField<ProductCategory>(
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedCategory,
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
                          _selectedCategory = value;
                          _filterProducts();
                        },
                      ),
                      const SizedBox(width: 16),
                      DropdownButtonFormField<ProductStatus>(
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedStatus,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Statuses'),
                          ),
                          ...ProductStatus.values.map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.name.toUpperCase()),
                          )),
                        ],
                        onChanged: (value) {
                          _selectedStatus = value;
                          _filterProducts();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Products List
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
                    : _filteredProducts.isNotEmpty
                        ? ListView.builder(
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getCategoryColor(product.category),
                                child: Icon(
                                  _getCategoryIcon(product.category),
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
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      Chip(
                                        label: Text(product.category.name.toUpperCase()),
                                        backgroundColor: _getCategoryColor(product.category).withOpacity(0.2),
                                        labelStyle: TextStyle(
                                          color: _getCategoryColor(product.category),
                                          fontSize: 12,
                                        ),
                                      ),
                                      Chip(
                                        label: Text(product.status?.name.toUpperCase() ?? 'UNKNOWN'),
                                        backgroundColor: _getStatusColor(product.status).withOpacity(0.2),
                                        labelStyle: TextStyle(
                                          color: _getStatusColor(product.status),
                                          fontSize: 12,
                                        ),
                                      ),
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
                                        onPressed: () => _showAddEditProductDialog(context, product: product),
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
                      )
                        : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(ProductCategory category) {
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

  IconData _getCategoryIcon(ProductCategory category) {
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

  Color _getStatusColor(ProductStatus? status) {
    switch (status) {
      case ProductStatus.inStock:
        return Colors.green;
      case ProductStatus.lowStock:
        return Colors.orange;
      case ProductStatus.outOfStock:
        return Colors.red;
      case ProductStatus.discontinued:
        return Colors.grey;
      case ProductStatus.preOrder:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getStockColor(int stockQuantity, int reorderPoint) {
    if (stockQuantity == 0) return Colors.red;
    if (stockQuantity <= reorderPoint) return Colors.orange;
    return Colors.green;
  }

  Future<void> _showAddEditProductDialog(BuildContext context, {Product? product}) async {
    final isEditing = product != null;
    final nameController = TextEditingController(text: product?.name ?? '');
    final codeController = TextEditingController(text: product?.productCode ?? '');
    final descriptionController = TextEditingController(text: product?.description ?? '');
    final priceController = TextEditingController(text: product?.price.toString() ?? '');
    final costController = TextEditingController(text: product?.cost.toString() ?? '');
    final stockController = TextEditingController(text: product?.stockQuantity.toString() ?? '');
    final reorderController = TextEditingController(text: product?.reorderPoint.toString() ?? '');
    final supplierController = TextEditingController(text: product?.supplier ?? '');
    final brandController = TextEditingController(text: product?.brand ?? '');
    final barcodeController = TextEditingController(text: product?.barcode ?? '');
    
    ProductCategory selectedCategory = product?.category ?? ProductCategory.food;
    ProductStatus selectedStatus = product?.status ?? ProductStatus.inStock;
    bool isActive = product?.isActive ?? true;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Product' : 'Add New Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Product Code'),
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
                      controller: costController,
                      decoration: const InputDecoration(labelText: 'Cost'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: stockController,
                      decoration: const InputDecoration(labelText: 'Stock Quantity'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: reorderController,
                      decoration: const InputDecoration(labelText: 'Reorder Point'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              TextField(
                controller: supplierController,
                decoration: const InputDecoration(labelText: 'Supplier'),
              ),
              TextField(
                controller: brandController,
                decoration: const InputDecoration(labelText: 'Brand'),
              ),
              TextField(
                controller: barcodeController,
                decoration: const InputDecoration(labelText: 'Barcode'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<ProductCategory>(
                      decoration: const InputDecoration(labelText: 'Category'),
                      value: selectedCategory,
                      items: ProductCategory.values.map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category.name.toUpperCase()),
                      )).toList(),
                      onChanged: (value) => selectedCategory = value!,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<ProductStatus>(
                      decoration: const InputDecoration(labelText: 'Status'),
                      value: selectedStatus,
                      items: ProductStatus.values.map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.name.toUpperCase()),
                      )).toList(),
                      onChanged: (value) => selectedStatus = value!,
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
                final newProduct = Product(
                  id: product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  productCode: codeController.text,
                  name: nameController.text,
                  category: selectedCategory,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  cost: double.tryParse(costController.text) ?? 0.0,
                  stockQuantity: int.tryParse(stockController.text) ?? 0,
                  reorderPoint: int.tryParse(reorderController.text) ?? 0,
                  isActive: isActive,
                  createdAt: product?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                  description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
                  supplier: supplierController.text.isNotEmpty ? supplierController.text : null,
                  brand: brandController.text.isNotEmpty ? brandController.text : null,
                  barcode: barcodeController.text.isNotEmpty ? barcodeController.text : null,
                  status: selectedStatus,
                );

                if (isEditing) {
                  await _productDao.update(newProduct);
                } else {
                  await _productDao.insert(newProduct);
                }

                Navigator.of(context).pop();
                _loadProducts();
                _filterProducts();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Product ${isEditing ? 'updated' : 'added'} successfully!'),
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
        _loadProducts();
        _filterProducts();
        
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
