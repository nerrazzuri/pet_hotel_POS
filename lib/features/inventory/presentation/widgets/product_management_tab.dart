import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/services/domain/entities/product.dart';
import '../providers/product_providers.dart';
// import 'package:file_picker/file_picker.dart';


class ProductManagementTab extends ConsumerStatefulWidget {
  const ProductManagementTab({super.key});

  @override
  ConsumerState<ProductManagementTab> createState() => _ProductManagementTabState();
}

class _ProductManagementTabState extends ConsumerState<ProductManagementTab> {
  final TextEditingController _searchController = TextEditingController();

  String? _selectedCategory;


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final analyticsAsync = ref.watch(inventoryAnalyticsProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          _buildHeader(),
          const SizedBox(height: 24),

          // Analytics Cards
          analyticsAsync.when(
            data: (analytics) => _buildAnalyticsCards(analytics),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),

          // Search and Filter Bar
          _buildSearchAndFilter(),
          const SizedBox(height: 16),

          // Products List
          Expanded(
            child: productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildProductsList(products);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error loading products: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(productsProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Product Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage your product catalog and inventory',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        Row(
          children: [
            // Low Stock Alert Button
            Consumer(
              builder: (context, ref, child) {
                final lowStockProducts = ref.watch(lowStockProductsProvider);
                return lowStockProducts.when(
                  data: (products) {
                    if (products.isNotEmpty) {
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: ElevatedButton.icon(
                          onPressed: () => _showLowStockAlert(products),
                          icon: const Icon(Icons.warning, color: Colors.orange),
                          label: Text('${products.length} Low Stock'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[100],
                            foregroundColor: Colors.orange[800],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
            ),
            // Add Product Button
            ElevatedButton.icon(
              onPressed: _showAddProductDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            // Bulk Import Button
            OutlinedButton.icon(
              onPressed: _showBulkImportDialog,
              icon: const Icon(Icons.upload_file),
              label: const Text('Bulk Import'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue[600],
                side: BorderSide(color: Colors.blue[600]!),
              ),
            ),
            const SizedBox(width: 12),
            // Export Button
            OutlinedButton.icon(
              onPressed: _exportProducts,
              icon: const Icon(Icons.download),
              label: const Text('Export'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green[600],
                side: BorderSide(color: Colors.green[600]!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalyticsCards(Map<String, dynamic> analytics) {
    return Row(
      children: [
        Expanded(
          child: _buildAnalyticsCard(
            'Total Products',
            analytics['totalProducts']?.toString() ?? '0',
            Icons.inventory,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildAnalyticsCard(
            'Total Value',
            '\$${(analytics['totalValue'] ?? 0.0).toStringAsFixed(2)}',
            Icons.attach_money,
            Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _buildAnalyticsCard(
            'Low Stock',
            (analytics['lowStockCount'] ?? 0).toString(),
            Icons.warning,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildAnalyticsCard(
            'Out of Stock',
            (analytics['outOfStockCount'] ?? 0).toString(),
            Icons.error,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products by name, code, or barcode...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(productSearchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                ref.read(productSearchQueryProvider.notifier).state = value;
              },
            ),
            const SizedBox(height: 16),

            // Filter Chips
            Row(
              children: [
                const Text('Filters: ', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(width: 8),
                // Category Filter
                FilterChip(
                  label: Text(_selectedCategory ?? 'All Categories'),
                  selected: _selectedCategory != null,
                  onSelected: (selected) {
                    if (selected) {
                      _showCategoryFilterDialog();
                    } else {
                      setState(() => _selectedCategory = null);
                      ref.read(productCategoryFilterProvider.notifier).state = null;
                    }
                  },
                ),
                const SizedBox(width: 8),
                // Stock Status Filter
                FilterChip(
                  label: const Text('Low Stock'),
                  selected: false,
                  onSelected: (_) {
                    // Navigate to Stock Control tab
                    // This would require tab controller access
                  },
                ),
                const Spacer(),
                // Clear Filters Button
                if (_selectedCategory != null)
                  TextButton(
                    onPressed: () {
                      setState(() => _selectedCategory = null);
                      ref.read(productCategoryFilterProvider.notifier).state = null;
                    },
                    child: const Text('Clear Filters'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first product to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddProductDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Product'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(List<Product> products) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _ProductCard(
          product: product,
          onTap: () => _showProductDetails(product),
          onEdit: () => _showEditProductDialog(product),
          onDelete: () => _showDeleteConfirmation(product),
        );
      },
    );
  }

  void _showCategoryFilterDialog() {
    final categories = ['Food & Treats', 'Toys', 'Grooming', 'Health', 'Accessories', 'Other'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: categories.map((category) {
            return RadioListTile<String>(
              title: Text(category),
              subtitle: Text(category),
              value: category,
              groupValue: _selectedCategory,
              onChanged: (value) {
                setState(() => _selectedCategory = value);
                ref.read(productCategoryFilterProvider.notifier).state = value;
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => const _ProductDialog(),
    );
  }

  void _showEditProductDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) => _ProductDialog(product: product),
    );
  }

  void _showProductDetails(Product product) {
    showDialog(
      context: context,
      builder: (context) => _ProductDetailsDialog(product: product),
    );
  }

  void _showDeleteConfirmation(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteProduct(product.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await ref.read(productServiceProvider).deleteProduct(productId);
      ref.invalidate(productsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting product: $e')),
        );
      }
    }
  }

  void _showBulkImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Import Products'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Upload a CSV file with product data.'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickCsvFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Select CSV File'),
            ),
            const SizedBox(height: 16),
            const Text(
              'CSV Format: Name,Category,Description,Price,Cost,StockQuantity,ReorderPoint,Supplier',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickCsvFile() async {
    // TODO: Implement CSV parsing and bulk import
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bulk import feature coming soon!')),
      );
    }
  }

  Future<void> _exportProducts() async {
    try {
      // TODO: Implement product export to CSV/Excel
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Export feature coming soon!')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting products: $e')),
        );
      }
    }
  }

  void _showLowStockAlert(List<Product> lowStockProducts) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange[600]),
            const SizedBox(width: 8),
            const Text('Low Stock Alert'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${lowStockProducts.length} products are running low on stock:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...lowStockProducts.map((product) {
                final stockLevel = product.stockQuantity;
                final reorderPoint = product.reorderPoint;
                final urgency = stockLevel <= reorderPoint * 0.5 ? 'Critical' : 'Warning';
                final urgencyColor = stockLevel <= reorderPoint * 0.5 ? Colors.red : Colors.orange;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: urgencyColor.withOpacity(0.1),
                      child: Icon(
                        stockLevel <= reorderPoint * 0.5 ? Icons.error : Icons.warning,
                        color: urgencyColor,
                      ),
                    ),
                    title: Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Stock: $stockLevel units'),
                        Text('Reorder Point: $reorderPoint units'),
                        Text(
                          'Urgency: $urgency',
                          style: TextStyle(
                            color: urgencyColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _createPurchaseOrderForProduct(product),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text('Order'),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () => _createBulkPurchaseOrder(lowStockProducts),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Create Bulk Order'),
          ),
        ],
      ),
    );
  }

  void _createPurchaseOrderForProduct(Product product) {
    // TODO: Implement purchase order creation for specific product
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Creating purchase order for ${product.name}...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _createBulkPurchaseOrder(List<Product> products) {
    // TODO: Implement bulk purchase order creation
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Creating bulk purchase order for ${products.length} products...'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

// Product Card Widget
class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Product Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: product.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.inventory,
                            color: Colors.grey[400],
                          ),
                        ),
                      )
                    : Icon(
                        Icons.inventory,
                        color: Colors.grey[400],
                      ),
              ),
              const SizedBox(width: 16),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description ?? 'No description',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product.category.name,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (product.barcode != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.qr_code, size: 12, color: Colors.green[700]),
                                const SizedBox(width: 4),
                                Text(
                                  'Barcode',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Price and Stock Info
              Column(
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
                  const SizedBox(height: 4),
                  Text(
                    'Stock: ${product.stockQuantity}',
                    style: TextStyle(
                      fontSize: 14,
                      color: _getStockColor(product.stockQuantity, product.reorderPoint),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, size: 20),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStockColor(int stockQuantity, int? reorderPoint) {
    if (stockQuantity == 0) return Colors.red;
    if (reorderPoint != null && stockQuantity <= reorderPoint) return Colors.orange;
    return Colors.green;
  }
}

// Product Dialog Widget
class _ProductDialog extends ConsumerStatefulWidget {
  final Product? product;

  const _ProductDialog({this.product});

  @override
  ConsumerState<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends ConsumerState<_ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _costController = TextEditingController();
  final _stockController = TextEditingController();
  final _reorderPointController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _categoryController = TextEditingController();
  final _supplierController = TextEditingController();
  final _brandController = TextEditingController();
  final _sizeController = TextEditingController();
  final _colorController = TextEditingController();
  final _weightController = TextEditingController();
  final _unitController = TextEditingController();
  final _tagsController = TextEditingController();
  final _specificationsController = TextEditingController();
  final _imageUrlController = TextEditingController();
  

  String? _selectedCategory;
  String? _imageUrl;
  final List<String> _categories = [
    'Food & Treats',
    'Toys',
    'Grooming',
    'Health',
    'Accessories',
    'Other'
  ];

  @override
  void initState() {
    super.initState();

    if (widget.product != null) {
      _populateForm(widget.product!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _stockController.dispose();
    _reorderPointController.dispose();
    _barcodeController.dispose();
    _categoryController.dispose();
    _supplierController.dispose();
    _brandController.dispose();
    _sizeController.dispose();
    _colorController.dispose();
    _weightController.dispose();
    _unitController.dispose();
    _tagsController.dispose();
    _specificationsController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _populateForm(Product product) {
    _nameController.text = product.name;
    _descriptionController.text = product.description ?? '';
    _priceController.text = product.price.toString();
    _costController.text = product.cost.toString();
    _stockController.text = product.stockQuantity.toString();
    _reorderPointController.text = product.reorderPoint?.toString() ?? '';
    _barcodeController.text = product.barcode ?? '';
    _categoryController.text = product.category.name;
    _supplierController.text = product.supplier ?? '';
    _brandController.text = product.brand ?? '';
    _sizeController.text = product.size ?? '';
    _colorController.text = product.color ?? '';
    _weightController.text = product.weight?.toString() ?? '';
    _unitController.text = product.unit ?? '';
    _tagsController.text = product.tags?.join(', ') ?? '';
    _specificationsController.text = product.specifications?.entries.map((e) => '${e.key}: ${e.value}').join(', ') ?? '';
    _selectedCategory = product.category.name;
    _imageUrl = product.imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(productFormProvider);

    return Dialog(
      child: Container(
        width: 700,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.product == null ? 'Add New Product' : 'Edit Product',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Basic Information
                      _buildSectionTitle('Basic Information'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Product Name *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter product name';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _barcodeController,
                              decoration: const InputDecoration(
                                labelText: 'Barcode',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.qr_code_scanner),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),

                      // Pricing & Stock
                      _buildSectionTitle('Pricing & Stock'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              decoration: const InputDecoration(
                                labelText: 'Selling Price *',
                                border: OutlineInputBorder(),
                                prefixText: '\$',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter selling price';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _costController,
                              decoration: const InputDecoration(
                                labelText: 'Cost Price *',
                                border: OutlineInputBorder(),
                                prefixText: '\$',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter cost price';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _stockController,
                              decoration: const InputDecoration(
                                labelText: 'Stock Quantity *',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter stock quantity';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _reorderPointController,
                              decoration: const InputDecoration(
                                labelText: 'Reorder Point',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Category & Supplier
                      _buildSectionTitle('Category & Supplier'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Category *',
                                border: OutlineInputBorder(),
                              ),
                              value: _selectedCategory,
                              items: _categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedCategory = value);
                                _categoryController.text = value ?? '';
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a category';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _supplierController,
                              decoration: const InputDecoration(
                                labelText: 'Supplier',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Additional Details
                      _buildSectionTitle('Additional Details'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _brandController,
                              decoration: const InputDecoration(
                                labelText: 'Brand',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _sizeController,
                              decoration: const InputDecoration(
                                labelText: 'Size',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _colorController,
                              decoration: const InputDecoration(
                                labelText: 'Color',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _weightController,
                              decoration: const InputDecoration(
                                labelText: 'Weight',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _unitController,
                              decoration: const InputDecoration(
                                labelText: 'Unit',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tagsController,
                        decoration: const InputDecoration(
                          labelText: 'Tags (comma separated)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _specificationsController,
                        decoration: const InputDecoration(
                          labelText: 'Specifications',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),

                      // Image Upload
                      _buildSectionTitle('Product Image'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (_imageUrl != null)
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  _imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.image,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.upload),
                            label: const Text('Upload Image'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Error Display
              if (formState.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          formState.error!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: formState.isLoading ? null : _saveProduct,
                    child: formState.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.product == null ? 'Create Product' : 'Update Product'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.teal,
      ),
    );
  }

  Future<void> _pickImage() async {
    // TODO: Implement image upload functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image upload feature coming soon!')),
    );
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      try {
        final product = Product(
          id: widget.product?.id ?? '',
          productCode: _generateProductCode(),
          name: _nameController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          price: double.parse(_priceController.text),
          cost: double.parse(_costController.text),
          stockQuantity: int.parse(_stockController.text),
                      reorderPoint: _reorderPointController.text.isNotEmpty
              ? int.tryParse(_reorderPointController.text) ?? 0
              : 0,
          category: _getProductCategoryFromString(_selectedCategory ?? ''),
          supplier: _supplierController.text.isEmpty ? null : _supplierController.text,
          barcode: _barcodeController.text.isEmpty ? null : _barcodeController.text,
          imageUrl: _imageUrl,
          brand: _brandController.text.isEmpty ? null : _brandController.text,
          size: _sizeController.text.isEmpty ? null : _sizeController.text,
          color: _colorController.text.isEmpty ? null : _colorController.text,
          weight: _weightController.text.isEmpty ? null : _weightController.text,
          unit: _unitController.text.isEmpty ? null : _unitController.text,
          tags: _tagsController.text.isEmpty ? null : _tagsController.text.split(',').map((s) => s.trim()).toList(),
          specifications: _specificationsController.text.isEmpty 
              ? null 
              : Map.fromEntries(_specificationsController.text.split(',').map((s) {
                  final trimmed = s.trim();
                  final parts = trimmed.split(':');
                  if (parts.length == 2) {
                    return MapEntry(parts[0].trim(), parts[1].trim());
                  }
                  return MapEntry(trimmed, '');
                })),
          isActive: true,
          createdAt: widget.product?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        if (widget.product == null) {
          await ref.read(productServiceProvider).createProduct(product);
        } else {
          await ref.read(productServiceProvider).updateProduct(product);
        }

        if (mounted) {
          Navigator.pop(context);
          ref.invalidate(productsProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.product == null 
                    ? 'Product created successfully!' 
                    : 'Product updated successfully!'
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving product: $e')),
          );
        }
      }
    }
  }

  String _generateProductCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    final category = _selectedCategory?.substring(0, 2).toUpperCase() ?? 'PR';
    return '$category$timestamp';
  }

  ProductCategory _getProductCategoryFromString(String categoryString) {
    for (final category in ProductCategory.values) {
      if (category.name == categoryString) {
        return category;
      }
    }
    return ProductCategory.other; // Default fallback
  }
}

// Product Details Dialog
class _ProductDetailsDialog extends StatelessWidget {
  final Product product;

  const _ProductDetailsDialog({required this.product});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.category.name,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Product Image
            if (product.imageUrl != null)
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.image,
                        color: Colors.grey[400],
                        size: 64,
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Product Information
            _buildInfoSection('Basic Information', [
              _buildInfoRow('Description', product.description ?? 'No description'),
              _buildInfoRow('Barcode', product.barcode ?? 'No barcode'),
              _buildInfoRow('Brand', product.brand ?? 'No brand'),
              _buildInfoRow('Size', product.size ?? 'No size'),
              _buildInfoRow('Color', product.color ?? 'No color'),
              _buildInfoRow('Weight', product.weight != null 
                  ? '${product.weight} ${product.unit ?? ''}'
                  : 'No weight'),
            ]),
            const SizedBox(height: 16),

            _buildInfoSection('Pricing & Stock', [
              _buildInfoRow('Selling Price', '\$${product.price.toStringAsFixed(2)}'),
              _buildInfoRow('Cost Price', '\$${product.cost.toStringAsFixed(2)}'),
              _buildInfoRow('Stock Quantity', product.stockQuantity.toString()),
              _buildInfoRow('Reorder Point', product.reorderPoint?.toString() ?? 'Not set'),
              _buildInfoRow('Supplier', product.supplier ?? 'No supplier'),
            ]),
            const SizedBox(height: 16),

            if (product.tags?.isNotEmpty == true) ...[
              _buildInfoSection('Tags', [
                _buildInfoRow('', product.tags!.join(', ')),
              ]),
              const SizedBox(height: 16),
            ],

            if (product.specifications?.isNotEmpty == true) ...[
              _buildInfoSection('Specifications', [
                _buildInfoRow('', product.specifications!.entries.map((e) => '${e.key}: ${e.value}').join(', ')),
              ]),
              const SizedBox(height: 16),
            ],

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          if (label.isNotEmpty) ...[
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  ProductCategory _getProductCategoryFromString(String categoryString) {
    for (final category in ProductCategory.values) {
      if (category.name == categoryString) {
        return category;
      }
    }
    return ProductCategory.other; // Default fallback
  }
}
