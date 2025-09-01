import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'waiver.freezed.dart';
part 'waiver.g.dart';

@JsonEnum()
enum WaiverType {
  @JsonValue('boarding_consent')
  boardingConsent,
  @JsonValue('grooming_consent')
  groomingConsent,
  @JsonValue('medical_treatment')
  medicalTreatment,
  @JsonValue('emergency_contact')
  emergencyContact,
  @JsonValue('photo_release')
  photoRelease,
  @JsonValue('liability_waiver')
  liabilityWaiver,
  @JsonValue('vaccination_waiver')
  vaccinationWaiver,
  @JsonValue('other')
  other,
}

extension WaiverTypeExtension on WaiverType {
  String get displayName {
    switch (this) {
      case WaiverType.boardingConsent:
        return 'Boarding Consent';
      case WaiverType.groomingConsent:
        return 'Grooming Consent';
      case WaiverType.medicalTreatment:
        return 'Medical Treatment';
      case WaiverType.emergencyContact:
        return 'Emergency Contact';
      case WaiverType.photoRelease:
        return 'Photo Release';
      case WaiverType.liabilityWaiver:
        return 'Liability Waiver';
      case WaiverType.vaccinationWaiver:
        return 'Vaccination Waiver';
      case WaiverType.other:
        return 'Other';
    }
  }
}

@JsonEnum()
enum WaiverStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('signed')
  signed,
  @JsonValue('expired')
  expired,
  @JsonValue('revoked')
  revoked,
  @JsonValue('rejected')
  rejected,
  @JsonValue('not_required')
  notRequired,
}

extension WaiverStatusExtension on WaiverStatus {
  String get displayName {
    switch (this) {
      case WaiverStatus.pending:
        return 'Pending';
      case WaiverStatus.signed:
        return 'Signed';
      case WaiverStatus.expired:
        return 'Expired';
      case WaiverStatus.revoked:
        return 'Revoked';
      case WaiverStatus.rejected:
        return 'Rejected';
      case WaiverStatus.notRequired:
        return 'Not Required';
    }
  }
}

@freezed
class Waiver with _$Waiver {
  const factory Waiver({
    required String id,
    required String customerId,
    required String customerName,
    String? petId,
    String? petName,
    required WaiverType type,
    required String title,
    required String content,
    required WaiverStatus status,
    required DateTime createdAt,
    DateTime? signedDate,
    DateTime? expiryDate,
    String? signedBy,
    String? signatureMethod, // digital, physical, email
    String? witnessName,
    String? witnessSignature,
    String? notes,
    bool? isRequired,
    bool? blocksCheckIn,
    Map<String, dynamic>? metadata,
    DateTime? updatedAt,
  }) = _Waiver;

  factory Waiver.fromJson(Map<String, dynamic> json) => _$WaiverFromJson(json);
}

extension WaiverExtension on Waiver {
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }
  
  bool get isDueSoon {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final daysUntilExpiry = expiryDate!.difference(now).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry > 0;
  }
  
  bool get isOverdue => isExpired;
  
  int get daysUntilExpiry {
    if (expiryDate == null) return -1;
    final now = DateTime.now();
    return expiryDate!.difference(now).inDays;
  }
  
  String get statusDisplay {
    switch (status) {
      case WaiverStatus.pending:
        return 'Pending';
      case WaiverStatus.signed:
        return 'Signed';
      case WaiverStatus.expired:
        return 'Expired';
      case WaiverStatus.revoked:
        return 'Revoked';
      case WaiverStatus.rejected:
        return 'Rejected';
      case WaiverStatus.notRequired:
        return 'Not Required';
    }
  }
  
  Color get statusColor {
    switch (status) {
      case WaiverStatus.pending:
        return Colors.orange;
      case WaiverStatus.signed:
        return Colors.green;
      case WaiverStatus.expired:
        return Colors.red;
      case WaiverStatus.revoked:
        return Colors.red;
      case WaiverStatus.rejected:
        return Colors.red.shade800;
      case WaiverStatus.notRequired:
        return Colors.grey;
    }
  }
  
  String get typeDisplay {
    switch (type) {
      case WaiverType.boardingConsent:
        return 'Boarding Consent';
      case WaiverType.groomingConsent:
        return 'Grooming Consent';
      case WaiverType.medicalTreatment:
        return 'Medical Treatment Consent';
      case WaiverType.emergencyContact:
        return 'Emergency Contact Authorization';
      case WaiverType.photoRelease:
        return 'Photo Release';
      case WaiverType.liabilityWaiver:
        return 'Liability Waiver';
      case WaiverType.vaccinationWaiver:
        return 'Vaccination Waiver';
      case WaiverType.other:
        return 'Other';
    }
  }
  
  bool get isSigned => status == WaiverStatus.signed;
  bool get needsSignature => status == WaiverStatus.pending;
  bool get isActive => isSigned && !isExpired;
}
