import 'package:cat_hotel_pos/features/inventory/domain/entities/purchase_order.dart';
import 'package:cat_hotel_pos/features/inventory/domain/entities/purchase_order_item.dart';
import 'web_storage_service.dart';

class WebPurchaseOrderDao {
  // TODO: Uncomment when implementing these storage keys
  // static const String _purchaseOrdersKey = 'purchase_orders';
  // static const String _purchaseOrderItemsKey = 'purchase_order_items';

  /// Create a new purchase order with items
  Future<void> create(PurchaseOrder purchaseOrder, List<PurchaseOrderItem> items) async {
    print('WebPurchaseOrderDao.create: Called with order: ${purchaseOrder.orderNumber}');
    
    try {
      // Save purchase order
      final orders = WebStorageService.getAllPurchaseOrders();
      orders.add(purchaseOrder.toJson());
      WebStorageService.savePurchaseOrders(orders);
      
      // Save purchase order items
      final allItems = WebStorageService.getAllPurchaseOrderItems();
      for (final item in items) {
        final itemWithOrderId = item.copyWith(purchaseOrderId: purchaseOrder.id);
        allItems.add(itemWithOrderId.toJson());
      }
      WebStorageService.savePurchaseOrderItems(allItems);
      
      print('WebPurchaseOrderDao.create: Successfully saved purchase order and items');
    } catch (e) {
      print('WebPurchaseOrderDao.create: Error: $e');
      rethrow;
    }
  }

  /// Update an existing purchase order
  Future<void> update(PurchaseOrder purchaseOrder) async {
    print('WebPurchaseOrderDao.update: Called with order: ${purchaseOrder.orderNumber}');
    
    try {
      final orders = WebStorageService.getAllPurchaseOrders();
      final existingIndex = orders.indexWhere((o) => o['id'] == purchaseOrder.id);
      
      if (existingIndex >= 0) {
        orders[existingIndex] = purchaseOrder.toJson();
        WebStorageService.savePurchaseOrders(orders);
        print('WebPurchaseOrderDao.update: Successfully updated purchase order');
      } else {
        throw Exception('Purchase order not found');
      }
    } catch (e) {
      print('WebPurchaseOrderDao.update: Error: $e');
      rethrow;
    }
  }

  /// Get all purchase orders with optional filters
  Future<List<PurchaseOrder>> getAll({
    PurchaseOrderStatus? status,
    String? supplierId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    print('WebPurchaseOrderDao.getAll: Called');
    
    try {
      final orderData = WebStorageService.getAllPurchaseOrders();
      final orders = orderData.map((data) => PurchaseOrder.fromJson(data)).toList();
      
      // Apply filters
      var filteredOrders = orders.where((order) => order.isActive).toList();
      
      if (status != null) {
        filteredOrders = filteredOrders.where((order) => order.status == status).toList();
      }
      
      if (supplierId != null) {
        filteredOrders = filteredOrders.where((order) => order.supplierId == supplierId).toList();
      }
      
      if (fromDate != null) {
        filteredOrders = filteredOrders.where((order) => order.orderDate.isAfter(fromDate)).toList();
      }
      
      if (toDate != null) {
        filteredOrders = filteredOrders.where((order) => order.orderDate.isBefore(toDate)).toList();
      }
      
      // Sort by order date descending
      filteredOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      
      print('WebPurchaseOrderDao.getAll: Retrieved ${filteredOrders.length} orders');
      return filteredOrders;
    } catch (e) {
      print('WebPurchaseOrderDao.getAll: Error: $e');
      return [];
    }
  }

  /// Get purchase order by ID
  Future<PurchaseOrder?> getById(String id) async {
    print('WebPurchaseOrderDao.getById: Called with id: $id');
    
    try {
      final orderData = WebStorageService.getAllPurchaseOrders();
      final orderMap = orderData.firstWhere((data) => data['id'] == id, orElse: () => {});
      
      if (orderMap.isNotEmpty) {
        print('WebPurchaseOrderDao.getById: Found order: ${orderMap['orderNumber']}');
        return PurchaseOrder.fromJson(orderMap);
      }
      
      print('WebPurchaseOrderDao.getById: Order not found for id: $id');
      return null;
    } catch (e) {
      print('WebPurchaseOrderDao.getById: Error: $e');
      return null;
    }
  }

  /// Search purchase orders
  Future<List<PurchaseOrder>> search(String query) async {
    print('WebPurchaseOrderDao.search: Called with query: "$query"');
    
    try {
      final orderData = WebStorageService.getAllPurchaseOrders();
      final orders = orderData.map((data) => PurchaseOrder.fromJson(data)).toList();
      
      final filtered = orders.where((order) {
        final lowerCaseQuery = query.toLowerCase();
        return order.orderNumber.toLowerCase().contains(lowerCaseQuery) ||
               (order.supplierName?.toLowerCase().contains(lowerCaseQuery) ?? false) ||
               (order.notes?.toLowerCase().contains(lowerCaseQuery) ?? false);
      }).toList();
      
      // Sort by order date descending
      filtered.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      
      print('WebPurchaseOrderDao.search: Found ${filtered.length} matching orders');
      return filtered;
    } catch (e) {
      print('WebPurchaseOrderDao.search: Error: $e');
      return [];
    }
  }

  /// Get purchase order items
  Future<List<PurchaseOrderItem>> getItems(String purchaseOrderId) async {
    print('WebPurchaseOrderDao.getItems: Called with orderId: $purchaseOrderId');
    
    try {
      final itemData = WebStorageService.getAllPurchaseOrderItems();
      final items = itemData
          .where((data) => data['purchaseOrderId'] == purchaseOrderId && data['isActive'] == true)
          .map((data) => PurchaseOrderItem.fromJson(data))
          .toList();
      
      // Sort by creation date ascending
      items.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      
      print('WebPurchaseOrderDao.getItems: Retrieved ${items.length} items');
      return items;
    } catch (e) {
      print('WebPurchaseOrderDao.getItems: Error: $e');
      return [];
    }
  }
}
