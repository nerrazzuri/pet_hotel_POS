// Functional Inventory Transaction DAO for Android compatibility
// Provides in-memory storage with sample data

import 'package:cat_hotel_pos/features/inventory/domain/entities/inventory_transaction.dart';

class InventoryTransactionDao {
  static final Map<String, InventoryTransaction> _transactions = {};
  static bool _initialized = false;

  static void _initialize() {
    if (_initialized) return;
    
    // Create sample inventory transactions
    _transactions['trans_001'] = InventoryTransaction(
      id: 'trans_001',
      productId: 'prod_001',
      productName: 'Premium Cat Food',
      productCode: 'FOOD-001',
      type: TransactionType.purchase,
      quantity: 25,
      unitCost: 28.50,
      totalCost: 712.50,
      reference: 'PO-2024-001',
      referenceType: 'purchase_order',
      notes: 'Monthly food supply purchase',
      createdBy: 'manager',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _transactions['trans_002'] = InventoryTransaction(
      id: 'trans_002',
      productId: 'prod_002',
      productName: 'Cat Litter Premium',
      productCode: 'LITTER-001',
      type: TransactionType.purchase,
      quantity: 20,
      unitCost: 18.75,
      totalCost: 375.00,
      reference: 'PO-2024-002',
      referenceType: 'purchase_order',
      notes: 'Litter supply purchase',
      createdBy: 'manager',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _transactions['trans_003'] = InventoryTransaction(
      id: 'trans_003',
      productId: 'prod_001',
      productName: 'Premium Cat Food',
      productCode: 'FOOD-001',
      type: TransactionType.sale,
      quantity: -5,
      unitCost: 45.99,
      totalCost: -229.95,
      reference: 'SALE-2024-001',
      referenceType: 'sale',
      notes: 'Retail sale to customer',
      createdBy: 'staff',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _transactions['trans_004'] = InventoryTransaction(
      id: 'trans_004',
      productId: 'prod_003',
      productName: 'Cat Toy Set',
      productCode: 'TOY-001',
      type: TransactionType.adjustment,
      quantity: 2,
      unitCost: 12.50,
      totalCost: 25.00,
      reference: 'ADJ-2024-001',
      referenceType: 'adjustment',
      notes: 'Found additional stock in warehouse',
      createdBy: 'manager',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _transactions['trans_005'] = InventoryTransaction(
      id: 'trans_005',
      productId: 'prod_004',
      productName: 'Cat Grooming Brush',
      productCode: 'GROOM-001',
      type: TransactionType.transfer,
      quantity: -3,
      unitCost: 18.99,
      totalCost: -56.97,
      reference: 'TRF-2024-001',
      referenceType: 'transfer',
      notes: 'Transferred to branch location',
      createdBy: 'manager',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _initialized = true;
  }

  Future<List<InventoryTransaction>> getAll() async {
    _initialize();
    return _transactions.values.toList();
  }

  Future<InventoryTransaction?> getById(String id) async {
    _initialize();
    return _transactions[id];
  }

  Future<InventoryTransaction> create(InventoryTransaction transaction) async {
    _initialize();
    _transactions[transaction.id] = transaction;
    return transaction;
  }

  Future<InventoryTransaction> update(InventoryTransaction transaction) async {
    _initialize();
    if (_transactions.containsKey(transaction.id)) {
      _transactions[transaction.id] = transaction;
      return transaction;
    } else {
      throw Exception('Transaction not found');
    }
  }

  Future<void> delete(String id) async {
    _initialize();
    if (_transactions.containsKey(id)) {
      _transactions.remove(id);
    } else {
      throw Exception('Transaction not found');
    }
  }

  Future<List<InventoryTransaction>> getByProductId(String productId) async {
    _initialize();
    return _transactions.values.where((transaction) => 
      transaction.productId == productId
    ).toList();
  }

  Future<List<InventoryTransaction>> getByDateRange(DateTime startDate, DateTime endDate) async {
    _initialize();
    return _transactions.values.where((transaction) => 
      transaction.createdAt.isAfter(startDate) && 
      transaction.createdAt.isBefore(endDate)
    ).toList();
  }

  Future<List<InventoryTransaction>> getByType(TransactionType type) async {
    _initialize();
    return _transactions.values.where((transaction) => 
      transaction.type == type
    ).toList();
  }

  Future<double> getTotalValueByType(TransactionType type) async {
    _initialize();
    double total = 0.0;
    for (final transaction in _transactions.values) {
      if (transaction.type == type) {
        total += transaction.totalCost;
      }
    }
    return total;
  }

  Future<Map<String, int>> getTransactionsByType() async {
    _initialize();
    final result = <String, int>{};
    for (final transaction in _transactions.values) {
      final type = transaction.type.name;
      result[type] = (result[type] ?? 0) + 1;
    }
    return result;
  }
}
