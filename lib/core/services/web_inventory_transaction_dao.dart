import 'web_storage_service.dart';
import 'base_dao.dart';

// Mock InventoryTransaction class for web compatibility
class InventoryTransaction {
  final String id;
  final String productId;
  final String productName;
  final String type;
  final int quantity;
  final DateTime createdAt;
  final String? notes;

  InventoryTransaction({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.createdAt,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'productName': productName,
    'type': type,
    'quantity': quantity,
    'createdAt': createdAt.toIso8601String(),
    'notes': notes,
  };

  factory InventoryTransaction.fromJson(Map<String, dynamic> json) {
    return InventoryTransaction(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      type: json['type'] as String,
      quantity: json['quantity'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      notes: json['notes'] as String?,
    );
  }
}

class WebInventoryTransactionDao implements BaseInventoryTransactionDao {
  static const String _key = 'inventory_transactions';

  @override
  Future<dynamic> create(dynamic entity) async {
    final transaction = entity as InventoryTransaction;
    final transactions = await getAll();
    transactions.add(transaction);
    WebStorageService.saveData(_key, transactions.map((t) => t.toJson()).toList());
    return transaction;
  }

  @override
  Future<dynamic> update(dynamic entity) async {
    final transaction = entity as InventoryTransaction;
    final transactions = await getAll();
    final index = transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      transactions[index] = transaction;
      WebStorageService.saveData(_key, transactions.map((t) => t.toJson()).toList());
    }
    return transaction;
  }

  @override
  Future<void> delete(String id) async {
    final transactions = await getAll();
    transactions.removeWhere((t) => t.id == id);
    WebStorageService.saveData(_key, transactions.map((t) => t.toJson()).toList());
  }

  @override
  Future<dynamic?> getById(String id) async {
    final transactions = await getAll();
    try {
      return transactions.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<InventoryTransaction>> getAll() async {
    final data = WebStorageService.getData(_key);
    return data.map((item) => InventoryTransaction(
      id: item['id'] ?? '',
      productId: item['productId'] ?? '',
      productName: item['productName'] ?? '',
      type: item['type'] ?? '',
      quantity: item['quantity'] ?? 0,
      createdAt: DateTime.tryParse(item['createdAt'] ?? '') ?? DateTime.now(),
      notes: item['notes'],
    )).toList();
  }

  @override
  Future<List<InventoryTransaction>> search(String query) async {
    final allData = WebStorageService.getData(_key);
    final filteredData = allData.where((item) {
      final searchableText = '${item['productName']} ${item['type']} ${item['notes']}'.toLowerCase();
      return searchableText.contains(query.toLowerCase());
    }).toList();
    
    return filteredData.map((item) => InventoryTransaction(
      id: item['id'] ?? '',
      productId: item['productId'] ?? '',
      productName: item['productName'] ?? '',
      type: item['type'] ?? '',
      quantity: item['quantity'] ?? 0,
      createdAt: DateTime.tryParse(item['createdAt'] ?? '') ?? DateTime.now(),
      notes: item['notes'],
    )).toList();
  }

  @override
  Future<List<InventoryTransaction>> getByProductId(String productId) async {
    final data = WebStorageService.getData(_key);
    final filteredData = data.where((item) => item['productId'] == productId).toList();
    
    return filteredData.map((item) => InventoryTransaction(
      id: item['id'] ?? '',
      productId: item['productId'] ?? '',
      productName: item['productName'] ?? '',
      type: item['type'] ?? '',
      quantity: item['quantity'] ?? 0,
      createdAt: DateTime.tryParse(item['createdAt'] ?? '') ?? DateTime.now(),
      notes: item['notes'],
    )).toList();
  }

  @override
  Future<List<InventoryTransaction>> getByType(String type) async {
    final data = WebStorageService.getData(_key);
    final filteredData = data.where((item) => item['type'] == type).toList();
    
    return filteredData.map((item) => InventoryTransaction(
      id: item['id'] ?? '',
      productId: item['productId'] ?? '',
      productName: item['productName'] ?? '',
      type: item['type'] ?? '',
      quantity: item['quantity'] ?? 0,
      createdAt: DateTime.tryParse(item['createdAt'] ?? '') ?? DateTime.now(),
      notes: item['notes'],
    )).toList();
  }

  @override
  Future<List<InventoryTransaction>> getByDateRange(DateTime startDate, DateTime endDate) async {
    final data = WebStorageService.getData(_key);
    final filteredData = data.where((item) {
      final itemDate = DateTime.tryParse(item['createdAt'] ?? '') ?? DateTime.now();
      return itemDate.isAfter(startDate) && itemDate.isBefore(endDate);
    }).toList();
    
    return filteredData.map((item) => InventoryTransaction(
      id: item['id'] ?? '',
      productId: item['productId'] ?? '',
      productName: item['productName'] ?? '',
      type: item['type'] ?? '',
      quantity: item['quantity'] ?? 0,
      createdAt: DateTime.tryParse(item['createdAt'] ?? '') ?? DateTime.now(),
      notes: item['notes'],
    )).toList();
  }
}
