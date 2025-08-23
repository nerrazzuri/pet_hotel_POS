import 'package:freezed_annotation/freezed_annotation.dart';

part 'vaccination_record.freezed.dart';
part 'vaccination_record.g.dart';

@JsonEnum()
enum VaccineType {
  @JsonValue('feline_viral_rhinotracheitis')
  felineViralRhinotracheitis,
  @JsonValue('calicivirus')
  calicivirus,
  @JsonValue('panleukopenia')
  panleukopenia,
  @JsonValue('rabies')
  rabies,
  @JsonValue('feline_leukemia')
  felineLeukemia,
  @JsonValue('bordetella')
  bordetella,
  @JsonValue('chlamydia')
  chlamydia,
  @JsonValue('feline_immunodeficiency')
  felineImmunodeficiency,
  @JsonValue('other')
  other,
}

@JsonEnum()
enum VaccinationStatus {
  @JsonValue('up_to_date')
  upToDate,
  @JsonValue('due_soon')
  dueSoon,
  @JsonValue('overdue')
  overdue,
  @JsonValue('expired')
  expired,
  @JsonValue('unknown')
  unknown,
}

@freezed
class VaccinationRecord with _$VaccinationRecord {
  const factory VaccinationRecord({
    required String id,
    required String petId,
    required String petName,
    required VaccineType vaccineType,
    required String vaccineName,
    required DateTime dateGiven,
    required DateTime expiryDate,
    required String batchNumber,
    required String veterinarianName,
    required String veterinarianPhone,
    required String clinicName,
    String? notes,
    String? adverseReactions,
    bool? isBooster,
    String? previousVaccinationId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _VaccinationRecord;

  factory VaccinationRecord.fromJson(Map<String, dynamic> json) => _$VaccinationRecordFromJson(json);
}

extension VaccinationRecordExtension on VaccinationRecord {
  VaccinationStatus get status {
    final now = DateTime.now();
    final daysUntilExpiry = expiryDate.difference(now).inDays;
    
    if (daysUntilExpiry < 0) {
      return VaccinationStatus.expired;
    } else if (daysUntilExpiry <= 30) {
      return VaccinationStatus.dueSoon;
    } else {
      return VaccinationStatus.upToDate;
    }
  }
  
  bool get isExpired => status == VaccinationStatus.expired;
  bool get isDueSoon => status == VaccinationStatus.dueSoon;
  bool get isUpToDate => status == VaccinationStatus.upToDate;
  
  int get daysUntilExpiry {
    final now = DateTime.now();
    return expiryDate.difference(now).inDays;
  }
}
