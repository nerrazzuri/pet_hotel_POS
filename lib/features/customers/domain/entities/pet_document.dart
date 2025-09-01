import 'package:freezed_annotation/freezed_annotation.dart';

part 'pet_document.freezed.dart';
part 'pet_document.g.dart';

@JsonEnum()
enum DocumentType {
  @JsonValue('vaccination_certificate')
  vaccinationCertificate,
  @JsonValue('medical_record')
  medicalRecord,
  @JsonValue('health_certificate')
  healthCertificate,
  @JsonValue('microchip_certificate')
  microchipCertificate,
  @JsonValue('pedigree_certificate')
  pedigreeCertificate,
  @JsonValue('insurance_document')
  insuranceDocument,
  @JsonValue('behavior_assessment')
  behaviorAssessment,
  @JsonValue('training_certificate')
  trainingCertificate,
  @JsonValue('photo')
  photo,
  @JsonValue('video')
  video,
  @JsonValue('other')
  other,
}

extension DocumentTypeExtension on DocumentType {
  String get displayName {
    switch (this) {
      case DocumentType.vaccinationCertificate:
        return 'Vaccination Certificate';
      case DocumentType.medicalRecord:
        return 'Medical Record';
      case DocumentType.healthCertificate:
        return 'Health Certificate';
      case DocumentType.microchipCertificate:
        return 'Microchip Certificate';
      case DocumentType.pedigreeCertificate:
        return 'Pedigree Certificate';
      case DocumentType.insuranceDocument:
        return 'Insurance Document';
      case DocumentType.behaviorAssessment:
        return 'Behavior Assessment';
      case DocumentType.trainingCertificate:
        return 'Training Certificate';
      case DocumentType.photo:
        return 'Photo';
      case DocumentType.video:
        return 'Video';
      case DocumentType.other:
        return 'Other';
    }
  }
  
  String get icon {
    switch (this) {
      case DocumentType.vaccinationCertificate:
        return 'vaccines';
      case DocumentType.medicalRecord:
        return 'medical_services';
      case DocumentType.healthCertificate:
        return 'health_and_safety';
      case DocumentType.microchipCertificate:
        return 'memory';
      case DocumentType.pedigreeCertificate:
        return 'family_history';
      case DocumentType.insuranceDocument:
        return 'security';
      case DocumentType.behaviorAssessment:
        return 'psychology';
      case DocumentType.trainingCertificate:
        return 'school';
      case DocumentType.photo:
        return 'photo';
      case DocumentType.video:
        return 'video_library';
      case DocumentType.other:
        return 'description';
    }
  }
}

@JsonEnum()
enum DocumentStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
  @JsonValue('expired')
  expired,
  @JsonValue('archived')
  archived,
}

extension DocumentStatusExtension on DocumentStatus {
  String get displayName {
    switch (this) {
      case DocumentStatus.pending:
        return 'Pending';
      case DocumentStatus.approved:
        return 'Approved';
      case DocumentStatus.rejected:
        return 'Rejected';
      case DocumentStatus.expired:
        return 'Expired';
      case DocumentStatus.archived:
        return 'Archived';
    }
  }
}

@freezed
class PetDocument with _$PetDocument {
  const factory PetDocument({
    required String id,
    required String petId,
    required String petName,
    required String customerId,
    required String customerName,
    required DocumentType type,
    required String fileName,
    required String fileUrl,
    required String fileType,
    required int fileSize,
    required DocumentStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? title,
    String? description,
    DateTime? expiryDate,
    String? uploadedBy,
    String? approvedBy,
    DateTime? approvedAt,
    String? rejectionReason,
    DateTime? rejectedAt,
    String? tags,
    bool? isRequired,
    bool? isPublic,
    String? thumbnailUrl,
    int? version,
    Map<String, dynamic>? metadata,
  }) = _PetDocument;

  factory PetDocument.fromJson(Map<String, dynamic> json) => _$PetDocumentFromJson(json);
}

extension PetDocumentExtension on PetDocument {
  bool get isExpired {
    if (expiryDate != null) {
      return expiryDate!.isBefore(DateTime.now());
    }
    return false;
  }
  
  bool get isExpiringSoon {
    if (expiryDate != null) {
      final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
      return daysUntilExpiry <= 30 && daysUntilExpiry >= 0;
    }
    return false;
  }
  
  int get daysUntilExpiry {
    if (expiryDate != null) {
      return expiryDate!.difference(DateTime.now()).inDays;
    }
    return -1;
  }
  
  String get fileSizeDisplay {
    if (fileSize < 1024) {
      return '${fileSize} B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
  
  bool get isImage {
    return fileType.startsWith('image/');
  }
  
  bool get isVideo {
    return fileType.startsWith('video/');
  }
  
  bool get isPdf {
    return fileType == 'application/pdf';
  }
  
  String get statusDisplay {
    if (isExpired) {
      return 'Expired';
    } else if (isExpiringSoon) {
      return 'Expiring Soon';
    }
    return status.displayName;
  }
}
