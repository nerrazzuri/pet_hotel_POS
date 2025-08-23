import 'package:freezed_annotation/freezed_annotation.dart';

part 'purchase_order.freezed.dart';
part 'purchase_order.g.dart';

enum PurchaseOrderStatus {
  draft,
  submitted,
  approved,
  ordered,
  received,
  completed,
  cancelled,
  rejected
}

enum PurchaseOrderType {
  regular,
  bulk,
  emergency,
  seasonal,
  maintenance
}

@freezed
class PurchaseOrder with _$PurchaseOrder {
  const factory PurchaseOrder({
    required String id,
    required String orderNumber,
    required String supplierId,
    required String supplierName,
    required PurchaseOrderStatus status,
    required PurchaseOrderType type,
    required DateTime orderDate,
    required DateTime expectedDeliveryDate,
    required double totalAmount,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    
    // Order Details
    String? notes,
    String? specialInstructions,
    String? deliveryAddress,
    String? billingAddress,
    
    // Financial Information
    double? taxAmount,
    double? shippingAmount,
    double? discountAmount,
    String? paymentTerms,
    String? paymentMethod,
    
    // Delivery Information
    String? deliveryMethod,
    String? trackingNumber,
    String? carrier,
    DateTime? actualDeliveryDate,
    
    // Approval Information
    String? approvedBy,
    DateTime? approvedAt,
    String? approvalNotes,
    
    // Additional Information
    List<String>? attachments,
    Map<String, dynamic>? metadata,
  }) = _PurchaseOrder;

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) => _$PurchaseOrderFromJson(json);
}

// Extension for display names
extension PurchaseOrderStatusExtension on PurchaseOrderStatus {
  String get displayName {
    switch (this) {
      case PurchaseOrderStatus.draft:
        return 'Draft';
      case PurchaseOrderStatus.submitted:
        return 'Submitted';
      case PurchaseOrderStatus.approved:
        return 'Approved';
      case PurchaseOrderStatus.ordered:
        return 'Ordered';
      case PurchaseOrderStatus.received:
        return 'Received';
      case PurchaseOrderStatus.completed:
        return 'Completed';
      case PurchaseOrderStatus.cancelled:
        return 'Cancelled';
      case PurchaseOrderStatus.rejected:
        return 'Rejected';
    }
  }
}

extension PurchaseOrderTypeExtension on PurchaseOrderType {
  String get displayName {
    switch (this) {
      case PurchaseOrderType.regular:
        return 'Regular';
      case PurchaseOrderType.bulk:
        return 'Bulk';
      case PurchaseOrderType.emergency:
        return 'Emergency';
      case PurchaseOrderType.seasonal:
        return 'Seasonal';
      case PurchaseOrderType.maintenance:
        return 'Maintenance';
    }
  }
}
