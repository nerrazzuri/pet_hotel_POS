import 'package:freezed_annotation/freezed_annotation.dart';

part 'partial_payment.freezed.dart';
part 'partial_payment.g.dart';

@freezed
class PartialPayment with _$PartialPayment {
  const factory PartialPayment({
    required String id,
    required String paymentMethod,
    required double amount,
    required DateTime paidAt,
    required String paidBy,
    String? reference, // Card auth code, bank reference, etc.
    String? notes,
    Map<String, dynamic>? metadata,
  }) = _PartialPayment;

  factory PartialPayment.fromJson(Map<String, dynamic> json) => _$PartialPaymentFromJson(json);
}
