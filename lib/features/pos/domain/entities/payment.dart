import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment.freezed.dart';
part 'payment.g.dart';

@freezed
class Payment with _$Payment {
  const factory Payment({
    required String id,
    required String bookingId,
    required double amount,
    required PaymentMethod paymentMethod,
    required PaymentStatus status,
    PaymentType? paymentType,
    required String customerName,
    String? notes,
    String? processedBy,
    required DateTime processedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);
}

enum PaymentMethod {
  cash,
  card,
  bankTransfer,
  eWallet,
  refund,
}

enum PaymentStatus {
  pending,
  completed,
  failed,
  cancelled,
}

enum PaymentType {
  full,
  deposit,
  balance,
  refund,
}
