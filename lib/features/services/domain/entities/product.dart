import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

enum ProductCategory {
  // Food & Nutrition
  food,
  petFood,
  treats,
  supplements,
  
  // Physical Items
  toys,
  grooming,
  health,
  accessories,
  bedding,
  litter,
  cleaning,
  
  // Business Categories
  retail,
  services,
  other
}

enum ProductStatus {
  inStock,
  lowStock,
  outOfStock,
  discontinued,
  preOrder
}

@freezed
class Product with _$Product {
  const factory Product({
    // Core Identification
    required String id,
    required String productCode,
    required String name,
    required ProductCategory category,
    required bool isActive,
    
    // Pricing & Cost
    required double price,
    required double cost,
    double? discountPrice,
    String? discountReason,
    DateTime? discountValidUntil,
    
    // Inventory Management
    required int stockQuantity,
    required int reorderPoint,
    ProductStatus? status,
    
    // Product Details
    String? description,
    String? barcode,
    String? supplier,
    String? brand,
    String? size,
    String? color,
    String? weight,
    String? unit,
    
    // Media & Visual
    String? imageUrl,
    List<String>? images,
    
    // Additional Information
    List<String>? tags,
    Map<String, dynamic>? specifications,
    String? notes,
    DateTime? expiryDate,
    String? batchNumber,
    String? location,
    Map<String, dynamic>? metadata,
    
    // Timestamps
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
}

@freezed
class ProductBundle with _$ProductBundle {
  const factory ProductBundle({
    required String id,
    required String name,
    required String description,
    required double price,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    List<String>? productIds,
    List<Product>? products,
    Map<String, int>? productQuantities,
    double? discountPercentage,
    String? discountReason,
    DateTime? discountValidUntil,
    String? termsAndConditions,
    List<String>? restrictions,
    Map<String, dynamic>? metadata,
  }) = _ProductBundle;

  factory ProductBundle.fromJson(Map<String, dynamic> json) => _$ProductBundleFromJson(json);
}

// Extension for display names
extension ProductCategoryExtension on ProductCategory {
  String get displayName {
    switch (this) {
      case ProductCategory.food:
        return 'Food';
      case ProductCategory.petFood:
        return 'Pet Food';
      case ProductCategory.treats:
        return 'Treats';
      case ProductCategory.supplements:
        return 'Supplements';
      case ProductCategory.toys:
        return 'Toys';
      case ProductCategory.grooming:
        return 'Grooming';
      case ProductCategory.health:
        return 'Health & Wellness';
      case ProductCategory.accessories:
        return 'Accessories';
      case ProductCategory.bedding:
        return 'Bedding & Comfort';
      case ProductCategory.litter:
        return 'Litter & Hygiene';
      case ProductCategory.cleaning:
        return 'Cleaning Supplies';
      case ProductCategory.retail:
        return 'Retail Items';
      case ProductCategory.services:
        return 'Services';
      case ProductCategory.other:
        return 'Other';
    }
  }
}
