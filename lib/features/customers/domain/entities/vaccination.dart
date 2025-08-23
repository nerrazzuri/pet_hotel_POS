import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'vaccination.freezed.dart';
part 'vaccination.g.dart';

@JsonEnum()
enum VaccinationType {
  @JsonValue('core')
  core,
  @JsonValue('non_core')
  nonCore,
  @JsonValue('rabies')
  rabies,
  @JsonValue('bordetella')
  bordetella,
  @JsonValue('dhpp')
  dhpp,
  @JsonValue('fvrcp')
  fvrcp,
  @JsonValue('lyme')
  lyme,
  @JsonValue('leptospirosis')
  leptospirosis,
  @JsonValue('canine_influenza')
  canineInfluenza,
  @JsonValue('feline_leukemia')
  felineLeukemia,
  @JsonValue('other')
  other,
}

@JsonEnum()
enum VaccinationStatus {
  @JsonValue('up_to_date')
  upToDate,
  @JsonValue('expired')
  expired,
  @JsonValue('due_soon')
  dueSoon,
  @JsonValue('overdue')
  overdue,
  @JsonValue('not_applicable')
  notApplicable,
}

@freezed
class Vaccination with _$Vaccination {
  const factory Vaccination({
    required String id,
    required String petId,
    required String petName,
    required String customerId,
    required String customerName,
    required VaccinationType type,
    required String name,
    required DateTime administeredDate,
    required DateTime expiryDate,
    required String administeredBy,
    required String clinicName,
    required VaccinationStatus status,
    String? batchNumber,
    String? manufacturer,
    String? notes,
    String? nextDueDate,
    bool? isRequired,
    bool? blocksCheckIn,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Vaccination;

  factory Vaccination.fromJson(Map<String, dynamic> json) => _$VaccinationFromJson(json);
}

extension VaccinationExtension on Vaccination {
  bool get isExpired => DateTime.now().isAfter(expiryDate);
  
  bool get isDueSoon {
    final now = DateTime.now();
    final daysUntilExpiry = expiryDate.difference(now).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry > 0;
  }
  
  bool get isOverdue => isExpired;
  
  int get daysUntilExpiry {
    final now = DateTime.now();
    return expiryDate.difference(now).inDays;
  }
  
  String get statusDisplay {
    switch (status) {
      case VaccinationStatus.upToDate:
        return 'Up to Date';
      case VaccinationStatus.expired:
        return 'Expired';
      case VaccinationStatus.dueSoon:
        return 'Due Soon';
      case VaccinationStatus.overdue:
        return 'Overdue';
      case VaccinationStatus.notApplicable:
        return 'Not Applicable';
    }
  }
  
  Color get statusColor {
    switch (status) {
      case VaccinationStatus.upToDate:
        return Colors.green;
      case VaccinationStatus.expired:
        return Colors.red;
      case VaccinationStatus.dueSoon:
        return Colors.orange;
      case VaccinationStatus.overdue:
        return Colors.red;
      case VaccinationStatus.notApplicable:
        return Colors.grey;
    }
  }
  
  String get typeDisplay {
    switch (type) {
      case VaccinationType.core:
        return 'Core Vaccination';
      case VaccinationType.nonCore:
        return 'Non-Core Vaccination';
      case VaccinationType.rabies:
        return 'Rabies';
      case VaccinationType.bordetella:
        return 'Bordetella';
      case VaccinationType.dhpp:
        return 'DHPP (Distemper, Hepatitis, Parvo, Parainfluenza)';
      case VaccinationType.fvrcp:
        return 'FVRCP (Feline Viral Rhinotracheitis, Calicivirus, Panleukopenia)';
      case VaccinationType.lyme:
        return 'Lyme Disease';
      case VaccinationType.leptospirosis:
        return 'Leptospirosis';
      case VaccinationType.canineInfluenza:
        return 'Canine Influenza';
      case VaccinationType.felineLeukemia:
        return 'Feline Leukemia';
      case VaccinationType.other:
        return 'Other';
    }
  }
}
