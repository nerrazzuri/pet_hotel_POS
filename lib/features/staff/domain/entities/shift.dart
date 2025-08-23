import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'shift.freezed.dart';
part 'shift.g.dart';

@freezed
class Shift with _$Shift {
  const factory Shift({
    required String id,
    required String staffMemberId,
    required DateTime startTime,
    DateTime? endTime,
    required ShiftStatus status,
    String? notes,
    double? actualHours,
    double? overtimeHours,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Shift;

  factory Shift.fromJson(Map<String, dynamic> json) => _$ShiftFromJson(json);

  factory Shift.create({
    required String staffMemberId,
    required DateTime startTime,
    String? notes,
  }) {
    return Shift(
      id: const Uuid().v4(),
      staffMemberId: staffMemberId,
      startTime: startTime,
      status: ShiftStatus.scheduled,
      notes: notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

enum ShiftStatus {
  @JsonValue('scheduled')
  scheduled,
  @JsonValue('active')
  active,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('no_show')
  noShow,
}

extension ShiftStatusExtension on ShiftStatus {
  String get displayName {
    switch (this) {
      case ShiftStatus.scheduled:
        return 'Scheduled';
      case ShiftStatus.active:
        return 'Active';
      case ShiftStatus.completed:
        return 'Completed';
      case ShiftStatus.cancelled:
        return 'Cancelled';
      case ShiftStatus.noShow:
        return 'No Show';
    }
  }

  Color get color {
    switch (this) {
      case ShiftStatus.scheduled:
        return Colors.blue;
      case ShiftStatus.active:
        return Colors.green;
      case ShiftStatus.completed:
        return Colors.teal;
      case ShiftStatus.cancelled:
        return Colors.red;
      case ShiftStatus.noShow:
        return Colors.orange;
    }
  }
}
