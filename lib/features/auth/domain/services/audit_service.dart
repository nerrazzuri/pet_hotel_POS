import 'package:cat_hotel_pos/features/auth/domain/entities/audit_log.dart';
import 'package:cat_hotel_pos/core/services/audit_log_dao.dart';

class AuditService {
  static final AuditService _instance = AuditService._internal();
  factory AuditService() => _instance;
  AuditService._internal();

  final AuditLogDao _auditLogDao = AuditLogDao();

  // Log permission changes
  Future<void> logPermissionChange({
    required String userId,
    required String userEmail,
    required String userRole,
    required String targetUserId,
    required String targetUserRole,
    required String permission,
    required bool granted,
    String? reason,
  }) async {
    final log = AuditLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      userEmail: userEmail,
      userRole: userRole,
      action: granted ? AuditAction.permissionGranted : AuditAction.permissionRevoked,
      resource: 'user_permissions',
      details: 'Permission ${granted ? 'granted' : 'revoked'}: $permission for user $targetUserId${reason != null ? ' (Reason: $reason)' : ''}',
      severity: AuditSeverity.medium,
      timestamp: DateTime.now(),
      targetUserId: targetUserId,
      targetUserRole: targetUserRole,
      metadata: {
        'permission': permission,
        'granted': granted,
        'reason': reason,
      },
    );

    await _auditLogDao.insert(log);
    _printAuditLog(log);
  }

  // Log role changes
  Future<void> logRoleChange({
    required String userId,
    required String userEmail,
    required String userRole,
    required String targetUserId,
    required String oldRole,
    required String newRole,
    String? reason,
  }) async {
    final log = AuditLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      userEmail: userEmail,
      userRole: userRole,
      action: AuditAction.roleChanged,
      resource: 'user_roles',
      details: 'Role changed from $oldRole to $newRole for user $targetUserId${reason != null ? ' (Reason: $reason)' : ''}',
      severity: AuditSeverity.high,
      timestamp: DateTime.now(),
      targetUserId: targetUserId,
      targetUserRole: newRole,
      metadata: {
        'oldRole': oldRole,
        'newRole': newRole,
        'reason': reason,
      },
    );

    await _auditLogDao.insert(log);
    _printAuditLog(log);
  }

  // Log user login
  Future<void> logLogin({
    required String userId,
    required String userEmail,
    required String userRole,
  }) async {
    final log = AuditLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      userEmail: userEmail,
      userRole: userRole,
      action: AuditAction.login,
      resource: 'authentication',
      details: 'User logged in successfully',
      severity: AuditSeverity.low,
      timestamp: DateTime.now(),
    );

    await _auditLogDao.insert(log);
    _printAuditLog(log);
  }

  // Log user logout
  Future<void> logLogout({
    required String userId,
    required String userEmail,
    required String userRole,
  }) async {
    final log = AuditLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      userEmail: userEmail,
      userRole: userRole,
      action: AuditAction.logout,
      resource: 'authentication',
      details: 'User logged out',
      severity: AuditSeverity.low,
      timestamp: DateTime.now(),
    );

    await _auditLogDao.insert(log);
    _printAuditLog(log);
  }

  // Log data access
  Future<void> logDataAccess({
    required String userId,
    required String userEmail,
    required String userRole,
    required String resource,
    String? details,
    Map<String, dynamic>? metadata,
  }) async {
    final log = AuditLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      userEmail: userEmail,
      userRole: userRole,
      action: AuditAction.dataAccessed,
      resource: resource,
      details: details ?? 'Data accessed: $resource',
      severity: AuditSeverity.low,
      timestamp: DateTime.now(),
      metadata: metadata,
    );

    await _auditLogDao.insert(log);
    _printAuditLog(log);
  }

  // Log data modification
  Future<void> logDataModification({
    required String userId,
    required String userEmail,
    required String userRole,
    required String resource,
    required String details,
    AuditSeverity severity = AuditSeverity.medium,
    Map<String, dynamic>? metadata,
  }) async {
    final log = AuditLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      userEmail: userEmail,
      userRole: userRole,
      action: AuditAction.dataModified,
      resource: resource,
      details: details,
      severity: severity,
      timestamp: DateTime.now(),
      metadata: metadata,
    );

    await _auditLogDao.insert(log);
    _printAuditLog(log);
  }

  // Get all audit logs
  Future<List<AuditLog>> getAllLogs({int? limit, int? offset}) async {
    return await _auditLogDao.getAll(limit: limit, offset: offset);
  }

  // Get logs for a specific user
  Future<List<AuditLog>> getLogsForUser(String userId) async {
    return await _auditLogDao.getLogsForUser(userId);
  }

  // Get logs by action type
  Future<List<AuditLog>> getLogsByAction(String action) async {
    return await _auditLogDao.getLogsByAction(action);
  }

  // Get logs by severity level
  Future<List<AuditLog>> getLogsBySeverity(AuditSeverity severity) async {
    return await _auditLogDao.getLogsBySeverity(severity);
  }

  // Get logs within a date range
  Future<List<AuditLog>> getLogsInDateRange(DateTime start, DateTime end) async {
    return await _auditLogDao.getLogsInDateRange(start, end);
  }

  // Clear old logs
  Future<void> clearOldLogs(DateTime before) async {
    await _auditLogDao.clearOldLogs(before);
  }

  // Export logs to CSV (placeholder for future implementation)
  Future<String> exportToCSV(List<AuditLog> logs) async {
    // TODO: Implement CSV export
    return 'CSV export not yet implemented';
  }

  // Private method for console output during development
  void _printAuditLog(AuditLog log) {
    print('🔍 AUDIT: ${log.action.name.toUpperCase()} - ${log.details}');
    print('   User: ${log.userEmail} (${log.userRole}) | Resource: ${log.resource} | Time: ${log.timestamp}');
    if (log.severity != AuditSeverity.low) {
      print('   ⚠️  Severity: ${log.severity.name.toUpperCase()}');
    }
    print('');
  }
}
