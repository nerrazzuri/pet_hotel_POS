import 'package:freezed_annotation/freezed_annotation.dart';
import 'cart_item.dart';
import 'voucher.dart';
import 'deposit.dart';
import 'partial_payment.dart';

part 'pos_cart.freezed.dart';
part 'pos_cart.g.dart';

@freezed
class POSCart with _$POSCart {
  const factory POSCart({
    required String id,
    required List<CartItem> items,
    required DateTime createdAt,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? notes,
    String? holdReason,
    DateTime? heldAt,
    String? heldBy,
    double? subtotal,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    double? amountPaid,
    double? changeAmount,
    String? paymentMethod,
    String? status, // 'active', 'held', 'completed', 'cancelled', 'partial'
    String? cashierId,
    String? cashierName,
    String? transactionId,
    // Enhanced payment features
    List<PartialPayment>? partialPayments,
    List<Voucher>? appliedVouchers,
    List<Deposit>? appliedDeposits,
    double? voucherDiscountTotal,
    double? depositAmountTotal,
    double? remainingBalance,
    // Tax and compliance
    double? sstRate, // Malaysia SST rate
    double? sstAmount,
    bool? isTaxInclusive,
    String? taxRegistrationNumber,
    // Receipt and invoice
    String? receiptNumber,
    String? invoiceNumber,
    bool? receiptPrinted,
    bool? invoiceSent,
    String? invoiceEmail,
    String? invoiceWhatsApp,
  }) = _POSCart;

  factory POSCart.fromJson(Map<String, dynamic> json) => _$POSCartFromJson(json);
}


