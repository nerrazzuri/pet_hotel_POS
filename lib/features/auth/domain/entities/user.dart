import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@JsonEnum()
enum UserRole {
  @JsonValue('staff')
  staff,
  @JsonValue('manager')
  manager,
  @JsonValue('owner')
  owner,
  @JsonValue('administrator')
  administrator,
}

@JsonEnum()
enum UserStatus {
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
  @JsonValue('suspended')
  suspended,
  @JsonValue('terminated')
  terminated,
}

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String username,
    required String email,
    required String fullName,
    required UserRole role,
    required Map<String, bool> permissions,
    required bool isActive,
    required DateTime lastLoginAt,
    required DateTime createdAt,
    String? phoneNumber,
    String? profileImageUrl,
    Map<String, bool>? customPermissions,
    UserStatus? status,
    String? location,
    List<String>? allowedShifts,
    Map<String, Map<String, dynamic>>? timeBasedPermissions,
    String? managerId,
    List<String>? subordinateIds,
    String? department,
    String? position,
    DateTime? hireDate,
    String? passwordHash,
    String? salt,
    DateTime? lastPasswordChange,
    int? failedLoginAttempts,
    DateTime? lockoutUntil,
    Map<String, dynamic>? preferences,
    String? notes,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
