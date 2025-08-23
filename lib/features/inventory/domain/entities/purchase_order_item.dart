import 'package:freezed_annotation/freezed_annotation.dart';

part 'purchase_order_item.freezed.dart';
part 'purchase_order_item.g.dart';

@freezed
class PurchaseOrderItem with _$PurchaseOrderItem {
  const factory PurchaseOrderItem({
    required String id,
    required String purchaseOrderId,
    required String productId,
    required String productName,
    required String productCode,
    required int quantity,
    required double unitPrice,
    required double totalPrice,
    required DateTime createdAt,
    required DateTime updatedAt,
    
    // Product Details
    String? description,
    String? brand,
    String? size,
    String? color,
    String? unit,
    
    // Order Details
    int? receivedQuantity,
    DateTime? receivedDate,
    String? receivedBy,
    String? notes,
    
    // Pricing Information
    double? discountPercentage,
    double? discountAmount,
    double? taxRate,
    double? taxAmount,
    
    // Additional Information
    Map<String, dynamic>? metadata,
  }) = _PurchaseOrderItem;

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) => _$PurchaseOrderItemFromJson(json);
}
