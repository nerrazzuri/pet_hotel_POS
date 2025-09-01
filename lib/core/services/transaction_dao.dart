import 'package:cat_hotel_pos/features/pos/domain/entities/transaction.dart';
import 'package:cat_hotel_pos/core/services/web_storage_service.dart';

class TransactionDao {
  static const String _collectionName = 'transactions';

  TransactionDao();

  Future<List<Transaction>> getAll() async {
    try {
      final data = WebStorageService.getData(_collectionName);
      return data.map((json) => Transaction.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Transaction?> getById(String id) async {
    try {
      final data = WebStorageService.getData(_collectionName);
      final transactionData = data.firstWhere(
        (item) => item['id'] == id,
        orElse: () => <String, dynamic>{},
      );
      if (transactionData.isNotEmpty) {
        return Transaction.fromJson(transactionData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> create(Transaction transaction) async {
    final existingData = WebStorageService.getData(_collectionName);
    existingData.add(transaction.toJson());
    WebStorageService.saveData(_collectionName, existingData);
  }

  Future<void> update(Transaction transaction) async {
    final existingData = WebStorageService.getData(_collectionName);
    final index = existingData.indexWhere((item) => item['id'] == transaction.id);
    if (index >= 0) {
      existingData[index] = transaction.toJson();
      WebStorageService.saveData(_collectionName, existingData);
    }
  }

  Future<void> delete(String id) async {
    final existingData = WebStorageService.getData(_collectionName);
    existingData.removeWhere((item) => item['id'] == id);
    WebStorageService.saveData(_collectionName, existingData);
  }

  Future<List<Transaction>> getTransactionsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final allTransactions = await getAll();
      return allTransactions.where((transaction) => 
        transaction.createdAt.isAfter(startDate) && 
        transaction.createdAt.isBefore(endDate)
      ).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Transaction>> getTransactionsByCustomer(String customerName) async {
    try {
      final allTransactions = await getAll();
      return allTransactions.where((transaction) => 
        transaction.customerName.toLowerCase().contains(customerName.toLowerCase())
      ).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Transaction>> getTransactionsByType(TransactionType type) async {
    try {
      final allTransactions = await getAll();
      return allTransactions.where((transaction) => transaction.type == type).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Transaction>> getTransactionsByStatus(TransactionStatus status) async {
    try {
      final allTransactions = await getAll();
      return allTransactions.where((transaction) => transaction.status == status).toList();
    } catch (e) {
      return [];
    }
  }

  Future<double> getTotalSalesByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final transactions = await getTransactionsByDateRange(startDate, endDate);
      return transactions
          .where((transaction) => transaction.type == TransactionType.sale)
          .fold<double>(0.0, (sum, transaction) => sum + transaction.total);
    } catch (e) {
      return 0.0;
    }
  }

  Future<double> getTotalRefundsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final transactions = await getTransactionsByDateRange(startDate, endDate);
      return transactions
          .where((transaction) => transaction.type == TransactionType.refund)
          .fold<double>(0.0, (sum, transaction) => sum + transaction.total);
    } catch (e) {
      return 0.0;
    }
  }
}
