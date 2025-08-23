import 'package:freezed_annotation/freezed_annotation.dart';

part 'inventory_transaction.freezed.dart';
part 'inventory_transaction.g.dart';

enum TransactionType {
  purchase,
  sale,
  adjustment,
  transfer,
  returnItem,
  damage,
  expiry,
  initial,
  count
}

@freezed
class InventoryTransaction with _$InventoryTransaction {
  const factory InventoryTransaction({
    required String id,
    required String productId,
    required String productName,
    required String productCode,
    required TransactionType type,
    required int quantity,
    required double unitCost,
    required double totalCost,
    required DateTime createdAt,
    required DateTime updatedAt,
    
    // Transaction Details
    String? reference,
    String? referenceType,
    String? notes,
    String? reason,
    
    // Location Information
    String? fromLocation,
    String? toLocation,
    String? location,
    
    // User Information
    String? createdBy,
    String? approvedBy,
    DateTime? approvedAt,
    
    // Additional Information
    String? batchNumber,
    DateTime? expiryDate,
    Map<String, dynamic>? metadata,
  }) = _InventoryTransaction;

  factory InventoryTransaction.fromJson(Map<String, dynamic> json) => _$InventoryTransactionFromJson(json);
}

// Extension for display names
extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.purchase:
        return 'Purchase';
      case TransactionType.sale:
        return 'Sale';
      case TransactionType.adjustment:
        return 'Adjustment';
      case TransactionType.transfer:
        return 'Transfer';
      case TransactionType.returnItem:
        return 'Return';
      case TransactionType.damage:
        return 'Damage';
      case TransactionType.expiry:
        return 'Expiry';
      case TransactionType.initial:
        return 'Initial';
      case TransactionType.count:
        return 'Count';
    }
  }
}
