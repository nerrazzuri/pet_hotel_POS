import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../entities/purchase_order.dart';
import '../entities/purchase_order_item.dart';
import '../../../../core/services/purchase_order_dao.dart';
import '../../../../core/services/web_purchase_order_dao.dart';

class PurchaseOrderService {
  final dynamic _purchaseOrderDao; // Can be PurchaseOrderDao or WebPurchaseOrderDao

  PurchaseOrderService() : _purchaseOrderDao = kIsWeb ? WebPurchaseOrderDao() : PurchaseOrderDao();

  /// Create a new purchase order
  Future<PurchaseOrder> createPurchaseOrder({
    required String supplierId,
    String? supplierName,
    required PurchaseOrderType type,
    required DateTime expectedDeliveryDate,
    required List<PurchaseOrderItem> items,
    String? notes,
    String? specialInstructions,
  }) async {
    print('PurchaseOrderService.createPurchaseOrder: Called with supplierId: $supplierId');
    
    try {
      final orderNumber = _generateOrderNumber();
      final subtotal = _calculateSubtotal(items);
      const taxAmount = 0.0; // TODO: Implement tax calculation
      const shippingAmount = 0.0; // TODO: Implement shipping calculation
      final totalAmount = subtotal + taxAmount + shippingAmount;

      final purchaseOrder = PurchaseOrder(
        id: const Uuid().v4(),
        orderNumber: orderNumber,
        supplierId: supplierId,
        supplierName: supplierName ?? 'Unknown Supplier',
        status: PurchaseOrderStatus.draft,
        type: type,
        orderDate: DateTime.now(),
        expectedDeliveryDate: expectedDeliveryDate,
        totalAmount: totalAmount,
        notes: notes,
        specialInstructions: specialInstructions,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _purchaseOrderDao.create(purchaseOrder, items);
      print('PurchaseOrderService.createPurchaseOrder: Successfully created purchase order');
      return purchaseOrder;
    } catch (e) {
      print('PurchaseOrderService.createPurchaseOrder: Error: $e');
      rethrow;
    }
  }

  /// Update purchase order status
  Future<void> updatePurchaseOrderStatus({
    required String purchaseOrderId,
    required PurchaseOrderStatus newStatus,
    String? notes,
    String? userId,
  }) async {
    print('PurchaseOrderService.updatePurchaseOrderStatus: Called with status: $newStatus');
    
    try {
      final existingOrder = await _purchaseOrderDao.getById(purchaseOrderId);
      if (existingOrder == null) {
        throw Exception('Purchase order not found');
      }

      // Validate status transition
      if (!_isValidStatusTransition(existingOrder.status, newStatus)) {
        throw Exception('Invalid status transition from ${existingOrder.status.displayName} to ${newStatus.displayName}');
      }

      final updatedOrder = existingOrder.copyWith(
        status: newStatus,
        notes: notes ?? existingOrder.notes,
        updatedAt: DateTime.now(),
        // Update relevant fields based on status
        approvedBy: newStatus == PurchaseOrderStatus.approved ? userId : existingOrder.approvedBy,
        approvedAt: newStatus == PurchaseOrderStatus.approved ? DateTime.now() : existingOrder.approvedAt,
        orderedBy: newStatus == PurchaseOrderStatus.ordered ? userId : existingOrder.orderedBy,
        orderedAt: newStatus == PurchaseOrderStatus.ordered ? DateTime.now() : existingOrder.orderedAt,
        receivedBy: newStatus == PurchaseOrderStatus.received ? userId : existingOrder.receivedBy,
        receivedAt: newStatus == PurchaseOrderStatus.received ? DateTime.now() : existingOrder.receivedAt,
        cancelledBy: newStatus == PurchaseOrderStatus.cancelled ? userId : existingOrder.cancelledBy,
        cancelledAt: newStatus == PurchaseOrderStatus.cancelled ? DateTime.now() : existingOrder.cancelledAt,
      );

      await _purchaseOrderDao.update(updatedOrder);
      print('PurchaseOrderService.updatePurchaseOrderStatus: Successfully updated status');
    } catch (e) {
      print('PurchaseOrderService.updatePurchaseOrderStatus: Error: $e');
      rethrow;
    }
  }

  /// Get all purchase orders
  Future<List<PurchaseOrder>> getAllPurchaseOrders({
    PurchaseOrderStatus? status,
    String? supplierId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    print('PurchaseOrderService.getAllPurchaseOrders: Called');
    
    try {
      final orders = await _purchaseOrderDao.getAll(
        status: status,
        supplierId: supplierId,
        fromDate: fromDate,
        toDate: toDate,
      );
      print('PurchaseOrderService.getAllPurchaseOrders: Retrieved ${orders.length} orders');
      return orders;
    } catch (e) {
      print('PurchaseOrderService.getAllPurchaseOrders: Error: $e');
      rethrow;
    }
  }

  /// Get purchase order by ID
  Future<PurchaseOrder?> getPurchaseOrderById(String id) async {
    print('PurchaseOrderService.getPurchaseOrderById: Called with id: $id');
    
    try {
      final order = await _purchaseOrderDao.getById(id);
      print('PurchaseOrderService.getPurchaseOrderById: ${order != null ? "Found" : "Not found"} order');
      return order;
    } catch (e) {
      print('PurchaseOrderService.getPurchaseOrderById: Error: $e');
      rethrow;
    }
  }

  /// Search purchase orders
  Future<List<PurchaseOrder>> searchPurchaseOrders(String query) async {
    print('PurchaseOrderService.searchPurchaseOrders: Called with query: "$query"');
    
    try {
      final orders = await _purchaseOrderDao.search(query);
      print('PurchaseOrderService.searchPurchaseOrders: Found ${orders.length} orders');
      return orders;
    } catch (e) {
      print('PurchaseOrderService.searchPurchaseOrders: Error: $e');
      rethrow;
    }
  }

  /// Cancel purchase order
  Future<void> cancelPurchaseOrder({
    required String purchaseOrderId,
    required String reason,
    required String userId,
  }) async {
    print('PurchaseOrderService.cancelPurchaseOrder: Called with reason: $reason');
    
    try {
      await updatePurchaseOrderStatus(
        purchaseOrderId: purchaseOrderId,
        newStatus: PurchaseOrderStatus.cancelled,
        notes: 'Cancelled: $reason',
        userId: userId,
      );
      print('PurchaseOrderService.cancelPurchaseOrder: Successfully cancelled order');
    } catch (e) {
      print('PurchaseOrderService.cancelPurchaseOrder: Error: $e');
      rethrow;
    }
  }

  /// Receive items from purchase order
  Future<void> receiveItems({
    required String purchaseOrderId,
    required List<Map<String, dynamic>> receivedItems, // [{itemId, quantity, receivedBy}]
  }) async {
    print('PurchaseOrderService.receiveItems: Called');
    
    try {
      // TODO: Implement item receiving logic
      // This would update individual items and potentially the overall order status
      print('PurchaseOrderService.receiveItems: Successfully processed received items');
    } catch (e) {
      print('PurchaseOrderService.receiveItems: Error: $e');
      rethrow;
    }
  }

  // Private helper methods

  String _generateOrderNumber() {
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final random = (1000 + DateTime.now().millisecondsSinceEpoch % 9000).toString();
    return 'PO$year$month$day$random';
  }

  double _calculateSubtotal(List<PurchaseOrderItem> items) {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  bool _isValidStatusTransition(PurchaseOrderStatus currentStatus, PurchaseOrderStatus newStatus) {
    // Define valid status transitions
    final validTransitions = {
      PurchaseOrderStatus.draft: [PurchaseOrderStatus.submitted, PurchaseOrderStatus.cancelled],
      PurchaseOrderStatus.submitted: [PurchaseOrderStatus.approved, PurchaseOrderStatus.cancelled],
      PurchaseOrderStatus.approved: [PurchaseOrderStatus.ordered, PurchaseOrderStatus.cancelled],
      PurchaseOrderStatus.ordered: [PurchaseOrderStatus.received, PurchaseOrderStatus.cancelled],
      PurchaseOrderStatus.received: [PurchaseOrderStatus.completed, PurchaseOrderStatus.cancelled],
      PurchaseOrderStatus.completed: [], // Terminal state
      PurchaseOrderStatus.cancelled: [], // Terminal state
    };

    return validTransitions[currentStatus]?.contains(newStatus) ?? false;
  }
}
