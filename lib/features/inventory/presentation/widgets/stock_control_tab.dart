import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/services/domain/entities/product.dart';
import 'package:cat_hotel_pos/features/inventory/domain/entities/inventory_transaction.dart';
import '../providers/product_providers.dart';
import '../providers/inventory_transaction_providers.dart';

class StockControlTab extends ConsumerStatefulWidget {
  const StockControlTab({super.key});

  @override
  ConsumerState<StockControlTab> createState() => _StockControlTabState();
}

class _StockControlTabState extends ConsumerState<StockControlTab> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          _buildHeader(),
          const SizedBox(height: 24),
          
          // Tab Navigation
          _buildTabNavigation(),
          const SizedBox(height: 24),
          
          // Content based on selected tab
          Expanded(
            child: _buildTabContent(),
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
            Text(
              'Stock Control & Inventory Management',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.teal[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Monitor stock levels, track movements, and manage inventory',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _showStockAdjustmentDialog(context),
              icon: const Icon(Icons.tune),
              label: const Text('Adjust Stock'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _showStockTransferDialog(context),
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Transfer Stock'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabNavigation() {
    final tabs = [
      {'title': 'Overview', 'icon': Icons.dashboard},
      {'title': 'Low Stock', 'icon': Icons.warning},
      {'title': 'Out of Stock', 'icon': Icons.remove_shopping_cart},
      {'title': 'Transactions', 'icon': Icons.receipt_long},
      {'title': 'Analytics', 'icon': Icons.analytics},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = _selectedIndex == index;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tab['icon'] as IconData,
                    size: 18,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(tab['title'] as String),
                ],
              ),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedIndex = index),
              backgroundColor: Colors.grey[100],
              selectedColor: Colors.teal,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildLowStockTab();
      case 2:
        return _buildOutOfStockTab();
      case 3:
        return _buildTransactionsTab();
      case 4:
        return _buildAnalyticsTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    return Consumer(
      builder: (context, ref, child) {
        final analyticsAsync = ref.watch(inventoryAnalyticsProvider);
        final productsAsync = ref.watch(productsProvider);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Analytics Cards
            analyticsAsync.when(
              data: (analytics) => _buildAnalyticsCards(analytics),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error: $error'),
            ),
            
            const SizedBox(height: 24),
            
            // Recent Products
            Text(
              'Recent Products',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: productsAsync.when(
                data: (products) => _buildProductsList(products.take(10).toList()),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text('Error: $error'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnalyticsCards(Map<String, dynamic> analytics) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: [
        _buildAnalyticsCard(
          'Total Products',
          '${analytics['totalProducts'] ?? 0}',
          Icons.inventory,
          Colors.blue,
        ),
        _buildAnalyticsCard(
          'Total Stock Value',
          '\$${(analytics['totalStockValue'] ?? 0).toStringAsFixed(2)}',
          Icons.attach_money,
          Colors.green,
        ),
        _buildAnalyticsCard(
          'Total Items',
          '${analytics['totalStockItems'] ?? 0}',
          Icons.shopping_cart,
          Colors.orange,
        ),
        _buildAnalyticsCard(
          'Low Stock',
          '${analytics['lowStockCount'] ?? 0}',
          Icons.warning,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockTab() {
    return Consumer(
      builder: (context, ref, child) {
        final lowStockAsync = ref.watch(lowStockProductsProvider);

        return lowStockAsync.when(
          data: (products) => _buildProductsList(products),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('Error: $error'),
        );
      },
    );
  }

  Widget _buildOutOfStockTab() {
    return Consumer(
      builder: (context, ref, child) {
        final outOfStockAsync = ref.watch(outOfStockProductsProvider);

        return outOfStockAsync.when(
          data: (products) => _buildProductsList(products),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('Error: $error'),
        );
      },
    );
  }

  Widget _buildTransactionsTab() {
    return Consumer(
      builder: (context, ref, child) {
        final transactionsAsync = ref.watch(inventoryTransactionsProvider);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search and Filters
            _buildTransactionFilters(),
            const SizedBox(height: 16),
            
            // Transactions List
            Expanded(
              child: transactionsAsync.when(
                data: (transactions) => _buildTransactionsList(transactions),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text('Error: $error'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionFilters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search transactions...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              ref.read(transactionSearchQueryProvider.notifier).state = value;
            },
          ),
        ),
        const SizedBox(width: 16),
        Consumer(
          builder: (context, ref, child) {
            final selectedType = ref.watch(transactionTypeFilterProvider);
            
            return DropdownButton<TransactionType?>(
              value: selectedType,
              hint: const Text('Filter by Type'),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Types'),
                ),
                ...TransactionType.values.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                )),
              ],
              onChanged: (value) {
                ref.read(transactionTypeFilterProvider.notifier).state = value;
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    return Consumer(
      builder: (context, ref, child) {
        final analyticsAsync = ref.watch(inventoryAnalyticsProvider);

        return analyticsAsync.when(
          data: (analytics) => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Detailed Analytics
                _buildDetailedAnalytics(analytics),
                const SizedBox(height: 24),
                
                // Charts Placeholder
                _buildChartsPlaceholder(),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('Error: $error'),
        );
      },
    );
  }

  Widget _buildDetailedAnalytics(Map<String, dynamic> analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detailed Inventory Analytics',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: 3,
              children: [
                _buildDetailItem('Average Stock Value', '\$${(analytics['averageStockValue'] ?? 0).toStringAsFixed(2)}'),
                _buildDetailItem('Out of Stock Items', '${analytics['outOfStockCount'] ?? 0}'),
                _buildDetailItem('Low Stock Items', '${analytics['lowStockCount'] ?? 0}'),
                _buildDetailItem('Total Stock Items', '${analytics['totalStockItems'] ?? 0}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.teal[800],
          ),
        ),
      ],
    );
  }

  Widget _buildChartsPlaceholder() {
    return Card(
      child: Container(
        height: 300,
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Inventory Charts',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Charts and graphs will be displayed here',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsList(List<Product> products) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStockColor(product.stockQuantity, product.reorderPoint),
              child: Text(
                product.stockQuantity.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Code: ${product.productCode}'),
                Text('Category: ${product.category}'),
                Text('Stock: ${product.stockQuantity} | Cost: \$${product.cost.toStringAsFixed(2)}'),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'adjust',
                  child: Row(
                    children: [
                      Icon(Icons.tune),
                      SizedBox(width: 8),
                      Text('Adjust Stock'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'transfer',
                  child: Row(
                    children: [
                      Icon(Icons.swap_horiz),
                      SizedBox(width: 8),
                      Text('Transfer Stock'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'adjust':
                    _showStockAdjustmentDialog(context, product: product);
                    break;
                  case 'transfer':
                    _showStockTransferDialog(context, product: product);
                    break;
                  case 'view':
                    _showProductDetailsDialog(context, product);
                    break;
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionsList(List<InventoryTransaction> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getTransactionTypeColor(transaction.type),
              child: Icon(
                _getTransactionIcon(transaction.type),
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              transaction.productName ?? 'Unknown Product',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type: ${transaction.type.displayName}'),
                Text('Quantity: ${transaction.quantity} | Cost: \$${transaction.totalCost.toStringAsFixed(2)}'),
                if (transaction.notes != null) Text('Notes: ${transaction.notes}'),
                Text('Date: ${_formatDate(transaction.createdAt)}'),
              ],
            ),
            trailing: Text(
              _isPositiveTransaction(transaction.type) ? '+${transaction.quantity}' : '-${transaction.quantity}',
              style: TextStyle(
                color: _isPositiveTransaction(transaction.type) ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStockColor(int stockQuantity, int? reorderPoint) {
    if (stockQuantity <= 0) return Colors.red;
    if (reorderPoint != null && stockQuantity <= reorderPoint) return Colors.orange;
    return Colors.green;
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.purchase:
        return Icons.add_shopping_cart;
      case TransactionType.sale:
        return Icons.remove_shopping_cart;
      case TransactionType.adjustment:
        return Icons.tune;
      case TransactionType.transfer:
        return Icons.swap_horiz;
      case TransactionType.returnItem:
        return Icons.undo;
      case TransactionType.damage:
        return Icons.warning;
      case TransactionType.expiry:
        return Icons.schedule;
      case TransactionType.initial:
        return Icons.inventory;
      case TransactionType.count:
        return Icons.calculate;
    }
    return Icons.help;
  }

  Color _getTransactionTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.purchase:
        return Colors.green;
      case TransactionType.sale:
        return Colors.orange;
      case TransactionType.adjustment:
        return Colors.blue;
      case TransactionType.transfer:
        return Colors.purple;
      case TransactionType.returnItem:
        return Colors.red;
      case TransactionType.damage:
        return Colors.red;
      case TransactionType.expiry:
        return Colors.orange;
      case TransactionType.initial:
        return Colors.blue;
      case TransactionType.count:
        return Colors.purple;
    }
    return Colors.grey;
  }

  bool _isPositiveTransaction(TransactionType type) {
    switch (type) {
      case TransactionType.purchase:
      case TransactionType.returnItem:
      case TransactionType.initial:
        return true;
      case TransactionType.sale:
      case TransactionType.damage:
      case TransactionType.expiry:
        return false;
      case TransactionType.adjustment:
      case TransactionType.transfer:
      case TransactionType.count:
        return true; // These can be positive or negative based on context
    }
    return true;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showStockAdjustmentDialog(BuildContext context, {Product? product}) {
    showDialog(
      context: context,
      builder: (context) => StockAdjustmentDialog(product: product),
    );
  }

  void _showStockTransferDialog(BuildContext context, {Product? product}) {
    showDialog(
      context: context,
      builder: (context) => StockTransferDialog(product: product),
    );
  }

  void _showProductDetailsDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => ProductDetailsDialog(product: product),
    );
  }
}

// Stock Adjustment Dialog
class StockAdjustmentDialog extends ConsumerStatefulWidget {
  final Product? product;

  const StockAdjustmentDialog({super.key, this.product});

  @override
  ConsumerState<StockAdjustmentDialog> createState() => _StockAdjustmentDialogState();
}

class _StockAdjustmentDialogState extends ConsumerState<StockAdjustmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();
  TransactionType _selectedType = TransactionType.adjustment;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _quantityController.text = '1';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Stock Adjustment'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.product != null) ...[
              Text('Product: ${widget.product!.name}'),
              Text('Current Stock: ${widget.product!.stockQuantity}'),
              const SizedBox(height: 16),
            ],
            
            DropdownButtonFormField<TransactionType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Adjustment Type',
                border: OutlineInputBorder(),
              ),
              items: TransactionType.values.map((type) => DropdownMenuItem(
                value: type,
                child: Text(type.displayName),
              )).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter quantity';
                }
                if (int.tryParse(value) == null || int.parse(value) <= 0) {
                  return 'Please enter a valid positive number';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a reason';
                }
                return null;
              },
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
          onPressed: _submitAdjustment,
          child: const Text('Submit'),
        ),
      ],
    );
  }

  void _submitAdjustment() {
    if (_formKey.currentState!.validate()) {
      final quantity = int.parse(_quantityController.text);
      final reason = _reasonController.text;
      
      if (widget.product != null) {
        ref.read(stockAdjustmentFormProvider.notifier).state = 
          ref.read(stockAdjustmentFormProvider.notifier).state.copyWith(
            productId: widget.product!.id,
            quantity: quantity,
            reason: reason,
            // type field removed from new entity structure
          );
        
        ref.read(stockAdjustmentFormProvider.notifier).adjustStock();
      }
      
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock adjustment submitted')),
      );
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }
}

// Stock Transfer Dialog
class StockTransferDialog extends ConsumerStatefulWidget {
  final Product? product;

  const StockTransferDialog({super.key, this.product});

  @override
  ConsumerState<StockTransferDialog> createState() => _StockTransferDialogState();
}

class _StockTransferDialogState extends ConsumerState<StockTransferDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _fromLocationController = TextEditingController();
  final _toLocationController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _quantityController.text = '1';
    }
    _fromLocationController.text = 'Main Storage';
    _toLocationController.text = 'Front Counter';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Stock Transfer'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.product != null) ...[
              Text('Product: ${widget.product!.name}'),
              Text('Available Stock: ${widget.product!.stockQuantity}'),
              const SizedBox(height: 16),
            ],
            
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity to Transfer',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter quantity';
                }
                if (int.tryParse(value) == null || int.parse(value) <= 0) {
                  return 'Please enter a valid positive number';
                }
                if (widget.product != null && int.parse(value) > widget.product!.stockQuantity) {
                  return 'Quantity exceeds available stock';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _fromLocationController,
              decoration: const InputDecoration(
                labelText: 'From Location',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter source location';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _toLocationController,
              decoration: const InputDecoration(
                labelText: 'To Location',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter destination location';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
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
          onPressed: _submitTransfer,
          child: const Text('Transfer'),
        ),
      ],
    );
  }

  void _submitTransfer() {
    if (_formKey.currentState!.validate()) {
      final quantity = int.parse(_quantityController.text);
      final fromLocation = _fromLocationController.text;
      final toLocation = _toLocationController.text;
      final notes = _notesController.text;
      
      if (widget.product != null) {
        // Call the transfer method
        ref.read(productServiceProvider).transferStock(
          widget.product!.id,
          quantity,
          fromLocation,
          toLocation,
          notes,
        );
      }
      
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock transfer completed')),
      );
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _fromLocationController.dispose();
    _toLocationController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

// Product Details Dialog
class ProductDetailsDialog extends StatelessWidget {
  final Product product;

  const ProductDetailsDialog({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(product.name),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Product Code', product.productCode),
            _buildDetailRow('Category', product.category.name),
            _buildDetailRow('Description', product.description ?? 'N/A'),
            _buildDetailRow('Price', '\$${product.price.toStringAsFixed(2)}'),
            _buildDetailRow('Cost', '\$${product.cost.toStringAsFixed(2)}'),
            _buildDetailRow('Stock Quantity', product.stockQuantity.toString()),
            _buildDetailRow('Reorder Point', product.reorderPoint?.toString() ?? 'Not set'),
            _buildDetailRow('Supplier', product.supplier ?? 'N/A'),
            if (product.brand != null) _buildDetailRow('Brand', product.brand!),
            if (product.size != null) _buildDetailRow('Size', product.size!),
            if (product.color != null) _buildDetailRow('Color', product.color!),
            if (product.weight != null) _buildDetailRow('Weight', '${product.weight} ${product.unit ?? ''}'),
            _buildDetailRow('Created', _formatDate(product.createdAt)),
            _buildDetailRow('Updated', _formatDate(product.updatedAt)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
