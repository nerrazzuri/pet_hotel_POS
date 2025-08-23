import 'package:freezed_annotation/freezed_annotation.dart';

part 'loyalty_transaction.freezed.dart';
part 'loyalty_transaction.g.dart';

enum LoyaltyTransactionType {
  earned,
  redeemed,
  expired,
  adjusted,
  bonus,
}

enum LoyaltyTransactionStatus {
  pending,
  completed,
  cancelled,
  failed,
}

@freezed
class LoyaltyTransaction with _$LoyaltyTransaction {
  const factory LoyaltyTransaction({
    required String id,
    required String customerId,
    required LoyaltyTransactionType type,
    required LoyaltyTransactionStatus status,
    required int points,
    required String description,
    required String? referenceId,
    required String? referenceType,
    required DateTime createdAt,
    required DateTime? processedAt,
    required DateTime? expiresAt,
    required String? notes,
  }) = _LoyaltyTransaction;

  factory LoyaltyTransaction.fromJson(Map<String, dynamic> json) =>
      _$LoyaltyTransactionFromJson(json);
}
