import 'package:freezed_annotation/freezed_annotation.dart';
import 'cart_item.dart';
import 'voucher.dart';
import 'deposit.dart';
import 'partial_payment.dart';
import 'receipt_reprint.dart';
import 'invoice_resend.dart';

part 'pos_transaction.freezed.dart';
part 'pos_transaction.g.dart';

@freezed
class POSTransaction with _$POSTransaction {
  const factory POSTransaction({
    required String id,
    required List<CartItem> items,
    required DateTime createdAt,
    required DateTime completedAt,
    required double totalAmount,
    required String paymentMethod,
    required String status, // 'completed', 'refunded', 'voided', 'partial'
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    double? subtotal,
    double? taxAmount,
    double? discountAmount,
    double? amountPaid,
    double? changeAmount,
    String? cashierId,
    String? cashierName,
    String? receiptNumber,
    String? invoiceNumber,
    String? notes,
    String? refundReason,
    String? voidReason,
    DateTime? refundedAt,
    DateTime? voidedAt,
    String? refundedBy,
    String? voidedBy,
    List<PaymentSplit>? paymentSplits,
    Map<String, dynamic>? metadata,
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
    bool? receiptPrinted,
    bool? invoiceSent,
    String? invoiceEmail,
    String? invoiceWhatsApp,
    DateTime? receiptPrintedAt,
    DateTime? invoiceSentAt,
    // Reprint tracking
    int? receiptPrintCount,
    int? invoiceSendCount,
    List<ReceiptReprint>? receiptReprints,
    List<InvoiceResend>? invoiceResends,
  }) = _POSTransaction;

  factory POSTransaction.fromJson(Map<String, dynamic> json) => _$POSTransactionFromJson(json);
}

@freezed
class PaymentSplit with _$PaymentSplit {
  const factory PaymentSplit({
    required String id,
    required String paymentMethod,
    required double amount,
    String? reference,
    String? notes,
    DateTime? createdAt,
  }) = _PaymentSplit;

  factory PaymentSplit.fromJson(Map<String, dynamic> json) => _$PaymentSplitFromJson(json);
}


