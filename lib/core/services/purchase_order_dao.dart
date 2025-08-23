// Functional Purchase Order DAO for Android compatibility
// Provides in-memory storage with sample data

import 'package:cat_hotel_pos/features/inventory/domain/entities/purchase_order.dart';
import 'package:cat_hotel_pos/features/inventory/domain/entities/purchase_order_item.dart';

class PurchaseOrderDao {
  static final Map<String, PurchaseOrder> _purchaseOrders = {};
  static final Map<String, List<PurchaseOrderItem>> _orderItems = {};
  static bool _initialized = false;

  static void _initialize() {
    if (_initialized) return;
    
    // Create sample purchase orders
    _purchaseOrders['po_001'] = PurchaseOrder(
      id: 'po_001',
      orderNumber: 'PO-2024-001',
      supplierId: 'supp_001',
      supplierName: 'Pet Food Plus Co.',
      status: PurchaseOrderStatus.submitted,
      type: PurchaseOrderType.regular,
      orderDate: DateTime.now().subtract(const Duration(days: 5)),
      expectedDeliveryDate: DateTime.now().add(const Duration(days: 7)),
      totalAmount: 1260.00,
      notes: 'Monthly food supply order',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _purchaseOrders['po_002'] = PurchaseOrder(
      id: 'po_002',
      orderNumber: 'PO-2024-002',
      supplierId: 'supp_002',
      supplierName: 'Cat Care Supplies Ltd.',
      status: PurchaseOrderStatus.approved,
      type: PurchaseOrderType.regular,
      orderDate: DateTime.now().subtract(const Duration(days: 3)),
      expectedDeliveryDate: DateTime.now().add(const Duration(days: 5)),
      totalAmount: 892.50,
      notes: 'New toy collection and accessories',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _purchaseOrders['po_003'] = PurchaseOrder(
      id: 'po_003',
      orderNumber: 'PO-2024-003',
      supplierId: 'supp_003',
      supplierName: 'Premium Pet Products',
      status: PurchaseOrderStatus.completed,
      type: PurchaseOrderType.regular,
      orderDate: DateTime.now().subtract(const Duration(days: 10)),
      expectedDeliveryDate: DateTime.now().subtract(const Duration(days: 2)),
      actualDeliveryDate: DateTime.now().subtract(const Duration(days: 2)),
      totalAmount: 682.50,
      notes: 'Grooming supplies and health products',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _purchaseOrders['po_004'] = PurchaseOrder(
      id: 'po_004',
      orderNumber: 'PO-2024-004',
      supplierId: 'supp_004',
      supplierName: 'Wholesale Pet Mart',
      status: PurchaseOrderStatus.submitted,
      type: PurchaseOrderType.bulk,
      orderDate: DateTime.now().subtract(const Duration(days: 15)),
      expectedDeliveryDate: DateTime.now().add(const Duration(days: 3)),
      totalAmount: 2100.00,
      notes: 'Bulk supplies for peak season',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _purchaseOrders['po_005'] = PurchaseOrder(
      id: 'po_005',
      orderNumber: 'PO-2024-005',
      supplierId: 'supp_005',
      supplierName: 'Eco Pet Solutions',
      status: PurchaseOrderStatus.draft,
      type: PurchaseOrderType.regular,
      orderDate: DateTime.now().subtract(const Duration(days: 1)),
      expectedDeliveryDate: DateTime.now().add(const Duration(days: 10)),
      totalAmount: 462.00,
      notes: 'Eco-friendly products trial order',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Create sample order items
    _orderItems['po_001'] = [
      PurchaseOrderItem(
        id: 'item_001',
        purchaseOrderId: 'po_001',
        productId: 'prod_001',
        productName: 'Premium Cat Food',
        productCode: 'FOOD-001',
        quantity: 25,
        unitPrice: 28.50,
        totalPrice: 712.50,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PurchaseOrderItem(
        id: 'item_002',
        purchaseOrderId: 'po_001',
        productId: 'prod_004',
        productName: 'Cat Grooming Brush',
        productCode: 'GROOM-001',
        quantity: 15,
        unitPrice: 9.25,
        totalPrice: 138.75,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    _orderItems['po_002'] = [
      PurchaseOrderItem(
        id: 'item_003',
        purchaseOrderId: 'po_002',
        productId: 'prod_003',
        productName: 'Cat Toy Set',
        productCode: 'TOY-001',
        quantity: 20,
        unitPrice: 12.50,
        totalPrice: 250.00,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PurchaseOrderItem(
        id: 'item_004',
        purchaseOrderId: 'po_002',
        productId: 'prod_005',
        productName: 'Cat Carrier Deluxe',
        productCode: 'ACC-001',
        quantity: 5,
        unitPrice: 55.00,
        totalPrice: 275.00,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    _orderItems['po_003'] = [
      PurchaseOrderItem(
        id: 'item_005',
        purchaseOrderId: 'po_003',
        productId: 'prod_004',
        productName: 'Cat Grooming Brush',
        productCode: 'GROOM-001',
        quantity: 10,
        unitPrice: 9.25,
        totalPrice: 92.50,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    _orderItems['po_004'] = [
      PurchaseOrderItem(
        id: 'item_006',
        purchaseOrderId: 'po_004',
        productId: 'prod_002',
        productName: 'Cat Litter Premium',
        productCode: 'LITTER-001',
        quantity: 30,
        unitPrice: 18.75,
        totalPrice: 562.50,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PurchaseOrderItem(
        id: 'item_007',
        purchaseOrderId: 'po_004',
        productId: 'prod_003',
        productName: 'Cat Toy Set',
        productCode: 'TOY-001',
        quantity: 50,
        unitPrice: 12.50,
        totalPrice: 625.00,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    _orderItems['po_005'] = [
      PurchaseOrderItem(
        id: 'item_008',
        purchaseOrderId: 'po_005',
        productId: 'prod_006',
        productName: 'Eco Cat Bowl',
        productCode: 'BOWL-001',
        quantity: 20,
        unitPrice: 15.00,
        totalPrice: 300.00,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    _initialized = true;
  }

  Future<void> insert(PurchaseOrder purchaseOrder) async {
    _initialize();
    _purchaseOrders[purchaseOrder.id] = purchaseOrder;
  }

  Future<PurchaseOrder?> getById(String id) async {
    _initialize();
    return _purchaseOrders[id];
  }

  Future<List<PurchaseOrder>> getAll() async {
    _initialize();
    return _purchaseOrders.values.toList();
  }

  Future<List<PurchaseOrder>> getBySupplierId(String supplierId) async {
    _initialize();
    return _purchaseOrders.values.where((order) => order.supplierId == supplierId).toList();
  }

  Future<List<PurchaseOrder>> getByStatus(PurchaseOrderStatus status) async {
    _initialize();
    return _purchaseOrders.values.where((order) => order.status == status).toList();
  }

  Future<List<PurchaseOrder>> getByDateRange(DateTime startDate, DateTime endDate) async {
    _initialize();
    return _purchaseOrders.values.where((order) => 
      order.orderDate.isAfter(startDate) && order.orderDate.isBefore(endDate)
    ).toList();
  }

  Future<PurchaseOrder> update(PurchaseOrder purchaseOrder) async {
    _initialize();
    _purchaseOrders[purchaseOrder.id] = purchaseOrder;
    return purchaseOrder;
  }

  Future<void> delete(String id) async {
    _initialize();
    _purchaseOrders.remove(id);
    _orderItems.remove(id);
  }

  Future<List<PurchaseOrder>> search(String query) async {
    _initialize();
    if (query.trim().isEmpty) return _purchaseOrders.values.toList();
    
    final lowercaseQuery = query.toLowerCase();
    return _purchaseOrders.values.where((order) =>
      order.orderNumber.toLowerCase().contains(lowercaseQuery) ||
      (order.supplierName?.toLowerCase().contains(lowercaseQuery) ?? false) ||
      (order.notes?.toLowerCase().contains(lowercaseQuery) ?? false)
    ).toList();
  }

  Future<List<PurchaseOrderItem>> getItemsByOrderId(String orderId) async {
    _initialize();
    return _orderItems[orderId] ?? [];
  }

  Future<void> insertItem(PurchaseOrderItem item) async {
    _initialize();
    if (_orderItems[item.purchaseOrderId] == null) {
      _orderItems[item.purchaseOrderId] = [];
    }
    _orderItems[item.purchaseOrderId]!.add(item);
  }

  Future<void> updateItem(PurchaseOrderItem item) async {
    _initialize();
    final items = _orderItems[item.purchaseOrderId];
    if (items != null) {
      final index = items.indexWhere((i) => i.id == item.id);
      if (index >= 0) {
        items[index] = item;
      }
    }
  }

  Future<void> deleteItem(String itemId) async {
    _initialize();
    for (final items in _orderItems.values) {
      items.removeWhere((item) => item.id == itemId);
    }
  }

  Future<int> getTotalOrders() async {
    _initialize();
    return _purchaseOrders.length;
  }

  Future<double> getTotalOrderValue() async {
    _initialize();
    double total = 0.0;
    for (final order in _purchaseOrders.values) {
      total += order.totalAmount;
    }
    return total;
  }

  Future<Map<String, int>> getOrdersByStatus() async {
    _initialize();
    final result = <String, int>{};
    for (final order in _purchaseOrders.values) {
      final status = order.status.name;
      result[status] = (result[status] ?? 0) + 1;
    }
    return result;
  }

  Future<Map<String, double>> getOrdersByMonth() async {
    _initialize();
    final result = <String, double>{};
    for (final order in _purchaseOrders.values) {
      final month = '${order.orderDate.year}-${order.orderDate.month.toString().padLeft(2, '0')}';
      result[month] = (result[month] ?? 0.0) + order.totalAmount;
    }
    return result;
  }
}
