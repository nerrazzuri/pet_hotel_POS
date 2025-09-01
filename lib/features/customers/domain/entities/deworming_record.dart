import 'package:freezed_annotation/freezed_annotation.dart';

part 'deworming_record.freezed.dart';
part 'deworming_record.g.dart';

@JsonEnum()
enum DewormingType {
  @JsonValue('roundworm')
  roundworm,
  @JsonValue('tapeworm')
  tapeworm,
  @JsonValue('hookworm')
  hookworm,
  @JsonValue('whipworm')
  whipworm,
  @JsonValue('heartworm')
  heartworm,
  @JsonValue('broad_spectrum')
  broadSpectrum,
  @JsonValue('other')
  other,
}

extension DewormingTypeExtension on DewormingType {
  String get displayName {
    switch (this) {
      case DewormingType.roundworm:
        return 'Roundworm';
      case DewormingType.tapeworm:
        return 'Tapeworm';
      case DewormingType.hookworm:
        return 'Hookworm';
      case DewormingType.whipworm:
        return 'Whipworm';
      case DewormingType.heartworm:
        return 'Heartworm';
      case DewormingType.broadSpectrum:
        return 'Broad Spectrum';
      case DewormingType.other:
        return 'Other';
    }
  }
}

@JsonEnum()
enum DewormingStatus {
  @JsonValue('scheduled')
  scheduled,
  @JsonValue('administered')
  administered,
  @JsonValue('overdue')
  overdue,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('not_required')
  notRequired,
}

extension DewormingStatusExtension on DewormingStatus {
  String get displayName {
    switch (this) {
      case DewormingStatus.scheduled:
        return 'Scheduled';
      case DewormingStatus.administered:
        return 'Administered';
      case DewormingStatus.overdue:
        return 'Overdue';
      case DewormingStatus.cancelled:
        return 'Cancelled';
      case DewormingStatus.notRequired:
        return 'Not Required';
    }
  }
}

@freezed
class DewormingRecord with _$DewormingRecord {
  const factory DewormingRecord({
    required String id,
    required String petId,
    required String petName,
    required String customerId,
    required String customerName,
    required DewormingType type,
    required String productName,
    required String dosage,
    required String frequency,
    required DateTime scheduledDate,
    required DewormingStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? administeredDate,
    String? administeredBy,
    String? veterinarianName,
    String? veterinarianPhone,
    String? clinicName,
    String? batchNumber,
    String? manufacturer,
    String? notes,
    String? adverseReactions,
    bool? isPreventive,
    bool? isTreatment,
    DateTime? nextDueDate,
    double? weightAtTime,
    String? weightUnit,
    Map<String, dynamic>? metadata,
  }) = _DewormingRecord;

  factory DewormingRecord.fromJson(Map<String, dynamic> json) => _$DewormingRecordFromJson(json);
}

extension DewormingRecordExtension on DewormingRecord {
  bool get isOverdue {
    if (status == DewormingStatus.scheduled && scheduledDate.isBefore(DateTime.now())) {
      return true;
    }
    if (nextDueDate != null && nextDueDate!.isBefore(DateTime.now())) {
      return true;
    }
    return false;
  }
  
  bool get isDueSoon {
    if (nextDueDate != null) {
      final daysUntilDue = nextDueDate!.difference(DateTime.now()).inDays;
      return daysUntilDue <= 7 && daysUntilDue >= 0;
    }
    return false;
  }
  
  int get daysUntilDue {
    if (nextDueDate != null) {
      return nextDueDate!.difference(DateTime.now()).inDays;
    }
    return -1;
  }
  
  String get statusDisplay {
    if (isOverdue) {
      return 'Overdue';
    } else if (isDueSoon) {
      return 'Due Soon';
    }
    return status.displayName;
  }
}
