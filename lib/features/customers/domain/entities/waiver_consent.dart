import 'package:freezed_annotation/freezed_annotation.dart';

part 'waiver_consent.freezed.dart';
part 'waiver_consent.g.dart';

@JsonEnum()
enum WaiverType {
  @JsonValue('boarding_waiver')
  boardingWaiver,
  @JsonValue('grooming_consent')
  groomingConsent,
  @JsonValue('medical_treatment')
  medicalTreatment,
  @JsonValue('emergency_contact')
  emergencyContact,
  @JsonValue('photo_release')
  photoRelease,
  @JsonValue('liability_release')
  liabilityRelease,
  @JsonValue('other')
  other,
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
}

@freezed
class WaiverConsent with _$WaiverConsent {
  const factory WaiverConsent({
    required String id,
    required String customerId,
    required String customerName,
    required String petId,
    required String petName,
    required WaiverType type,
    required String title,
    required String content,
    required WaiverStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? signedAt,
    String? signedBy,
    String? signatureMethod, // 'digital', 'handwritten', 'electronic'
    String? fileUrl,
    String? fileName,
    String? fileType,
    int? fileSize,
    DateTime? expiryDate,
    String? notes,
    bool? isRequired,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) = _WaiverConsent;

  factory WaiverConsent.fromJson(Map<String, dynamic> json) => _$WaiverConsentFromJson(json);
}

extension WaiverConsentExtension on WaiverConsent {
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }
  
  bool get needsRenewal {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30;
  }
  
  bool get canCheckIn {
    if (type == WaiverType.boardingWaiver || type == WaiverType.liabilityRelease) {
      return status == WaiverStatus.signed && !isExpired;
    }
    return true;
  }
}
