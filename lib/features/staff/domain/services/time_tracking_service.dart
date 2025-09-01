import 'package:cat_hotel_pos/features/staff/domain/entities/time_tracking.dart';
import 'package:cat_hotel_pos/core/services/time_tracking_dao.dart';

class TimeTrackingService {
  final TimeTrackingDao _timeTrackingDao;

  TimeTrackingService(this._timeTrackingDao);

  /// Clock in for a staff member
  Future<TimeTracking> clockIn({
    required String staffMemberId,
    String? location,
    String? notes,
  }) async {
    // Check if staff member is already clocked in
    final activeTracking = await getActiveTracking(staffMemberId);
    if (activeTracking != null) {
      throw Exception('Staff member is already clocked in');
    }

    final timeTracking = TimeTracking.create(
      staffMemberId: staffMemberId,
      location: location,
      notes: notes,
    );

    return await _timeTrackingDao.createTimeTracking(timeTracking);
  }

  /// Clock out for a staff member
  Future<TimeTracking> clockOut({
    required String staffMemberId,
    String? notes,
  }) async {
    final activeTracking = await getActiveTracking(staffMemberId);
    if (activeTracking == null) {
      throw Exception('No active time tracking found');
    }

    final clockOutTime = DateTime.now();
    final totalHours = _calculateTotalHours(
      activeTracking.clockInTime,
      clockOutTime,
      activeTracking.breakStartTime,
      activeTracking.breakEndTime,
    );

    final updatedTracking = activeTracking.copyWith(
      clockOutTime: clockOutTime,
      status: TimeTrackingStatus.clockedOut,
      totalHours: totalHours,
      updatedAt: DateTime.now(),
    );

    return await _timeTrackingDao.updateTimeTracking(updatedTracking);
  }

  /// Start a break
  Future<TimeTracking> startBreak({
    required String staffMemberId,
    required BreakType breakType,
    String? reason,
  }) async {
    final activeTracking = await getActiveTracking(staffMemberId);
    if (activeTracking == null) {
      throw Exception('No active time tracking found');
    }

    if (activeTracking.status == TimeTrackingStatus.onBreak) {
      throw Exception('Already on break');
    }

    final breakStartTime = DateTime.now();
    final updatedTracking = activeTracking.copyWith(
      breakStartTime: breakStartTime,
      status: TimeTrackingStatus.onBreak,
      updatedAt: DateTime.now(),
    );

    // Create break record
    final breakRecord = BreakRecord.create(
      timeTrackingId: activeTracking.id,
      type: breakType,
      reason: reason,
    );
    await _timeTrackingDao.createBreakRecord(breakRecord);

    return await _timeTrackingDao.updateTimeTracking(updatedTracking);
  }

  /// End a break
  Future<TimeTracking> endBreak({
    required String staffMemberId,
  }) async {
    final activeTracking = await getActiveTracking(staffMemberId);
    if (activeTracking == null) {
      throw Exception('No active time tracking found');
    }

    if (activeTracking.status != TimeTrackingStatus.onBreak) {
      throw Exception('Not currently on break');
    }

    final breakEndTime = DateTime.now();
    final updatedTracking = activeTracking.copyWith(
      breakEndTime: breakEndTime,
      status: TimeTrackingStatus.clockedIn,
      updatedAt: DateTime.now(),
    );

    return await _timeTrackingDao.updateTimeTracking(updatedTracking);
  }

  /// Get active time tracking for a staff member
  Future<TimeTracking?> getActiveTracking(String staffMemberId) async {
    final allTracking = await _timeTrackingDao.getTimeTrackingByStaffMember(staffMemberId);
    return allTracking.where((tracking) => 
      tracking.status == TimeTrackingStatus.clockedIn || 
      tracking.status == TimeTrackingStatus.onBreak
    ).firstOrNull;
  }

  /// Get time tracking records for a staff member
  Future<List<TimeTracking>> getTimeTrackingByStaffMember(String staffMemberId) async {
    return await _timeTrackingDao.getTimeTrackingByStaffMember(staffMemberId);
  }

  /// Get time tracking records for a date range
  Future<List<TimeTracking>> getTimeTrackingByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? staffMemberId,
  }) async {
    return await _timeTrackingDao.getTimeTrackingByDateRange(
      startDate: startDate,
      endDate: endDate,
      staffMemberId: staffMemberId,
    );
  }

  /// Get attendance summary for a staff member
  Future<Map<String, dynamic>> getAttendanceSummary({
    required String staffMemberId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final records = await getTimeTrackingByDateRange(
      startDate: startDate,
      endDate: endDate,
      staffMemberId: staffMemberId,
    );

    double totalHours = 0;
    double overtimeHours = 0;
    int daysWorked = 0;
    int lateArrivals = 0;

    for (final record in records) {
      if (record.clockOutTime != null) {
        totalHours += record.totalHours ?? 0;
        overtimeHours += record.overtimeHours ?? 0;
        daysWorked++;

        // Check for late arrival (assuming 9 AM start time)
        final expectedStartTime = DateTime(
          record.clockInTime.year,
          record.clockInTime.month,
          record.clockInTime.day,
          9, // 9 AM
        );
        if (record.clockInTime.isAfter(expectedStartTime)) {
          lateArrivals++;
        }
      }
    }

    return {
      'totalHours': totalHours,
      'overtimeHours': overtimeHours,
      'daysWorked': daysWorked,
      'lateArrivals': lateArrivals,
      'averageHoursPerDay': daysWorked > 0 ? totalHours / daysWorked : 0,
    };
  }

  /// Calculate total hours worked
  double _calculateTotalHours(
    DateTime clockIn,
    DateTime clockOut,
    DateTime? breakStart,
    DateTime? breakEnd,
  ) {
    final totalDuration = clockOut.difference(clockIn);
    double totalHours = totalDuration.inMinutes / 60.0;

    // Subtract break time if break was taken
    if (breakStart != null && breakEnd != null) {
      final breakDuration = breakEnd.difference(breakStart);
      totalHours -= breakDuration.inMinutes / 60.0;
    }

    return totalHours;
  }

  /// Get break records for a time tracking record
  Future<List<BreakRecord>> getBreakRecords(String timeTrackingId) async {
    return await _timeTrackingDao.getBreakRecords(timeTrackingId);
  }
}
