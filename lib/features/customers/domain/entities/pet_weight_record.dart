import 'package:freezed_annotation/freezed_annotation.dart';

part 'pet_weight_record.freezed.dart';
part 'pet_weight_record.g.dart';

@JsonEnum()
enum WeightUnit {
  @JsonValue('kg')
  kg,
  @JsonValue('lbs')
  lbs,
  @JsonValue('g')
  g,
  @JsonValue('oz')
  oz,
}

extension WeightUnitExtension on WeightUnit {
  String get displayName {
    switch (this) {
      case WeightUnit.kg:
        return 'Kilograms (kg)';
      case WeightUnit.lbs:
        return 'Pounds (lbs)';
      case WeightUnit.g:
        return 'Grams (g)';
      case WeightUnit.oz:
        return 'Ounces (oz)';
    }
  }
  
  String get shortName {
    switch (this) {
      case WeightUnit.kg:
        return 'kg';
      case WeightUnit.lbs:
        return 'lbs';
      case WeightUnit.g:
        return 'g';
      case WeightUnit.oz:
        return 'oz';
    }
  }
}

@JsonEnum()
enum WeightRecordType {
  @JsonValue('routine')
  routine,
  @JsonValue('pre_boarding')
  preBoarding,
  @JsonValue('post_boarding')
  postBoarding,
  @JsonValue('medical')
  medical,
  @JsonValue('grooming')
  grooming,
  @JsonValue('vaccination')
  vaccination,
  @JsonValue('deworming')
  deworming,
  @JsonValue('other')
  other,
}

extension WeightRecordTypeExtension on WeightRecordType {
  String get displayName {
    switch (this) {
      case WeightRecordType.routine:
        return 'Routine Check';
      case WeightRecordType.preBoarding:
        return 'Pre-Boarding';
      case WeightRecordType.postBoarding:
        return 'Post-Boarding';
      case WeightRecordType.medical:
        return 'Medical Visit';
      case WeightRecordType.grooming:
        return 'Grooming';
      case WeightRecordType.vaccination:
        return 'Vaccination';
      case WeightRecordType.deworming:
        return 'Deworming';
      case WeightRecordType.other:
        return 'Other';
    }
  }
}

@freezed
class PetWeightRecord with _$PetWeightRecord {
  const factory PetWeightRecord({
    required String id,
    required String petId,
    required String petName,
    required String customerId,
    required String customerName,
    required double weight,
    required WeightUnit unit,
    required WeightRecordType type,
    required DateTime recordedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? recordedBy,
    String? notes,
    String? location,
    String? equipment,
    bool? isAccurate,
    double? previousWeight,
    WeightUnit? previousUnit,
    double? weightChange,
    String? weightChangeUnit,
    double? bmi,
    String? bodyConditionScore,
    Map<String, dynamic>? metadata,
  }) = _PetWeightRecord;

  factory PetWeightRecord.fromJson(Map<String, dynamic> json) => _$PetWeightRecordFromJson(json);
}

extension PetWeightRecordExtension on PetWeightRecord {
  String get weightDisplay {
    return '${weight.toStringAsFixed(2)} ${unit.shortName}';
  }
  
  String get weightChangeDisplay {
    if (weightChange != null) {
      final change = weightChange!;
      final unitStr = weightChangeUnit ?? unit.shortName;
      if (change > 0) {
        return '+${change.toStringAsFixed(2)} $unitStr';
      } else if (change < 0) {
        return '${change.toStringAsFixed(2)} $unitStr';
      } else {
        return '0.00 $unitStr';
      }
    }
    return 'N/A';
  }
  
  bool get isWeightGain {
    return weightChange != null && weightChange! > 0;
  }
  
  bool get isWeightLoss {
    return weightChange != null && weightChange! < 0;
  }
  
  bool get isWeightStable {
    return weightChange != null && weightChange! == 0;
  }
  
  String get trend {
    if (isWeightGain) {
      return 'Gaining';
    } else if (isWeightLoss) {
      return 'Losing';
    } else if (isWeightStable) {
      return 'Stable';
    }
    return 'Unknown';
  }
  
  String get bodyConditionDescription {
    switch (bodyConditionScore) {
      case '1':
        return 'Very Thin';
      case '2':
        return 'Thin';
      case '3':
        return 'Ideal';
      case '4':
        return 'Overweight';
      case '5':
        return 'Obese';
      default:
        return 'Not Recorded';
    }
  }
}
