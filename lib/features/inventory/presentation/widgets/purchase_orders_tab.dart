import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/inventory/presentation/providers/purchase_order_providers.dart';
import 'package:cat_hotel_pos/features/inventory/presentation/providers/supplier_providers.dart';
import 'package:cat_hotel_pos/features/inventory/domain/entities/purchase_order.dart';
import 'package:cat_hotel_pos/features/inventory/domain/entities/purchase_order_item.dart';
import 'package:cat_hotel_pos/features/inventory/domain/entities/supplier.dart';

class PurchaseOrdersTab extends ConsumerStatefulWidget {
  const PurchaseOrdersTab({super.key});

  @override
  ConsumerState<PurchaseOrdersTab> createState() => _PurchaseOrdersTabState();
}

class _PurchaseOrdersTabState extends ConsumerState<PurchaseOrdersTab> {
  final TextEditingController _searchController = TextEditingController();
  PurchaseOrderStatus? _selectedStatus;
  String? _selectedSupplierId;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref.read(purchaseOrderSearchQueryProvider.notifier).state = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final purchaseOrdersAsync = ref.watch(filteredPurchaseOrdersProvider);
    final suppliersAsync = ref.watch(suppliersProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          _buildHeader(),
          const SizedBox(height: 24),

          // Search and Filter Bar
          _buildSearchAndFilter(suppliersAsync),
          const SizedBox(height: 16),

          // Purchase Orders List
          Expanded(
            child: purchaseOrdersAsync.when(
              data: (purchaseOrders) {
                if (purchaseOrders.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildPurchaseOrdersList(purchaseOrders);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error loading purchase orders: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(filteredPurchaseOrdersProvider),
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
              'Purchase Orders',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage and track all purchase orders',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showCreatePurchaseOrderDialog(),
          icon: const Icon(Icons.add),
          label: const Text('New Purchase Order'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter(AsyncValue<List<Supplier>> suppliersAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search purchase orders...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(purchaseOrderSearchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),

            // Filter Chips
            Row(
              children: [
                const Text('Filters: ', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(width: 8),
                // Status Filter
                FilterChip(
                  label: Text(_selectedStatus?.displayName ?? 'All Statuses'),
                  selected: _selectedStatus != null,
                  onSelected: (selected) {
                    if (selected) {
                      _showStatusFilterDialog();
                    } else {
                      setState(() => _selectedStatus = null);
                      ref.read(purchaseOrderStatusFilterProvider.notifier).state = null;
                    }
                  },
                ),
                const SizedBox(width: 8),
                // Supplier Filter
                suppliersAsync.when(
                  data: (suppliers) => FilterChip(
                    label: Text(_selectedSupplierId != null 
                        ? suppliers.firstWhere((s) => s.id == _selectedSupplierId).name
                        : 'All Suppliers'),
                    selected: _selectedSupplierId != null,
                    onSelected: (selected) {
                      if (selected) {
                        _showSupplierFilterDialog(suppliers);
                      } else {
                        setState(() => _selectedSupplierId = null);
                        ref.read(purchaseOrderSupplierFilterProvider.notifier).state = null;
                      }
                    },
                  ),
                  loading: () => FilterChip(
                    label: const Text('Loading...'),
                    selected: false,
                    onSelected: (_) {},
                  ),
                  error: (_, __) => FilterChip(
                    label: const Text('Error'),
                    selected: false,
                    onSelected: (_) {},
                  ),
                ),
                const Spacer(),
                // Clear Filters Button
                if (_selectedStatus != null || _selectedSupplierId != null)
                  TextButton(
                    onPressed: _clearFilters,
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
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No purchase orders found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first purchase order to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreatePurchaseOrderDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Create Purchase Order'),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseOrdersList(List<PurchaseOrder> purchaseOrders) {
    return ListView.builder(
      itemCount: purchaseOrders.length,
      itemBuilder: (context, index) {
        final order = purchaseOrders[index];
        return _PurchaseOrderCard(
          purchaseOrder: order,
          onTap: () => _showPurchaseOrderDetails(order),
          onStatusChange: () => _showStatusChangeDialog(order),
        );
      },
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedSupplierId = null;
    });
    ref.read(purchaseOrderStatusFilterProvider.notifier).state = null;
    ref.read(purchaseOrderSupplierFilterProvider.notifier).state = null;
  }

  void _showStatusFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: PurchaseOrderStatus.values.map((status) {
            return RadioListTile<PurchaseOrderStatus>(
              title: Text(status.displayName),
              subtitle: Text(status.name),
              value: status,
              groupValue: _selectedStatus,
              onChanged: (value) {
                setState(() => _selectedStatus = value);
                ref.read(purchaseOrderStatusFilterProvider.notifier).state = value;
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showSupplierFilterDialog(List<Supplier> suppliers) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Supplier'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: suppliers.length,
            itemBuilder: (context, index) {
              final supplier = suppliers[index];
              return RadioListTile<String>(
                title: Text(supplier.name),
                subtitle: Text(supplier.companyName ?? ''),
                value: supplier.id,
                groupValue: _selectedSupplierId,
                onChanged: (value) {
                  setState(() => _selectedSupplierId = value);
                  ref.read(purchaseOrderSupplierFilterProvider.notifier).state = value;
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showCreatePurchaseOrderDialog() {
    showDialog(
      context: context,
      builder: (context) => const _CreatePurchaseOrderDialog(),
    );
  }

  void _showPurchaseOrderDetails(PurchaseOrder order) {
    showDialog(
      context: context,
      builder: (context) => _PurchaseOrderDetailsDialog(purchaseOrder: order),
    );
  }

  void _showStatusChangeDialog(PurchaseOrder order) {
    showDialog(
      context: context,
      builder: (context) => _StatusChangeDialog(purchaseOrder: order),
    );
  }
}

// Purchase Order Card Widget
class _PurchaseOrderCard extends StatelessWidget {
  final PurchaseOrder purchaseOrder;
  final VoidCallback onTap;
  final VoidCallback onStatusChange;

  const _PurchaseOrderCard({
    required this.purchaseOrder,
    required this.onTap,
    required this.onStatusChange,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          purchaseOrder.orderNumber,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          purchaseOrder.supplierName ?? 'Unknown Supplier',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(purchaseOrder.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      'Order Date',
                      _formatDate(purchaseOrder.orderDate),
                      Icons.calendar_today,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoRow(
                      'Expected Delivery',
                      _formatDate(purchaseOrder.expectedDeliveryDate),
                      Icons.delivery_dining,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoRow(
                      'Total Amount',
                      '\$${purchaseOrder.totalAmount.toStringAsFixed(2)}',
                      Icons.attach_money,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${purchaseOrder.type.displayName} Order',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'status') {
                        onStatusChange();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'status',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Change Status'),
                          ],
                        ),
                      ),
                    ],
                    child: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(PurchaseOrderStatus status) {
    Color chipColor;
    switch (status) {
      case PurchaseOrderStatus.draft:
        chipColor = Colors.grey;
        break;
      case PurchaseOrderStatus.submitted:
        chipColor = Colors.orange;
        break;
      case PurchaseOrderStatus.approved:
        chipColor = Colors.blue;
        break;
      case PurchaseOrderStatus.ordered:
        chipColor = Colors.purple;
        break;
      case PurchaseOrderStatus.received:
        chipColor = Colors.green;
        break;
      case PurchaseOrderStatus.completed:
        chipColor = Colors.teal;
        break;
      case PurchaseOrderStatus.cancelled:
        chipColor = Colors.red;
        break;
      case PurchaseOrderStatus.rejected:
        chipColor = Colors.red;
        break;
    }

    return Chip(
      label: Text(
        status.displayName,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

// Create Purchase Order Dialog
class _CreatePurchaseOrderDialog extends ConsumerStatefulWidget {
  const _CreatePurchaseOrderDialog();

  @override
  ConsumerState<_CreatePurchaseOrderDialog> createState() => _CreatePurchaseOrderDialogState();
}

class _CreatePurchaseOrderDialogState extends ConsumerState<_CreatePurchaseOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _productCodeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitCostController = TextEditingController();
  final _notesController = TextEditingController();
  final _specialInstructionsController = TextEditingController();

  @override
  void dispose() {
    _productNameController.dispose();
    _productCodeController.dispose();
    _quantityController.dispose();
    _unitCostController.dispose();
    _notesController.dispose();
    _specialInstructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(purchaseOrderFormProvider);
    final suppliersAsync = ref.watch(suppliersProvider);

    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Create Purchase Order',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Supplier Selection
              suppliersAsync.when(
                data: (suppliers) => DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Supplier *',
                    border: OutlineInputBorder(),
                  ),
                  value: formState.supplierId.isEmpty ? null : formState.supplierId,
                  items: suppliers.map((supplier) {
                    return DropdownMenuItem(
                      value: supplier.id,
                      child: Text(supplier.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      final supplier = suppliers.firstWhere((s) => s.id == value);
                      ref.read(purchaseOrderFormProvider.notifier).setSupplier(
                        supplier.id,
                        supplier.name,
                      );
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a supplier';
                    }
                    return null;
                  },
                ),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Error loading suppliers'),
              ),
              const SizedBox(height: 16),

              // Order Type
              DropdownButtonFormField<PurchaseOrderType>(
                decoration: const InputDecoration(
                  labelText: 'Order Type',
                  border: OutlineInputBorder(),
                ),
                value: formState.type,
                items: PurchaseOrderType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(purchaseOrderFormProvider.notifier).setType(value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Expected Delivery Date
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    ref.read(purchaseOrderFormProvider.notifier).setExpectedDeliveryDate(date);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Expected Delivery Date *',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    formState.expectedDeliveryDate != null
                        ? '${formState.expectedDeliveryDate!.month}/${formState.expectedDeliveryDate!.day}/${formState.expectedDeliveryDate!.year}'
                        : 'Select Date',
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Items Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Order Items',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  TextButton.icon(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Item'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Items List
              if (formState.items.isNotEmpty) ...[
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: formState.items.length,
                    itemBuilder: (context, index) {
                      final item = formState.items[index];
                      return ListTile(
                        title: Text(item.productName ?? 'Unnamed Product'),
                        subtitle: Text('Qty: ${item.quantity} × \$${item.unitPrice.toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '\$${item.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              onPressed: () => ref.read(purchaseOrderFormProvider.notifier).removeItem(item.id),
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onChanged: (value) {
                  ref.read(purchaseOrderFormProvider.notifier).setNotes(value);
                },
              ),
              const SizedBox(height: 16),

              // Special Instructions
              TextFormField(
                controller: _specialInstructionsController,
                decoration: const InputDecoration(
                  labelText: 'Special Instructions',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onChanged: (value) {
                  ref.read(purchaseOrderFormProvider.notifier).setSpecialInstructions(value);
                },
              ),
              const SizedBox(height: 24),

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
                    onPressed: formState.isLoading ? null : _createPurchaseOrder,
                    child: formState.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create Order'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _productNameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _unitCostController,
                    decoration: const InputDecoration(
                      labelText: 'Unit Cost',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = int.tryParse(_quantityController.text);
              final unitCost = double.tryParse(_unitCostController.text);
              
              if (_productNameController.text.isNotEmpty && 
                  quantity != null && quantity > 0 && 
                  unitCost != null && unitCost > 0) {
                
                final item = PurchaseOrderItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  purchaseOrderId: '',
                  productId: '',
                  productName: _productNameController.text,
                  quantity: quantity,
                  unitPrice: unitCost,
                  totalPrice: quantity * unitCost,
                  productCode: _productCodeController.text,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                
                ref.read(purchaseOrderFormProvider.notifier).addItem(item);
                
                // Clear form
                _productNameController.clear();
                _quantityController.clear();
                _unitCostController.clear();
                
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _createPurchaseOrder() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(purchaseOrderFormProvider.notifier).createPurchaseOrder();
      
      if (mounted) {
        final formState = ref.read(purchaseOrderFormProvider);
        if (formState.isSuccess) {
          Navigator.pop(context);
          ref.invalidate(filteredPurchaseOrdersProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Purchase order created successfully!')),
          );
        }
      }
    }
  }
}

// Purchase Order Details Dialog
class _PurchaseOrderDetailsDialog extends ConsumerWidget {
  final PurchaseOrder purchaseOrder;

  const _PurchaseOrderDetailsDialog({required this.purchaseOrder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      child: Container(
        width: 700,
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
                        purchaseOrder.orderNumber,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        purchaseOrder.supplierName ?? 'Unknown Supplier',
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

            // Order Information
            _buildInfoSection('Order Information', [
              _buildInfoRow('Status', purchaseOrder.status.displayName),
              _buildInfoRow('Type', purchaseOrder.type.displayName),
              _buildInfoRow('Order Date', _formatDate(purchaseOrder.orderDate)),
              _buildInfoRow('Expected Delivery', _formatDate(purchaseOrder.expectedDeliveryDate)),
              if (purchaseOrder.actualDeliveryDate != null)
                _buildInfoRow('Actual Delivery', _formatDate(purchaseOrder.actualDeliveryDate!)),
            ]),
            const SizedBox(height: 16),

            // Financial Information
            _buildInfoSection('Financial Information', [
              _buildInfoRow('Total Amount', '\$${purchaseOrder.totalAmount.toStringAsFixed(2)}'),
              _buildInfoRow('Tax', '\$${purchaseOrder.taxAmount?.toStringAsFixed(2) ?? '0.00'}'),
              _buildInfoRow('Shipping', '\$${purchaseOrder.shippingAmount?.toStringAsFixed(2) ?? '0.00'}'),
              _buildInfoRow('Total', '\$${purchaseOrder.totalAmount.toStringAsFixed(2)}', isTotal: true),
            ]),
            const SizedBox(height: 16),

            // Approval Information
            if (purchaseOrder.approvedBy != null) ...[
              _buildInfoSection('Approval Information', [
                _buildInfoRow('Approved By', purchaseOrder.approvedBy!),
                _buildInfoRow('Approved At', _formatDate(purchaseOrder.approvedAt!)),
              ]),
              const SizedBox(height: 16),
            ],

            // Notes
            if (purchaseOrder.notes?.isNotEmpty == true) ...[
              _buildInfoSection('Notes', [
                _buildInfoRow('', purchaseOrder.notes!),
              ]),
              const SizedBox(height: 16),
            ],

            // Special Instructions
            if (purchaseOrder.specialInstructions?.isNotEmpty == true) ...[
              _buildInfoSection('Special Instructions', [
                _buildInfoRow('', purchaseOrder.specialInstructions!),
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

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
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
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? 16 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

// Status Change Dialog
class _StatusChangeDialog extends ConsumerStatefulWidget {
  final PurchaseOrder purchaseOrder;

  const _StatusChangeDialog({required this.purchaseOrder});

  @override
  ConsumerState<_StatusChangeDialog> createState() => _StatusChangeDialogState();
}

class _StatusChangeDialogState extends ConsumerState<_StatusChangeDialog> {
  PurchaseOrderStatus? _newStatus;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Purchase Order Status'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Current Status: ${widget.purchaseOrder.status.displayName}'),
          const SizedBox(height: 16),
          DropdownButtonFormField<PurchaseOrderStatus>(
            decoration: const InputDecoration(
              labelText: 'New Status',
              border: OutlineInputBorder(),
            ),
            value: _newStatus,
            items: PurchaseOrderStatus.values
                .where((status) => status != widget.purchaseOrder.status)
                .map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status.displayName),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _newStatus = value);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes (Optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _newStatus == null ? null : _updateStatus,
          child: const Text('Update Status'),
        ),
      ],
    );
  }

  Future<void> _updateStatus() async {
    if (_newStatus != null) {
      try {
        await ref.read(purchaseOrderServiceProvider).updatePurchaseOrderStatus(
          purchaseOrderId: widget.purchaseOrder.id,
          newStatus: _newStatus!,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
          userId: 'current_user', // TODO: Get from auth service
        );
        
        if (mounted) {
          Navigator.pop(context);
          ref.invalidate(filteredPurchaseOrdersProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Status updated to ${_newStatus!.displayName}')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating status: $e')),
          );
        }
      }
    }
  }
}
