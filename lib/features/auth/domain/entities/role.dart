import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cat_hotel_pos/features/auth/domain/entities/user.dart';

part 'role.freezed.dart';
part 'role.g.dart';

@freezed
class Role with _$Role {
  const factory Role({
    required String id,
    required String name,
    required String description,
    required UserRole baseRole,
    required Map<String, bool> permissions,
    required bool isCustom,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isActive,
    String? createdBy,
    Map<String, dynamic>? metadata,
  }) = _Role;

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);
}

// Default roles with their base permissions
class DefaultRoles {
  static const staff = 'staff';
  static const manager = 'manager';
  static const owner = 'owner';
  static const administrator = 'administrator';
  
  // Custom role templates
  static const seniorStaff = 'senior_staff';
  static const groomerManager = 'groomer_manager';
  static const receptionist = 'receptionist';
  static const inventorySpecialist = 'inventory_specialist';
}
