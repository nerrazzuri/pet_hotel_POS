import 'package:cat_hotel_pos/features/staff/domain/entities/time_tracking.dart';
import 'package:cat_hotel_pos/core/services/web_storage_service.dart';

class TimeTrackingDao {
  static const String _timeTrackingKey = 'time_tracking';
  static const String _breakRecordsKey = 'break_records';

  /// Get all time tracking records
  Future<List<TimeTracking>> getAllTimeTracking() async {
    try {
      final data = WebStorageService.getData(_timeTrackingKey);
      if (data == null || data.isEmpty) {
        return [];
      }
      
      final List<dynamic> jsonList = data;
      return jsonList
          .map((json) => TimeTracking.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting time tracking records: $e');
      return [];
    }
  }

  /// Get time tracking by ID
  Future<TimeTracking?> getTimeTrackingById(String id) async {
    try {
      final records = await getAllTimeTracking();
      return records.where((record) => record.id == id).firstOrNull;
    } catch (e) {
      print('Error getting time tracking by ID: $e');
      return null;
    }
  }

  /// Get time tracking records for a specific staff member
  Future<List<TimeTracking>> getTimeTrackingByStaffMember(String staffMemberId) async {
    try {
      final records = await getAllTimeTracking();
      return records.where((record) => record.staffMemberId == staffMemberId).toList();
    } catch (e) {
      print('Error getting time tracking by staff member: $e');
      return [];
    }
  }

  /// Get time tracking records by date range
  Future<List<TimeTracking>> getTimeTrackingByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? staffMemberId,
  }) async {
    try {
      final records = await getAllTimeTracking();
      return records.where((record) {
        final recordDate = DateTime(
          record.clockInTime.year,
          record.clockInTime.month,
          record.clockInTime.day,
        );
        final start = DateTime(startDate.year, startDate.month, startDate.day);
        final end = DateTime(endDate.year, endDate.month, endDate.day);
        
        final inDateRange = recordDate.isAtSameMomentAs(start) || 
                           recordDate.isAtSameMomentAs(end) ||
                           (recordDate.isAfter(start) && recordDate.isBefore(end));
        
        if (staffMemberId != null) {
          return inDateRange && record.staffMemberId == staffMemberId;
        }
        return inDateRange;
      }).toList();
    } catch (e) {
      print('Error getting time tracking by date range: $e');
      return [];
    }
  }

  /// Create a new time tracking record
  Future<TimeTracking> createTimeTracking(TimeTracking timeTracking) async {
    try {
      final records = await getAllTimeTracking();
      records.add(timeTracking);
      await _saveTimeTracking(records);
      return timeTracking;
    } catch (e) {
      throw Exception('Failed to create time tracking: $e');
    }
  }

  /// Update an existing time tracking record
  Future<TimeTracking> updateTimeTracking(TimeTracking timeTracking) async {
    try {
      final records = await getAllTimeTracking();
      final index = records.indexWhere((record) => record.id == timeTracking.id);
      if (index == -1) {
        throw Exception('Time tracking record not found');
      }
      
      records[index] = timeTracking;
      await _saveTimeTracking(records);
      return timeTracking;
    } catch (e) {
      throw Exception('Failed to update time tracking: $e');
    }
  }

  /// Delete a time tracking record
  Future<bool> deleteTimeTracking(String id) async {
    try {
      final records = await getAllTimeTracking();
      records.removeWhere((record) => record.id == id);
      await _saveTimeTracking(records);
      return true;
    } catch (e) {
      print('Error deleting time tracking: $e');
      return false;
    }
  }

  /// Get all break records
  Future<List<BreakRecord>> getAllBreakRecords() async {
    try {
      final data = WebStorageService.getData(_breakRecordsKey);
      if (data == null || data.isEmpty) {
        return [];
      }
      
      final List<dynamic> jsonList = data;
      return jsonList
          .map((json) => BreakRecord.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting break records: $e');
      return [];
    }
  }

  /// Get break records for a specific time tracking record
  Future<List<BreakRecord>> getBreakRecords(String timeTrackingId) async {
    try {
      final records = await getAllBreakRecords();
      return records.where((record) => record.timeTrackingId == timeTrackingId).toList();
    } catch (e) {
      print('Error getting break records: $e');
      return [];
    }
  }

  /// Create a new break record
  Future<BreakRecord> createBreakRecord(BreakRecord breakRecord) async {
    try {
      final records = await getAllBreakRecords();
      records.add(breakRecord);
      await _saveBreakRecords(records);
      return breakRecord;
    } catch (e) {
      throw Exception('Failed to create break record: $e');
    }
  }

  /// Update an existing break record
  Future<BreakRecord> updateBreakRecord(BreakRecord breakRecord) async {
    try {
      final records = await getAllBreakRecords();
      final index = records.indexWhere((record) => record.id == breakRecord.id);
      if (index == -1) {
        throw Exception('Break record not found');
      }
      
      records[index] = breakRecord;
      await _saveBreakRecords(records);
      return breakRecord;
    } catch (e) {
      throw Exception('Failed to update break record: $e');
    }
  }

  /// Save time tracking records to storage
  Future<void> _saveTimeTracking(List<TimeTracking> records) async {
    try {
      final jsonList = records.map((record) => record.toJson()).toList();
      WebStorageService.saveData(_timeTrackingKey, jsonList);
    } catch (e) {
      throw Exception('Failed to save time tracking: $e');
    }
  }

  /// Save break records to storage
  Future<void> _saveBreakRecords(List<BreakRecord> records) async {
    try {
      final jsonList = records.map((record) => record.toJson()).toList();
      WebStorageService.saveData(_breakRecordsKey, jsonList);
    } catch (e) {
      throw Exception('Failed to save break records: $e');
    }
  }

  /// Clear all time tracking data (for testing/reset)
  Future<void> clearAllTimeTracking() async {
    try {
      WebStorageService.removeData(_timeTrackingKey);
      WebStorageService.removeData(_breakRecordsKey);
    } catch (e) {
      print('Error clearing time tracking data: $e');
    }
  }
}
