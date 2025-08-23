import 'package:freezed_annotation/freezed_annotation.dart';

part 'receipt.freezed.dart';
part 'receipt.g.dart';

enum ReceiptType {
  sale,
  refund,
  deposit,
  withdrawal,
  adjustment,
  voided,
}

enum ReceiptStatus {
  generated,
  printed,
  emailed,
  whatsapped,
  voided,
  reprinted,
}

@freezed
class ReceiptItem with _$ReceiptItem {
  const factory ReceiptItem({
    required String id,
    required String name,
    required String description,
    required double quantity,
    required double unitPrice,
    required double totalAmount,
    String? itemId,
    String? category,
    double? discountAmount,
    double? discountPercentage,
    double? taxAmount,
    double? taxRate,
    Map<String, dynamic>? metadata,
  }) = _ReceiptItem;

  factory ReceiptItem.fromJson(Map<String, dynamic> json) =>
      _$ReceiptItemFromJson(json);
}

@freezed
class Receipt with _$Receipt {
  const factory Receipt({
    required String id,
    required String receiptNumber,
    required ReceiptType type,
    required ReceiptStatus status,
    required DateTime transactionDate,
    required double totalAmount,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? transactionId,
    String? invoiceId,
    String? orderId,
    String? cashierId,
    String? cashierName,
    String? terminalId,
    String? businessName,
    String? businessAddress,
    String? businessPhone,
    String? businessEmail,
    String? businessWebsite,
    String? businessTaxId,
    String? currency,
    double? exchangeRate,
    double? subtotal,
    double? taxAmount,
    double? discountAmount,
    double? serviceChargeAmount,
    double? tipAmount,
    double? changeAmount,
    String? paymentMethod,
    String? cardType,
    String? cardLast4,
    String? authorizationCode,
    String? referenceNumber,
    List<ReceiptItem>? items,
    String? notes,
    String? termsAndConditions,
    String? footerMessage,
    String? qrCodeData,
    String? barcodeData,
    List<String>? attachments,
    bool? isVoided,
    DateTime? voidedAt,
    String? voidedBy,
    String? voidReason,
    int? printCount,
    DateTime? lastPrintedAt,
    DateTime? emailedAt,
    DateTime? whatsappedAt,
    String? emailSentTo,
    String? whatsappSentTo,
    bool? isReprinted,
    DateTime? reprintedAt,
    String? reprintedBy,
    String? reprintReason,
  }) = _Receipt;

  factory Receipt.fromJson(Map<String, dynamic> json) =>
      _$ReceiptFromJson(json);
}
