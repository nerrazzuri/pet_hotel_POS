import 'package:freezed_annotation/freezed_annotation.dart';

part 'voucher.freezed.dart';
part 'voucher.g.dart';

enum VoucherType {
  discount,      // Percentage or fixed amount discount
  giftCard,     // Gift card with balance
  promotional,  // Promotional code
  loyalty,      // Loyalty points redemption
}

enum VoucherStatus {
  active,
  used,
  expired,
  cancelled,
}

@freezed
class Voucher with _$Voucher {
  const factory Voucher({
    required String id,
    required String code,
    required VoucherType type,
    required VoucherStatus status,
    required double value, // Amount or percentage
    required DateTime validFrom,
    required DateTime validUntil,
    required int maxUsage,
    required int currentUsage,
    String? description,
    String? customerId, // If voucher is customer-specific
    String? customerName,
    List<String>? applicableServices, // Service IDs this voucher applies to
    List<String>? applicableProducts, // Product IDs this voucher applies to
    double? minimumPurchaseAmount, // Minimum amount required to use voucher
    double? maximumDiscountAmount, // Maximum discount amount (for percentage vouchers)
    String? issuedBy,
    DateTime? issuedAt,
    DateTime? usedAt,
    String? usedBy,
    String? transactionId, // Transaction where voucher was used
    Map<String, dynamic>? metadata,
  }) = _Voucher;

  factory Voucher.fromJson(Map<String, dynamic> json) => _$VoucherFromJson(json);
}

@freezed
class VoucherUsage with _$VoucherUsage {
  const factory VoucherUsage({
    required String id,
    required String voucherId,
    required String voucherCode,
    required String transactionId,
    required double discountAmount,
    required DateTime usedAt,
    required String usedBy,
    String? customerId,
    String? customerName,
    Map<String, dynamic>? metadata,
  }) = _VoucherUsage;

  factory VoucherUsage.fromJson(Map<String, dynamic> json) => _$VoucherUsageFromJson(json);
}
