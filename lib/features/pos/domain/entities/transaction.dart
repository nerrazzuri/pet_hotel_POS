import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/payment.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required TransactionType type,
    required double amount,
    required PaymentMethod paymentMethod,
    required TransactionStatus status,
    required String customerName,
    required List<TransactionItem> items,
    required double subtotal,
    required double tax,
    required double discount,
    required double total,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
}

@freezed
class TransactionItem with _$TransactionItem {
  const factory TransactionItem({
    required String id,
    required String name,
    required int quantity,
    required double unitPrice,
    required double totalPrice,
    String? category,
    String? notes,
  }) = _TransactionItem;

  factory TransactionItem.fromJson(Map<String, dynamic> json) => _$TransactionItemFromJson(json);
}

enum TransactionType {
  sale,
  refund,
  voidTransaction,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
}
