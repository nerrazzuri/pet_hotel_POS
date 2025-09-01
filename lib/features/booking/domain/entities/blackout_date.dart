import 'package:freezed_annotation/freezed_annotation.dart';

part 'blackout_date.freezed.dart';
part 'blackout_date.g.dart';

enum BlackoutReason {
  maintenance,
  holiday,
  specialEvent,
  staffTraining,
  renovation,
  emergency,
  other
}

@freezed
class BlackoutDate with _$BlackoutDate {
  const factory BlackoutDate({
    required String id,
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required BlackoutReason reason,
    required List<String> affectedRoomIds,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? createdBy,
    String? notes,
    Map<String, dynamic>? metadata,
  }) = _BlackoutDate;

  factory BlackoutDate.fromJson(Map<String, dynamic> json) => _$BlackoutDateFromJson(json);
}
