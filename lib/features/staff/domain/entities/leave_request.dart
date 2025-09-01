import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'leave_request.freezed.dart';
part 'leave_request.g.dart';

@freezed
class LeaveRequest with _$LeaveRequest {
  const factory LeaveRequest({
    required String id,
    required String staffMemberId,
    required LeaveType type,
    required DateTime startDate,
    required DateTime endDate,
    required int totalDays,
    required LeaveStatus status,
    String? reason,
    String? notes,
    String? approvedBy,
    DateTime? approvedAt,
    String? rejectedBy,
    DateTime? rejectedAt,
    String? rejectionReason,
    String? attachments,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _LeaveRequest;

  factory LeaveRequest.fromJson(Map<String, dynamic> json) =>
      _$LeaveRequestFromJson(json);

  factory LeaveRequest.create({
    required String staffMemberId,
    required LeaveType type,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
    String? notes,
  }) {
    final totalDays = endDate.difference(startDate).inDays + 1;
    return LeaveRequest(
      id: const Uuid().v4(),
      staffMemberId: staffMemberId,
      type: type,
      startDate: startDate,
      endDate: endDate,
      totalDays: totalDays,
      status: LeaveStatus.pending,
      reason: reason,
      notes: notes,
      approvedBy: null,
      approvedAt: null,
      rejectedBy: null,
      rejectedAt: null,
      rejectionReason: null,
      attachments: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

@freezed
class LeaveBalance with _$LeaveBalance {
  const factory LeaveBalance({
    required String id,
    required String staffMemberId,
    required int year,
    required int annualLeaveTotal,
    required int annualLeaveUsed,
    required int annualLeaveRemaining,
    required int sickLeaveTotal,
    required int sickLeaveUsed,
    required int sickLeaveRemaining,
    required int medicalLeaveTotal,
    required int medicalLeaveUsed,
    required int medicalLeaveRemaining,
    required int personalLeaveTotal,
    required int personalLeaveUsed,
    required int personalLeaveRemaining,
    required int emergencyLeaveTotal,
    required int emergencyLeaveUsed,
    required int emergencyLeaveRemaining,
    required int maternityLeaveTotal,
    required int maternityLeaveUsed,
    required int maternityLeaveRemaining,
    required int paternityLeaveTotal,
    required int paternityLeaveUsed,
    required int paternityLeaveRemaining,
    required int compassionateLeaveTotal,
    required int compassionateLeaveUsed,
    required int compassionateLeaveRemaining,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _LeaveBalance;

  factory LeaveBalance.fromJson(Map<String, dynamic> json) =>
      _$LeaveBalanceFromJson(json);

  factory LeaveBalance.create({
    required String staffMemberId,
    required int year,
    int? annualLeaveTotal,
    int? sickLeaveTotal,
    int? medicalLeaveTotal,
    int? personalLeaveTotal,
    int? emergencyLeaveTotal,
    int? maternityLeaveTotal,
    int? paternityLeaveTotal,
    int? compassionateLeaveTotal,
  }) {
    final annual = annualLeaveTotal ?? 21; // Default 21 days annual leave
    final sick = sickLeaveTotal ?? 14; // Default 14 days sick leave
    final medical = medicalLeaveTotal ?? 30; // Default 30 days medical leave
    final personal = personalLeaveTotal ?? 5; // Default 5 days personal leave
    final emergency = emergencyLeaveTotal ?? 3; // Default 3 days emergency leave
    final maternity = maternityLeaveTotal ?? 90; // Default 90 days maternity leave
    final paternity = paternityLeaveTotal ?? 14; // Default 14 days paternity leave
    final compassionate = compassionateLeaveTotal ?? 5; // Default 5 days compassionate leave

    return LeaveBalance(
      id: const Uuid().v4(),
      staffMemberId: staffMemberId,
      year: year,
      annualLeaveTotal: annual,
      annualLeaveUsed: 0,
      annualLeaveRemaining: annual,
      sickLeaveTotal: sick,
      sickLeaveUsed: 0,
      sickLeaveRemaining: sick,
      medicalLeaveTotal: medical,
      medicalLeaveUsed: 0,
      medicalLeaveRemaining: medical,
      personalLeaveTotal: personal,
      personalLeaveUsed: 0,
      personalLeaveRemaining: personal,
      emergencyLeaveTotal: emergency,
      emergencyLeaveUsed: 0,
      emergencyLeaveRemaining: emergency,
      maternityLeaveTotal: maternity,
      maternityLeaveUsed: 0,
      maternityLeaveRemaining: maternity,
      paternityLeaveTotal: paternity,
      paternityLeaveUsed: 0,
      paternityLeaveRemaining: paternity,
      compassionateLeaveTotal: compassionate,
      compassionateLeaveUsed: 0,
      compassionateLeaveRemaining: compassionate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

enum LeaveType {
  @JsonValue('annual')
  annual,
  @JsonValue('sick')
  sick,
  @JsonValue('medical')
  medical,
  @JsonValue('personal')
  personal,
  @JsonValue('emergency')
  emergency,
  @JsonValue('maternity')
  maternity,
  @JsonValue('paternity')
  paternity,
  @JsonValue('compassionate')
  compassionate,
  @JsonValue('unpaid')
  unpaid,
}

enum LeaveStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
  @JsonValue('cancelled')
  cancelled,
}

extension LeaveTypeExtension on LeaveType {
  String get displayName {
    switch (this) {
      case LeaveType.annual:
        return 'Annual Leave';
      case LeaveType.sick:
        return 'Sick Leave';
      case LeaveType.medical:
        return 'Medical Leave';
      case LeaveType.personal:
        return 'Personal Leave';
      case LeaveType.emergency:
        return 'Emergency Leave';
      case LeaveType.maternity:
        return 'Maternity Leave';
      case LeaveType.paternity:
        return 'Paternity Leave';
      case LeaveType.compassionate:
        return 'Compassionate Leave';
      case LeaveType.unpaid:
        return 'Unpaid Leave';
    }
  }

  Color get color {
    switch (this) {
      case LeaveType.annual:
        return Colors.blue;
      case LeaveType.sick:
        return Colors.red;
      case LeaveType.medical:
        return Colors.red[300]!;
      case LeaveType.personal:
        return Colors.green;
      case LeaveType.emergency:
        return Colors.orange;
      case LeaveType.maternity:
        return Colors.pink;
      case LeaveType.paternity:
        return Colors.cyan;
      case LeaveType.compassionate:
        return Colors.purple;
      case LeaveType.unpaid:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (this) {
      case LeaveType.annual:
        return Icons.beach_access;
      case LeaveType.sick:
        return Icons.sick;
      case LeaveType.medical:
        return Icons.medical_services;
      case LeaveType.personal:
        return Icons.person;
      case LeaveType.emergency:
        return Icons.emergency;
      case LeaveType.maternity:
        return Icons.child_care;
      case LeaveType.paternity:
        return Icons.family_restroom;
      case LeaveType.compassionate:
        return Icons.favorite;
      case LeaveType.unpaid:
        return Icons.money_off;
    }
  }
}

extension LeaveStatusExtension on LeaveStatus {
  String get displayName {
    switch (this) {
      case LeaveStatus.pending:
        return 'Pending';
      case LeaveStatus.approved:
        return 'Approved';
      case LeaveStatus.rejected:
        return 'Rejected';
      case LeaveStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case LeaveStatus.pending:
        return Colors.orange;
      case LeaveStatus.approved:
        return Colors.green;
      case LeaveStatus.rejected:
        return Colors.red;
      case LeaveStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (this) {
      case LeaveStatus.pending:
        return Icons.schedule;
      case LeaveStatus.approved:
        return Icons.check_circle;
      case LeaveStatus.rejected:
        return Icons.cancel;
      case LeaveStatus.cancelled:
        return Icons.block;
    }
  }
}
