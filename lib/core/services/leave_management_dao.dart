import 'package:cat_hotel_pos/features/staff/domain/entities/leave_request.dart';
import 'package:cat_hotel_pos/core/services/web_storage_service.dart';

class LeaveManagementDao {
  static const String _leaveRequestsKey = 'leave_requests';
  static const String _leaveBalancesKey = 'leave_balances';

  /// Get all leave requests
  Future<List<LeaveRequest>> getAllLeaveRequests() async {
    try {
      final data = WebStorageService.getData(_leaveRequestsKey);
      if (data == null || data.isEmpty) {
        return [];
      }
      
      final List<dynamic> jsonList = data;
      return jsonList
          .map((json) => LeaveRequest.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting leave requests: $e');
      return [];
    }
  }

  /// Get leave request by ID
  Future<LeaveRequest?> getLeaveRequestById(String id) async {
    try {
      final requests = await getAllLeaveRequests();
      return requests.where((request) => request.id == id).firstOrNull;
    } catch (e) {
      print('Error getting leave request by ID: $e');
      return null;
    }
  }

  /// Get leave requests for a specific staff member
  Future<List<LeaveRequest>> getLeaveRequestsByStaffMember(String staffMemberId) async {
    try {
      final requests = await getAllLeaveRequests();
      return requests.where((request) => request.staffMemberId == staffMemberId).toList();
    } catch (e) {
      print('Error getting leave requests by staff member: $e');
      return [];
    }
  }

  /// Get leave requests by status
  Future<List<LeaveRequest>> getLeaveRequestsByStatus(LeaveStatus status) async {
    try {
      final requests = await getAllLeaveRequests();
      return requests.where((request) => request.status == status).toList();
    } catch (e) {
      print('Error getting leave requests by status: $e');
      return [];
    }
  }

  /// Get leave requests by date range
  Future<List<LeaveRequest>> getLeaveRequestsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? staffMemberId,
  }) async {
    try {
      final requests = await getAllLeaveRequests();
      return requests.where((request) {
        final inDateRange = (request.startDate.isAfter(startDate) || request.startDate.isAtSameMomentAs(startDate)) &&
                           (request.endDate.isBefore(endDate) || request.endDate.isAtSameMomentAs(endDate));
        
        if (staffMemberId != null) {
          return inDateRange && request.staffMemberId == staffMemberId;
        }
        return inDateRange;
      }).toList();
    } catch (e) {
      print('Error getting leave requests by date range: $e');
      return [];
    }
  }

  /// Create a new leave request
  Future<LeaveRequest> createLeaveRequest(LeaveRequest leaveRequest) async {
    try {
      final requests = await getAllLeaveRequests();
      requests.add(leaveRequest);
      await _saveLeaveRequests(requests);
      return leaveRequest;
    } catch (e) {
      throw Exception('Failed to create leave request: $e');
    }
  }

  /// Update an existing leave request
  Future<LeaveRequest> updateLeaveRequest(LeaveRequest leaveRequest) async {
    try {
      final requests = await getAllLeaveRequests();
      final index = requests.indexWhere((request) => request.id == leaveRequest.id);
      if (index == -1) {
        throw Exception('Leave request not found');
      }
      
      requests[index] = leaveRequest;
      await _saveLeaveRequests(requests);
      return leaveRequest;
    } catch (e) {
      throw Exception('Failed to update leave request: $e');
    }
  }

  /// Delete a leave request
  Future<bool> deleteLeaveRequest(String id) async {
    try {
      final requests = await getAllLeaveRequests();
      requests.removeWhere((request) => request.id == id);
      await _saveLeaveRequests(requests);
      return true;
    } catch (e) {
      print('Error deleting leave request: $e');
      return false;
    }
  }

  /// Get all leave balances
  Future<List<LeaveBalance>> getAllLeaveBalances() async {
    try {
      final data = WebStorageService.getData(_leaveBalancesKey);
      if (data == null || data.isEmpty) {
        return [];
      }
      
      final List<dynamic> jsonList = data;
      return jsonList
          .map((json) => LeaveBalance.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting leave balances: $e');
      return [];
    }
  }

  /// Get leave balance for a staff member and year
  Future<LeaveBalance?> getLeaveBalance(String staffMemberId, int year) async {
    try {
      final balances = await getAllLeaveBalances();
      return balances.where((balance) => 
        balance.staffMemberId == staffMemberId && balance.year == year
      ).firstOrNull;
    } catch (e) {
      print('Error getting leave balance: $e');
      return null;
    }
  }

  /// Create a new leave balance
  Future<LeaveBalance> createLeaveBalance(LeaveBalance leaveBalance) async {
    try {
      final balances = await getAllLeaveBalances();
      balances.add(leaveBalance);
      await _saveLeaveBalances(balances);
      return leaveBalance;
    } catch (e) {
      throw Exception('Failed to create leave balance: $e');
    }
  }

  /// Update an existing leave balance
  Future<LeaveBalance> updateLeaveBalance(LeaveBalance leaveBalance) async {
    try {
      final balances = await getAllLeaveBalances();
      final index = balances.indexWhere((balance) => balance.id == leaveBalance.id);
      if (index == -1) {
        throw Exception('Leave balance not found');
      }
      
      balances[index] = leaveBalance;
      await _saveLeaveBalances(balances);
      return leaveBalance;
    } catch (e) {
      throw Exception('Failed to update leave balance: $e');
    }
  }

  /// Save leave requests to storage
  Future<void> _saveLeaveRequests(List<LeaveRequest> requests) async {
    try {
      final jsonList = requests.map((request) => request.toJson()).toList();
      WebStorageService.saveData(_leaveRequestsKey, jsonList);
    } catch (e) {
      throw Exception('Failed to save leave requests: $e');
    }
  }

  /// Save leave balances to storage
  Future<void> _saveLeaveBalances(List<LeaveBalance> balances) async {
    try {
      final jsonList = balances.map((balance) => balance.toJson()).toList();
      WebStorageService.saveData(_leaveBalancesKey, jsonList);
    } catch (e) {
      throw Exception('Failed to save leave balances: $e');
    }
  }

  /// Clear all leave management data (for testing/reset)
  Future<void> clearAllLeaveData() async {
    try {
      WebStorageService.removeData(_leaveRequestsKey);
      WebStorageService.removeData(_leaveBalancesKey);
    } catch (e) {
      print('Error clearing leave data: $e');
    }
  }
}
