import 'package:freezed_annotation/freezed_annotation.dart';

part 'deposit.freezed.dart';
part 'deposit.g.dart';

enum DepositType {
  advance,        // Advance payment for services
  security,       // Security deposit for rooms/equipment
  preAuth,        // Pre-authorization hold on card
  giftCard,       // Gift card purchase
  storeCredit,    // Store credit for future use
}

enum DepositStatus {
  pending,        // Payment initiated but not confirmed
  confirmed,      // Payment confirmed and available
  applied,        // Applied to a transaction
  refunded,       // Refunded to customer
  expired,        // Expired (for pre-authorizations)
  cancelled,      // Cancelled before confirmation
}

@freezed
class Deposit with _$Deposit {
  const factory Deposit({
    required String id,
    required String customerId,
    required String customerName,
    required String customerPhone,
    required DepositType type,
    required DepositStatus status,
    required double amount,
    required String paymentMethod,
    required DateTime createdAt,
    String? description,
    String? reference, // External reference (card auth code, etc.)
    DateTime? confirmedAt,
    DateTime? appliedAt,
    DateTime? refundedAt,
    DateTime? expiredAt,
    DateTime? cancelledAt,
    String? appliedToTransactionId, // Transaction where deposit was applied
    String? refundReason,
    String? cancelledReason,
    String? processedBy, // Staff member who processed
    Map<String, dynamic>? metadata,
  }) = _Deposit;

  factory Deposit.fromJson(Map<String, dynamic> json) => _$DepositFromJson(json);
}

@freezed
class DepositApplication with _$DepositApplication {
  const factory DepositApplication({
    required String id,
    required String depositId,
    required String transactionId,
    required double amountApplied,
    required DateTime appliedAt,
    required String appliedBy,
    String? notes,
    Map<String, dynamic>? metadata,
  }) = _DepositApplication;

  factory DepositApplication.fromJson(Map<String, dynamic> json) => _$DepositApplicationFromJson(json);
}
