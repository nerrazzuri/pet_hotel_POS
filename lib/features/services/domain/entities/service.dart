import 'package:freezed_annotation/freezed_annotation.dart';

part 'service.freezed.dart';
part 'service.g.dart';

enum ServiceCategory {
  boarding,
  daycare,
  grooming,
  addOns,
  retail,
  training,
  medical,
  wellness
}

@freezed
class Service with _$Service {
  const factory Service({
    required String id,
    required String serviceCode,
    required String name,
    required ServiceCategory category,
    required double price,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? description,
    int? duration, // in minutes
    String? imageUrl,
    List<String>? tags,
    Map<String, dynamic>? specifications,
    double? discountPrice,
    String? discountReason,
    DateTime? discountValidUntil,
    String? staffNotes,
    String? customerNotes,
    List<String>? requirements,
    bool? requiresAppointment,
    int? maxPetsPerSession,
    String? cancellationPolicy,
    double? depositRequired,
    Map<String, dynamic>? metadata,
  }) = _Service;

  factory Service.fromJson(Map<String, dynamic> json) => _$ServiceFromJson(json);
}

@freezed
class ServicePackage with _$ServicePackage {
  const factory ServicePackage({
    required String id,
    required String name,
    required String description,
    required double price,
    required int validityDays,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    List<String>? serviceIds,
    List<Service>? services,
    double? discountPercentage,
    String? discountReason,
    DateTime? discountValidUntil,
    int? maxUses,
    String? termsAndConditions,
    List<String>? restrictions,
    Map<String, dynamic>? metadata,
  }) = _ServicePackage;

  factory ServicePackage.fromJson(Map<String, dynamic> json) => _$ServicePackageFromJson(json);
}
