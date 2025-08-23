import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cat_hotel_pos/features/payments/domain/entities/payment_method.dart';

part 'payment_transaction.freezed.dart';
part 'payment_transaction.g.dart';

enum TransactionType {
  sale,
  refund,
  partialRefund,
  deposit,
  withdrawal,
  adjustment,
  tip,
  serviceCharge,
}

@freezed
class PaymentTransaction with _$PaymentTransaction {
  const factory PaymentTransaction({
    required String id,
    required String transactionId,
    required TransactionType type,
    required double amount,
    required PaymentMethod paymentMethod,
    required PaymentStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? customerId,
    String? customerName,
    String? orderId,
    String? invoiceId,
    String? receiptId,
    String? referenceNumber,
    String? authorizationCode,
    String? transactionReference,
    String? cardType,
    String? cardLast4,
    Map<String, dynamic>? metadata,
    String? notes,
    String? errorMessage,
    DateTime? processedAt,
    DateTime? completedAt,
    String? processedBy,
    String? approvedBy,
    double? processingFee,
    double? taxAmount,
    double? tipAmount,
    double? serviceChargeAmount,
    String? currency,
    double? exchangeRate,
    bool? isVoided,
    DateTime? voidedAt,
    String? voidedBy,
    String? voidReason,
  }) = _PaymentTransaction;

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) =>
      _$PaymentTransactionFromJson(json);
}
