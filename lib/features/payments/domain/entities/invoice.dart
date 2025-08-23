import 'package:freezed_annotation/freezed_annotation.dart';

part 'invoice.freezed.dart';
part 'invoice.g.dart';

enum InvoiceStatus {
  draft,
  sent,
  viewed,
  paid,
  overdue,
  cancelled,
  voided,
}

enum InvoiceType {
  service,
  product,
  package,
  deposit,
  adjustment,
  refund,
}

@freezed
class InvoiceItem with _$InvoiceItem {
  const factory InvoiceItem({
    required String id,
    required String name,
    required String description,
    required double quantity,
    required double unitPrice,
    required double totalAmount,
    required InvoiceType type,
    String? itemId,
    String? category,
    double? discountAmount,
    double? discountPercentage,
    double? taxAmount,
    double? taxRate,
    Map<String, dynamic>? metadata,
  }) = _InvoiceItem;

  factory InvoiceItem.fromJson(Map<String, dynamic> json) =>
      _$InvoiceItemFromJson(json);
}

@freezed
class Invoice with _$Invoice {
  const factory Invoice({
    required String id,
    required String invoiceNumber,
    required String customerId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required DateTime invoiceDate,
    required DateTime dueDate,
    required InvoiceStatus status,
    required double subtotal,
    required double taxAmount,
    required double totalAmount,
    required DateTime createdAt,
    required DateTime updatedAt,
    InvoiceType? type,
    String? customerAddress,
    String? customerTaxId,
    String? businessName,
    String? businessAddress,
    String? businessTaxId,
    String? businessPhone,
    String? businessEmail,
    String? businessWebsite,
    String? termsAndConditions,
    String? notes,
    String? paymentTerms,
    String? currency,
    double? exchangeRate,
    double? discountAmount,
    double? discountPercentage,
    double? shippingAmount,
    double? handlingAmount,
    List<InvoiceItem>? items,
    String? paymentMethod,
    DateTime? paidAt,
    String? paidBy,
    String? receiptId,
    String? referenceNumber,
    bool? isRecurring,
    String? recurringSchedule,
    DateTime? nextInvoiceDate,
    String? parentInvoiceId,
    List<String>? attachments,
    String? emailSentTo,
    DateTime? emailSentAt,
    bool? isVoided,
    DateTime? voidedAt,
    String? voidedBy,
    String? voidReason,
  }) = _Invoice;

  factory Invoice.fromJson(Map<String, dynamic> json) =>
      _$InvoiceFromJson(json);
}
