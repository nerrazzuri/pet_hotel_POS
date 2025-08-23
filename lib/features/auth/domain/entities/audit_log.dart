import 'package:freezed_annotation/freezed_annotation.dart';

part 'audit_log.freezed.dart';
part 'audit_log.g.dart';

enum AuditAction {
  @JsonValue('permission_granted')
  permissionGranted,
  @JsonValue('permission_revoked')
  permissionRevoked,
  @JsonValue('role_changed')
  roleChanged,
  @JsonValue('user_created')
  userCreated,
  @JsonValue('user_deleted')
  userDeleted,
  @JsonValue('login')
  login,
  @JsonValue('logout')
  logout,
  @JsonValue('data_accessed')
  dataAccessed,
  @JsonValue('data_modified')
  dataModified,
  @JsonValue('system_setting_changed')
  systemSettingChanged,
}

enum AuditSeverity {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical,
}

@freezed
class AuditLog with _$AuditLog {
  const factory AuditLog({
    required String id,
    required String userId,
    required String userEmail,
    required String userRole,
    required AuditAction action,
    required String resource,
    required String details,
    required AuditSeverity severity,
    required DateTime timestamp,
    String? ipAddress,
    String? userAgent,
    Map<String, dynamic>? metadata,
    String? targetUserId,
    String? targetUserRole,
  }) = _AuditLog;

  factory AuditLog.fromJson(Map<String, dynamic> json) => _$AuditLogFromJson(json);
}
