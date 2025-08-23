import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'staff_member.freezed.dart';
part 'staff_member.g.dart';

@freezed
class StaffMember with _$StaffMember {
  const factory StaffMember({
    required String id,
    required String employeeId,
    required String fullName,
    required String email,
    required String phone,
    required StaffRole role,
    required StaffStatus status,
    required DateTime hireDate,
    String? department,
    String? position,
    double? hourlyRate,
    String? emergencyContact,
    String? emergencyPhone,
    String? address,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _StaffMember;

  factory StaffMember.fromJson(Map<String, dynamic> json) =>
      _$StaffMemberFromJson(json);

  factory StaffMember.create({
    required String employeeId,
    required String fullName,
    required String email,
    required String phone,
    required StaffRole role,
    String? department,
    String? position,
    double? hourlyRate,
    String? emergencyContact,
    String? emergencyPhone,
    String? address,
    String? notes,
  }) {
    return StaffMember(
      id: const Uuid().v4(),
      employeeId: employeeId,
      fullName: fullName,
      email: email,
      phone: phone,
      role: role,
      status: StaffStatus.active,
      hireDate: DateTime.now(),
      department: department,
      position: position,
      hourlyRate: hourlyRate,
      emergencyContact: emergencyContact,
      emergencyPhone: emergencyPhone,
      address: address,
      notes: notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

enum StaffRole {
  @JsonValue('admin')
  admin,
  @JsonValue('manager')
  manager,
  @JsonValue('cashier')
  cashier,
  @JsonValue('groomer')
  groomer,
  @JsonValue('housekeeper')
  housekeeper,
  @JsonValue('receptionist')
  receptionist,
  @JsonValue('veterinarian')
  veterinarian,
  @JsonValue('assistant')
  assistant,
}

enum StaffStatus {
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
  @JsonValue('suspended')
  suspended,
  @JsonValue('terminated')
  terminated,
  @JsonValue('on_leave')
  onLeave,
}

extension StaffRoleExtension on StaffRole {
  String get displayName {
    switch (this) {
      case StaffRole.admin:
        return 'Administrator';
      case StaffRole.manager:
        return 'Manager';
      case StaffRole.cashier:
        return 'Cashier';
      case StaffRole.groomer:
        return 'Groomer';
      case StaffRole.housekeeper:
        return 'Housekeeper';
      case StaffRole.receptionist:
        return 'Receptionist';
      case StaffRole.veterinarian:
        return 'Veterinarian';
      case StaffRole.assistant:
        return 'Assistant';
    }
  }

  String get shortName {
    switch (this) {
      case StaffRole.admin:
        return 'Admin';
      case StaffRole.manager:
        return 'Mgr';
      case StaffRole.cashier:
        return 'Cash';
      case StaffRole.groomer:
        return 'Groom';
      case StaffRole.housekeeper:
        return 'HK';
      case StaffRole.receptionist:
        return 'Recep';
      case StaffRole.veterinarian:
        return 'Vet';
      case StaffRole.assistant:
        return 'Asst';
    }
  }

  Color get color {
    switch (this) {
      case StaffRole.admin:
        return Colors.purple;
      case StaffRole.manager:
        return Colors.blue;
      case StaffRole.cashier:
        return Colors.green;
      case StaffRole.groomer:
        return Colors.orange;
      case StaffRole.housekeeper:
        return Colors.teal;
      case StaffRole.receptionist:
        return Colors.indigo;
      case StaffRole.veterinarian:
        return Colors.red;
      case StaffRole.assistant:
        return Colors.grey;
    }
  }
}

extension StaffStatusExtension on StaffStatus {
  String get displayName {
    switch (this) {
      case StaffStatus.active:
        return 'Active';
      case StaffStatus.inactive:
        return 'Inactive';
      case StaffStatus.suspended:
        return 'Suspended';
      case StaffStatus.terminated:
        return 'Terminated';
      case StaffStatus.onLeave:
        return 'On Leave';
    }
  }

  Color get color {
    switch (this) {
      case StaffStatus.active:
        return Colors.green;
      case StaffStatus.inactive:
        return Colors.grey;
      case StaffStatus.suspended:
        return Colors.orange;
      case StaffStatus.terminated:
        return Colors.red;
      case StaffStatus.onLeave:
        return Colors.blue;
    }
  }
}
