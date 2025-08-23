import 'package:freezed_annotation/freezed_annotation.dart';

part 'supplier.freezed.dart';
part 'supplier.g.dart';

enum SupplierStatus {
  active,
  inactive,
  suspended,
  pending
}

enum SupplierCategory {
  food,
  supplies,
  equipment,
  services,
  other
}

@freezed
class Supplier with _$Supplier {
  const factory Supplier({
    required String id,
    required String name,
    required String companyName,
    required SupplierStatus status,
    required SupplierCategory category,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    
    // Contact Information
    String? email,
    String? phone,
    String? website,
    String? contactPerson,
    String? contactPhone,
    String? contactEmail,
    
    // Address Information
    String? address,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    
    // Business Information
    String? taxId,
    String? businessLicense,
    String? paymentTerms,
    String? creditLimit,
    String? notes,
    
    // Categories and Specialties
    List<String>? categories,
    List<String>? specialties,
    List<String>? certifications,
    
    // Performance Metrics
    double? rating,
    int? totalOrders,
    double? totalSpent,
    DateTime? lastOrderDate,
    
    // Additional Information
    Map<String, dynamic>? metadata,
  }) = _Supplier;

  factory Supplier.fromJson(Map<String, dynamic> json) => _$SupplierFromJson(json);
}

// Extension for display names
extension SupplierStatusExtension on SupplierStatus {
  String get displayName {
    switch (this) {
      case SupplierStatus.active:
        return 'Active';
      case SupplierStatus.inactive:
        return 'Inactive';
      case SupplierStatus.suspended:
        return 'Suspended';
      case SupplierStatus.pending:
        return 'Pending';
    }
  }
}

extension SupplierCategoryExtension on SupplierCategory {
  String get displayName {
    switch (this) {
      case SupplierCategory.food:
        return 'Food & Nutrition';
      case SupplierCategory.supplies:
        return 'Supplies';
      case SupplierCategory.equipment:
        return 'Equipment';
      case SupplierCategory.services:
        return 'Services';
      case SupplierCategory.other:
        return 'Other';
    }
  }
}
