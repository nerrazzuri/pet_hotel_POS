import 'package:cat_hotel_pos/features/inventory/domain/entities/inventory_transaction.dart';
import 'package:cat_hotel_pos/core/services/inventory_transaction_dao.dart';

class InventoryTransactionService {
  final InventoryTransactionDao _transactionDao;

  InventoryTransactionService({
    InventoryTransactionDao? transactionDao,
  }) : _transactionDao = transactionDao ?? InventoryTransactionDao();

  /// Create a new inventory transaction
  Future<InventoryTransaction?> createTransaction({
    required String productId,
    required TransactionType type,
    required int quantity,
    required double unitCost,
    String? notes,
    String? reason,
    String? location,
    String? reference,
    String? referenceType,
    String? createdBy,
  }) async {
    print('InventoryTransactionService.createTransaction: Called');
    
    try {
      final transaction = InventoryTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: productId,
        productName: 'Product $productId', // This should be fetched from product service
        productCode: 'CODE-$productId', // This should be fetched from product service
        type: type,
        quantity: quantity,
        unitCost: unitCost,
        totalCost: quantity * unitCost,
        notes: notes,
        reason: reason,
        location: location,
        reference: reference,
        referenceType: referenceType,
        createdBy: createdBy,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _transactionDao.create(transaction);
      print('InventoryTransactionService.createTransaction: Successfully created transaction');
      return transaction;
    } catch (e) {
      print('InventoryTransactionService.createTransaction: Error: $e');
      return null;
    }
  }

  /// Get all inventory transactions
  Future<List<InventoryTransaction>> getAllTransactions({
    TransactionType? type,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    print('InventoryTransactionService.getAllTransactions: Called');
    
    try {
      final transactions = await _transactionDao.getAll();
      
      // Apply filters
      var filteredTransactions = transactions;
      
      if (type != null) {
        filteredTransactions = filteredTransactions.where((t) => t.type == type).toList();
      }
      
      if (fromDate != null) {
        filteredTransactions = filteredTransactions.where((t) => t.createdAt.isAfter(fromDate)).toList();
      }
      
      if (toDate != null) {
        filteredTransactions = filteredTransactions.where((t) => t.createdAt.isBefore(toDate)).toList();
      }
      
      // Sort by creation date descending
      filteredTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      print('InventoryTransactionService.getAllTransactions: Retrieved ${filteredTransactions.length} transactions');
      return filteredTransactions;
    } catch (e) {
      print('InventoryTransactionService.getAllTransactions: Error: $e');
      return [];
    }
  }

  /// Search inventory transactions
  Future<List<InventoryTransaction>> searchTransactions(String query) async {
    print('InventoryTransactionService.searchTransactions: Called with query: "$query"');
    
    try {
      final transactions = await _transactionDao.getAll();
      final filteredTransactions = transactions.where((transaction) =>
        transaction.productName.toLowerCase().contains(query.toLowerCase()) ||
        transaction.productCode.toLowerCase().contains(query.toLowerCase()) ||
        (transaction.notes?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
        (transaction.reason?.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList();
      
      print('InventoryTransactionService.searchTransactions: Found ${filteredTransactions.length} transactions');
      return filteredTransactions;
    } catch (e) {
      print('InventoryTransactionService.searchTransactions: Error: $e');
      return [];
    }
  }

  /// Get transaction by ID
  Future<InventoryTransaction?> getTransactionById(String id) async {
    print('InventoryTransactionService.getTransactionById: Called with id: $id');
    
    try {
      final transaction = await _transactionDao.getById(id);
      print('InventoryTransactionService.getTransactionById: ${transaction != null ? "Found" : "Not found"} transaction');
      return transaction;
    } catch (e) {
      print('InventoryTransactionService.getTransactionById: Error: $e');
      return null;
    }
  }

  /// Update transaction
  Future<bool> updateTransaction(InventoryTransaction transaction) async {
    print('InventoryTransactionService.updateTransaction: Called');
    
    try {
      await _transactionDao.update(transaction);
      print('InventoryTransactionService.updateTransaction: Successfully updated transaction');
      return true;
    } catch (e) {
      print('InventoryTransactionService.updateTransaction: Error: $e');
      return false;
    }
  }

  /// Delete transaction
  Future<bool> deleteTransaction(String id) async {
    print('InventoryTransactionService.deleteTransaction: Called with id: $id');
    
    try {
      await _transactionDao.delete(id);
      print('InventoryTransactionService.deleteTransaction: Successfully deleted transaction');
      return true;
    } catch (e) {
      print('InventoryTransactionService.deleteTransaction: Error: $e');
      return false;
    }
  }

  /// Get transactions by product ID
  Future<List<InventoryTransaction>> getTransactionsByProduct(String productId) async {
    print('InventoryTransactionService.getTransactionsByProduct: Called with productId: $productId');
    
    try {
      final transactions = await _transactionDao.getAll();
      final filteredTransactions = transactions.where((t) => t.productId == productId).toList();
      
      print('InventoryTransactionService.getTransactionsByProduct: Found ${filteredTransactions.length} transactions');
      return filteredTransactions;
    } catch (e) {
      print('InventoryTransactionService.getTransactionsByProduct: Error: $e');
      return [];
    }
  }

  /// Get transactions by type
  Future<List<InventoryTransaction>> getTransactionsByType(TransactionType type) async {
    print('InventoryTransactionService.getTransactionsByType: Called with type: $type');
    
    try {
      final transactions = await _transactionDao.getAll();
      final filteredTransactions = transactions.where((t) => t.type == type).toList();
      
      print('InventoryTransactionService.getTransactionsByType: Found ${filteredTransactions.length} transactions');
      return filteredTransactions;
    } catch (e) {
      print('InventoryTransactionService.getTransactionsByType: Error: $e');
      return [];
    }
  }

  /// Get transaction summary statistics
  Future<Map<String, dynamic>> getTransactionSummary({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    print('InventoryTransactionService.getTransactionSummary: Called');
    
    try {
      final transactions = await getAllTransactions(fromDate: fromDate, toDate: toDate);
      
      final totalTransactions = transactions.length;
      final totalValue = transactions.fold(0.0, (sum, t) => sum + t.totalCost);
      final totalQuantity = transactions.fold(0, (sum, t) => sum + t.quantity);
      
      final typeBreakdown = <TransactionType, int>{};
      for (final type in TransactionType.values) {
        typeBreakdown[type] = transactions.where((t) => t.type == type).length;
      }
      
      final summary = {
        'totalTransactions': totalTransactions,
        'totalValue': totalValue,
        'totalQuantity': totalQuantity,
        'typeBreakdown': typeBreakdown,
        'averageValue': totalTransactions > 0 ? totalValue / totalTransactions : 0.0,
        'averageQuantity': totalTransactions > 0 ? totalQuantity / totalTransactions : 0,
      };
      
      print('InventoryTransactionService.getTransactionSummary: Generated summary');
      return summary;
    } catch (e) {
      print('InventoryTransactionService.getTransactionSummary: Error: $e');
      return {};
    }
  }
}
