import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_method.freezed.dart';
part 'payment_method.g.dart';

enum PaymentType {
  cash,
  creditCard,
  debitCard,
  digitalWallet,
  bankTransfer,
  voucher,
  deposit,
  partialPayment,
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
  refunded,
  partiallyRefunded,
}

@freezed
class PaymentMethod with _$PaymentMethod {
  const factory PaymentMethod({
    required String id,
    required String name,
    required PaymentType type,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? description,
    String? iconPath,
    Map<String, dynamic>? configuration,
    double? processingFee,
    double? minimumAmount,
    double? maximumAmount,
    List<String>? supportedCurrencies,
    bool? requiresSignature,
    bool? requiresReceipt,
    String? notes,
  }) = _PaymentMethod;

  factory PaymentMethod.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodFromJson(json);
}
