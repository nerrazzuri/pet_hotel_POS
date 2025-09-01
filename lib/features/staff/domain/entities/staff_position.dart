import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'staff_position.freezed.dart';
part 'staff_position.g.dart';

@freezed
class StaffPosition with _$StaffPosition {
  const factory StaffPosition({
    required String id,
    required String title,
    required String description,
    required int hierarchyLevel,
    required String? reportsToId, // ID of the position this reports to
    required List<String> permissions, // List of permission IDs
    required double? baseSalary,
    required String? department,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _StaffPosition;

  factory StaffPosition.fromJson(Map<String, dynamic> json) =>
      _$StaffPositionFromJson(json);

  factory StaffPosition.create({
    required String title,
    required String description,
    required int hierarchyLevel,
    String? reportsToId,
    List<String> permissions = const [],
    double? baseSalary,
    String? department,
  }) {
    return StaffPosition(
      id: const Uuid().v4(),
      title: title,
      description: description,
      hierarchyLevel: hierarchyLevel,
      reportsToId: reportsToId,
      permissions: permissions,
      baseSalary: baseSalary,
      department: department,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

// Predefined hierarchy levels for common business structures
enum HierarchyLevel {
  @JsonValue(0)
  businessOwner(0, 'Business Owner', Colors.purple),
  @JsonValue(1)
  executive(1, 'Executive', Colors.red),
  @JsonValue(2)
  seniorManager(2, 'Senior Manager', Colors.blue),
  @JsonValue(3)
  manager(3, 'Manager', Colors.indigo),
  @JsonValue(4)
  supervisor(4, 'Supervisor', Colors.teal),
  @JsonValue(5)
  seniorStaff(5, 'Senior Staff', Colors.green),
  @JsonValue(6)
  staff(6, 'Staff', Colors.orange),
  @JsonValue(7)
  trainee(7, 'Trainee', Colors.grey);

  const HierarchyLevel(this.level, this.displayName, this.color);
  
  final int level;
  final String displayName;
  final Color color;

  static HierarchyLevel fromLevel(int level) {
    return HierarchyLevel.values.firstWhere(
      (h) => h.level == level,
      orElse: () => HierarchyLevel.staff,
    );
  }
}

// Common position templates for quick setup
class PositionTemplates {
  static const List<Map<String, dynamic>> templates = [
    {
      'title': 'Business Owner',
      'description': 'Ultimate decision maker and company owner',
      'hierarchyLevel': 0,
      'reportsToId': null,
      'permissions': ['all'],
      'baseSalary': null,
      'department': 'Executive',
    },
    {
      'title': 'General Manager',
      'description': 'Oversees all operations and reports to business owner',
      'hierarchyLevel': 1,
      'reportsToId': null, // Will be set to business owner
      'permissions': ['manage_staff', 'manage_finances', 'manage_operations'],
      'baseSalary': null,
      'department': 'Management',
    },
    {
      'title': 'Operations Manager',
      'description': 'Manages daily operations and reports to general manager',
      'hierarchyLevel': 2,
      'reportsToId': null, // Will be set to general manager
      'permissions': ['manage_operations', 'manage_staff'],
      'baseSalary': null,
      'department': 'Operations',
    },
    {
      'title': 'Department Head',
      'description': 'Leads a specific department and reports to operations manager',
      'hierarchyLevel': 3,
      'reportsToId': null, // Will be set to operations manager
      'permissions': ['manage_department', 'view_reports'],
      'baseSalary': null,
      'department': null, // Will be set based on department
    },
    {
      'title': 'Team Lead',
      'description': 'Leads a team and reports to department head',
      'hierarchyLevel': 4,
      'reportsToId': null, // Will be set to department head
      'permissions': ['manage_team', 'view_reports'],
      'baseSalary': null,
      'department': null, // Will be set based on department
    },
    {
      'title': 'Senior Staff',
      'description': 'Experienced staff member with some leadership responsibilities',
      'hierarchyLevel': 5,
      'reportsToId': null, // Will be set to team lead
      'permissions': ['view_reports', 'train_staff'],
      'baseSalary': null,
      'department': null, // Will be set based on department
    },
    {
      'title': 'Staff Member',
      'description': 'Regular staff member performing assigned duties',
      'hierarchyLevel': 6,
      'reportsToId': null, // Will be set to senior staff or team lead
      'permissions': ['basic_access'],
      'baseSalary': null,
      'department': null, // Will be set based on department
    },
    {
      'title': 'Trainee',
      'description': 'New staff member in training',
      'hierarchyLevel': 7,
      'reportsToId': null, // Will be set to staff member or team lead
      'permissions': ['basic_access'],
      'baseSalary': null,
      'department': null, // Will be set based on department
    },
  ];
}
