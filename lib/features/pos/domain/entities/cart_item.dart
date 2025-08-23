import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_item.freezed.dart';
part 'cart_item.g.dart';

@freezed
class CartItem with _$CartItem {
  const factory CartItem({
    required String id,
    required String name,
    required String type, // 'service', 'product', 'package'
    required double price,
    required int quantity,
    String? description,
    String? category,
    String? sku,
    String? barcode,
    Map<String, dynamic>? options, // For customizable services
    double? discountAmount,
    double? discountPercentage,
    String? discountReason,
    DateTime? createdAt,
    String? notes,
  }) = _CartItem;

  factory CartItem.fromJson(Map<String, dynamic> json) => _$CartItemFromJson(json);
}
