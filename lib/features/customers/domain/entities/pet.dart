import 'package:freezed_annotation/freezed_annotation.dart';

part 'pet.freezed.dart';
part 'pet.g.dart';

@JsonEnum()
enum PetType {
  @JsonValue('cat')
  cat,
  @JsonValue('dog')
  dog,
  @JsonValue('bird')
  bird,
  @JsonValue('rabbit')
  rabbit,
  @JsonValue('hamster')
  hamster,
  @JsonValue('guinea_pig')
  guineaPig,
  @JsonValue('ferret')
  ferret,
  @JsonValue('other')
  other,
}

extension PetTypeExtension on PetType {
  String get displayName {
    switch (this) {
      case PetType.cat:
        return 'Cat';
      case PetType.dog:
        return 'Dog';
      case PetType.bird:
        return 'Bird';
      case PetType.rabbit:
        return 'Rabbit';
      case PetType.hamster:
        return 'Hamster';
      case PetType.guineaPig:
        return 'Guinea Pig';
      case PetType.ferret:
        return 'Ferret';
      case PetType.other:
        return 'Other';
    }
  }
}

@JsonEnum()
enum PetGender {
  @JsonValue('male')
  male,
  @JsonValue('female')
  female,
  @JsonValue('unknown')
  unknown,
}

extension PetGenderExtension on PetGender {
  String get displayName {
    switch (this) {
      case PetGender.male:
        return 'Male';
      case PetGender.female:
        return 'Female';
      case PetGender.unknown:
        return 'Unknown';
    }
  }
}

@JsonEnum()
enum PetSize {
  @JsonValue('tiny')
  tiny, // < 2kg
  @JsonValue('small')
  small, // 2-5kg
  @JsonValue('medium')
  medium, // 5-15kg
  @JsonValue('large')
  large, // 15-30kg
  @JsonValue('giant')
  giant, // > 30kg
}

@JsonEnum()
enum TemperamentType {
  @JsonValue('calm')
  calm,
  @JsonValue('playful')
  playful,
  @JsonValue('shy')
  shy,
  @JsonValue('aggressive')
  aggressive,
  @JsonValue('anxious')
  anxious,
  @JsonValue('friendly')
  friendly,
  @JsonValue('independent')
  independent,
  @JsonValue('social')
  social,
  @JsonValue('territorial')
  territorial,
  @JsonValue('other')
  other,
}

@JsonEnum()
enum FeedingScheduleType {
  @JsonValue('twice_daily')
  twiceDaily,
  @JsonValue('three_times_daily')
  threeTimesDaily,
  @JsonValue('free_feeding')
  freeFeeding,
  @JsonValue('scheduled')
  scheduled,
  @JsonValue('on_demand')
  onDemand,
  @JsonValue('other')
  other,
}

@freezed
class FeedingSchedule with _$FeedingSchedule {
  const factory FeedingSchedule({
    required String id,
    required FeedingScheduleType type,
    required List<DateTime> feedingTimes,
    required String foodType,
    required double portionSize,
    String? portionUnit,
    String? specialInstructions,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
  }) = _FeedingSchedule;

  factory FeedingSchedule.fromJson(Map<String, dynamic> json) => _$FeedingScheduleFromJson(json);
}

@freezed
class MedicalHistory with _$MedicalHistory {
  const factory MedicalHistory({
    required String id,
    required String condition,
    required DateTime diagnosedDate,
    required String diagnosedBy,
    String? treatment,
    DateTime? treatmentStartDate,
    DateTime? treatmentEndDate,
    String? medication,
    String? dosage,
    String? frequency,
    String? notes,
    bool? isOngoing,
    bool? isResolved,
  }) = _MedicalHistory;

  factory MedicalHistory.fromJson(Map<String, dynamic> json) => _$MedicalHistoryFromJson(json);
}

@freezed
class Pet with _$Pet {
  const factory Pet({
    required String id,
    required String customerId,
    required String customerName,
    required String name,
    required PetType type,
    required PetGender gender,
    required PetSize size,
    required DateTime dateOfBirth,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? breed,
    String? color,
    double? weight,
    String? weightUnit,
    String? microchipNumber,
    String? collarTag,
    String? photoUrl,
    bool? isNeutered,
    bool? isSpayed,
    bool? isVaccinated,
    bool? isDewormed,
    bool? isFleaTreated,
    bool? isTickTreated,
    TemperamentType? temperament,
    String? temperamentNotes,
    List<String>? allergies,
    List<String>? medications,
    List<String>? specialNeeds,
    String? behaviorNotes,
    String? veterinarianName,
    String? veterinarianPhone,
    String? veterinarianClinic,
    String? insuranceProvider,
    String? insurancePolicyNumber,
    DateTime? insuranceExpiryDate,
    FeedingSchedule? feedingSchedule,
    List<MedicalHistory>? medicalHistory,
    List<String>? tags,
    Map<String, dynamic>? preferences,
    bool? isActive,
    String? notes,
  }) = _Pet;

  factory Pet.fromJson(Map<String, dynamic> json) => _$PetFromJson(json);
}

extension PetExtension on Pet {
  int get age {
    final now = DateTime.now();
    return now.difference(dateOfBirth).inDays ~/ 365;
  }
  
  int get ageInMonths {
    final now = DateTime.now();
    return (now.difference(dateOfBirth).inDays / 30).floor();
  }
  
  bool get isAdult {
    if (type == PetType.cat) {
      return age >= 1; // Cats are adults at 1 year
    } else if (type == PetType.dog) {
      return age >= 1; // Dogs are adults at 1 year
    }
    return age >= 1;
  }
  
  bool get isSenior {
    if (type == PetType.cat) {
      return age >= 11; // Cats are senior at 11 years
    } else if (type == PetType.dog) {
      return age >= 7; // Dogs are senior at 7 years
    }
    return age >= 10;
  }
  
  bool get needsSpecialCare {
    return specialNeeds != null && specialNeeds!.isNotEmpty ||
           allergies != null && allergies!.isNotEmpty ||
           medications != null && medications!.isNotEmpty;
  }
  
  String get displayName {
    if (breed != null && breed!.isNotEmpty) {
      return '$name ($breed)';
    }
    return name;
  }
}
