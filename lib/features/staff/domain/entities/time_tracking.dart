import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'time_tracking.freezed.dart';
part 'time_tracking.g.dart';

@freezed
class TimeTracking with _$TimeTracking {
  const factory TimeTracking({
    required String id,
    required String staffMemberId,
    required DateTime clockInTime,
    DateTime? clockOutTime,
    DateTime? breakStartTime,
    DateTime? breakEndTime,
    required TimeTrackingStatus status,
    String? notes,
    String? location,
    double? totalHours,
    double? overtimeHours,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TimeTracking;

  factory TimeTracking.fromJson(Map<String, dynamic> json) =>
      _$TimeTrackingFromJson(json);

  factory TimeTracking.create({
    required String staffMemberId,
    DateTime? clockInTime,
    String? location,
    String? notes,
  }) {
    final now = DateTime.now();
    return TimeTracking(
      id: const Uuid().v4(),
      staffMemberId: staffMemberId,
      clockInTime: clockInTime ?? now,
      clockOutTime: null,
      breakStartTime: null,
      breakEndTime: null,
      status: TimeTrackingStatus.clockedIn,
      notes: notes,
      location: location,
      totalHours: 0.0,
      overtimeHours: 0.0,
      createdAt: now,
      updatedAt: now,
    );
  }
}

@freezed
class BreakRecord with _$BreakRecord {
  const factory BreakRecord({
    required String id,
    required String timeTrackingId,
    required DateTime startTime,
    DateTime? endTime,
    required BreakType type,
    String? reason,
    required DateTime createdAt,
  }) = _BreakRecord;

  factory BreakRecord.fromJson(Map<String, dynamic> json) =>
      _$BreakRecordFromJson(json);

  factory BreakRecord.create({
    required String timeTrackingId,
    required BreakType type,
    String? reason,
  }) {
    return BreakRecord(
      id: const Uuid().v4(),
      timeTrackingId: timeTrackingId,
      startTime: DateTime.now(),
      endTime: null,
      type: type,
      reason: reason,
      createdAt: DateTime.now(),
    );
  }
}

enum TimeTrackingStatus {
  @JsonValue('clocked_in')
  clockedIn,
  @JsonValue('on_break')
  onBreak,
  @JsonValue('clocked_out')
  clockedOut,
  @JsonValue('overtime')
  overtime,
}

enum BreakType {
  @JsonValue('lunch')
  lunch,
  @JsonValue('short_break')
  shortBreak,
  @JsonValue('personal')
  personal,
  @JsonValue('emergency')
  emergency,
}

extension TimeTrackingStatusExtension on TimeTrackingStatus {
  String get displayName {
    switch (this) {
      case TimeTrackingStatus.clockedIn:
        return 'Clocked In';
      case TimeTrackingStatus.onBreak:
        return 'On Break';
      case TimeTrackingStatus.clockedOut:
        return 'Clocked Out';
      case TimeTrackingStatus.overtime:
        return 'Overtime';
    }
  }

  Color get color {
    switch (this) {
      case TimeTrackingStatus.clockedIn:
        return Colors.green;
      case TimeTrackingStatus.onBreak:
        return Colors.orange;
      case TimeTrackingStatus.clockedOut:
        return Colors.grey;
      case TimeTrackingStatus.overtime:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case TimeTrackingStatus.clockedIn:
        return Icons.login;
      case TimeTrackingStatus.onBreak:
        return Icons.pause_circle;
      case TimeTrackingStatus.clockedOut:
        return Icons.logout;
      case TimeTrackingStatus.overtime:
        return Icons.schedule;
    }
  }
}

extension BreakTypeExtension on BreakType {
  String get displayName {
    switch (this) {
      case BreakType.lunch:
        return 'Lunch Break';
      case BreakType.shortBreak:
        return 'Short Break';
      case BreakType.personal:
        return 'Personal Break';
      case BreakType.emergency:
        return 'Emergency Break';
    }
  }

  Duration get maxDuration {
    switch (this) {
      case BreakType.lunch:
        return const Duration(hours: 1);
      case BreakType.shortBreak:
        return const Duration(minutes: 15);
      case BreakType.personal:
        return const Duration(minutes: 30);
      case BreakType.emergency:
        return const Duration(hours: 2);
    }
  }
}
