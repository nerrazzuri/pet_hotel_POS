// Stub Audit Log DAO for Android compatibility
// This will be re-enabled when database services are restored

import 'package:cat_hotel_pos/features/auth/domain/entities/audit_log.dart';

class AuditLogDao {
  // TODO: Uncomment when implementing database tables
  // static const String _table = 'audit_logs';

  Future<void> insert(AuditLog log) async {
    // Stub implementation
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    return [];
  }

  Future<List<Map<String, dynamic>>> queryByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? orderBy,
    int? limit,
  }) async {
    return [];
  }

  Future<List<Map<String, dynamic>>> queryByUser(
    String userId, {
    String? orderBy,
    int? limit,
  }) async {
    return [];
  }

  Future<List<Map<String, dynamic>>> queryByAction(
    String action, {
    String? orderBy,
    int? limit,
  }) async {
    return [];
  }

  Future<List<Map<String, dynamic>>> queryByResource(
    String resourceType,
    String resourceId, {
    String? orderBy,
    int? limit,
  }) async {
    return [];
  }

  Future<void> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    // Stub implementation
  }

  // Additional methods that AuditService expects
  Future<List<AuditLog>> getAll({int? limit, int? offset}) async {
    return [];
  }

  Future<List<AuditLog>> getLogsForUser(String userId) async {
    return [];
  }

  Future<List<AuditLog>> getLogsByAction(String action) async {
    return [];
  }

  Future<List<AuditLog>> getLogsBySeverity(dynamic severity) async {
    return [];
  }

  Future<List<AuditLog>> getLogsInDateRange(DateTime start, DateTime end) async {
    return [];
  }

  Future<void> clearOldLogs(DateTime before) async {
    // Stub implementation
  }
}
