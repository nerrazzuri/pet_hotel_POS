import 'package:cat_hotel_pos/features/staff/domain/entities/leave_request.dart';
import 'package:cat_hotel_pos/core/services/leave_management_dao.dart';

class LeaveManagementService {
  final LeaveManagementDao _leaveDao;

  LeaveManagementService(this._leaveDao);

  /// Create a new leave request
  Future<LeaveRequest> createLeaveRequest({
    required String staffMemberId,
    required LeaveType type,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
    String? notes,
  }) async {
    // Validate dates
    if (endDate.isBefore(startDate)) {
      throw Exception('End date cannot be before start date');
    }

    if (startDate.isBefore(DateTime.now())) {
      throw Exception('Cannot request leave for past dates');
    }

    // Check leave balance
    final balance = await getLeaveBalance(staffMemberId, startDate.year);
    final requestedDays = endDate.difference(startDate).inDays + 1;
    
    if (!_hasSufficientBalance(balance, type, requestedDays)) {
      throw Exception('Insufficient leave balance');
    }

    // Check for overlapping requests
    final overlappingRequests = await getOverlappingRequests(
      staffMemberId,
      startDate,
      endDate,
    );
    if (overlappingRequests.isNotEmpty) {
      throw Exception('Leave request overlaps with existing approved leave');
    }

    final leaveRequest = LeaveRequest.create(
      staffMemberId: staffMemberId,
      type: type,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
      notes: notes,
    );

    return await _leaveDao.createLeaveRequest(leaveRequest);
  }

  /// Approve a leave request
  Future<LeaveRequest> approveLeaveRequest({
    required String leaveRequestId,
    required String approvedBy,
  }) async {
    final leaveRequest = await _leaveDao.getLeaveRequestById(leaveRequestId);
    if (leaveRequest == null) {
      throw Exception('Leave request not found');
    }

    if (leaveRequest.status != LeaveStatus.pending) {
      throw Exception('Leave request is not pending');
    }

    final updatedRequest = leaveRequest.copyWith(
      status: LeaveStatus.approved,
      approvedBy: approvedBy,
      approvedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Update leave balance
    await _updateLeaveBalance(leaveRequest);

    return await _leaveDao.updateLeaveRequest(updatedRequest);
  }

  /// Reject a leave request
  Future<LeaveRequest> rejectLeaveRequest({
    required String leaveRequestId,
    required String rejectedBy,
    required String rejectionReason,
  }) async {
    final leaveRequest = await _leaveDao.getLeaveRequestById(leaveRequestId);
    if (leaveRequest == null) {
      throw Exception('Leave request not found');
    }

    if (leaveRequest.status != LeaveStatus.pending) {
      throw Exception('Leave request is not pending');
    }

    final updatedRequest = leaveRequest.copyWith(
      status: LeaveStatus.rejected,
      rejectedBy: rejectedBy,
      rejectedAt: DateTime.now(),
      rejectionReason: rejectionReason,
      updatedAt: DateTime.now(),
    );

    return await _leaveDao.updateLeaveRequest(updatedRequest);
  }

  /// Cancel a leave request
  Future<LeaveRequest> cancelLeaveRequest({
    required String leaveRequestId,
  }) async {
    final leaveRequest = await _leaveDao.getLeaveRequestById(leaveRequestId);
    if (leaveRequest == null) {
      throw Exception('Leave request not found');
    }

    if (leaveRequest.status == LeaveStatus.approved) {
      // Restore leave balance if approved
      await _restoreLeaveBalance(leaveRequest);
    }

    final updatedRequest = leaveRequest.copyWith(
      status: LeaveStatus.cancelled,
      updatedAt: DateTime.now(),
    );

    return await _leaveDao.updateLeaveRequest(updatedRequest);
  }

  /// Get leave requests for a staff member
  Future<List<LeaveRequest>> getLeaveRequestsByStaffMember(String staffMemberId) async {
    return await _leaveDao.getLeaveRequestsByStaffMember(staffMemberId);
  }

  /// Get pending leave requests
  Future<List<LeaveRequest>> getPendingLeaveRequests() async {
    return await _leaveDao.getLeaveRequestsByStatus(LeaveStatus.pending);
  }

  /// Get all leave requests
  Future<List<LeaveRequest>> getAllLeaveRequests() async {
    return await _leaveDao.getAllLeaveRequests();
  }

  /// Get leave requests by date range
  Future<List<LeaveRequest>> getLeaveRequestsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? staffMemberId,
  }) async {
    return await _leaveDao.getLeaveRequestsByDateRange(
      startDate: startDate,
      endDate: endDate,
      staffMemberId: staffMemberId,
    );
  }

  /// Get overlapping leave requests
  Future<List<LeaveRequest>> getOverlappingRequests(
    String staffMemberId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final requests = await getLeaveRequestsByStaffMember(staffMemberId);
    return requests.where((request) {
      if (request.status != LeaveStatus.approved) return false;
      
      return (request.startDate.isBefore(endDate) || request.startDate.isAtSameMomentAs(endDate)) &&
             (request.endDate.isAfter(startDate) || request.endDate.isAtSameMomentAs(startDate));
    }).toList();
  }

  /// Get leave balance for a staff member
  Future<LeaveBalance> getLeaveBalance(String staffMemberId, int year) async {
    final balance = await _leaveDao.getLeaveBalance(staffMemberId, year);
    if (balance == null) {
      // Create default balance if not exists
      final newBalance = LeaveBalance.create(
        staffMemberId: staffMemberId,
        year: year,
      );
      return await _leaveDao.createLeaveBalance(newBalance);
    }
    return balance;
  }

  /// Update leave balance after approval
  Future<void> _updateLeaveBalance(LeaveRequest leaveRequest) async {
    final balance = await getLeaveBalance(leaveRequest.staffMemberId, leaveRequest.startDate.year);
    
    LeaveBalance updatedBalance;
    switch (leaveRequest.type) {
      case LeaveType.annual:
        updatedBalance = balance.copyWith(
          annualLeaveUsed: balance.annualLeaveUsed + leaveRequest.totalDays,
          annualLeaveRemaining: balance.annualLeaveRemaining - leaveRequest.totalDays,
          updatedAt: DateTime.now(),
        );
        break;
      case LeaveType.sick:
        updatedBalance = balance.copyWith(
          sickLeaveUsed: balance.sickLeaveUsed + leaveRequest.totalDays,
          sickLeaveRemaining: balance.sickLeaveRemaining - leaveRequest.totalDays,
          updatedAt: DateTime.now(),
        );
        break;
      case LeaveType.personal:
        updatedBalance = balance.copyWith(
          personalLeaveUsed: balance.personalLeaveUsed + leaveRequest.totalDays,
          personalLeaveRemaining: balance.personalLeaveRemaining - leaveRequest.totalDays,
          updatedAt: DateTime.now(),
        );
        break;
      case LeaveType.emergency:
        updatedBalance = balance.copyWith(
          emergencyLeaveUsed: balance.emergencyLeaveUsed + leaveRequest.totalDays,
          emergencyLeaveRemaining: balance.emergencyLeaveRemaining - leaveRequest.totalDays,
          updatedAt: DateTime.now(),
        );
        break;
      default:
        return; // No balance update for other types
    }

    await _leaveDao.updateLeaveBalance(updatedBalance);
  }

  /// Restore leave balance after cancellation
  Future<void> _restoreLeaveBalance(LeaveRequest leaveRequest) async {
    final balance = await getLeaveBalance(leaveRequest.staffMemberId, leaveRequest.startDate.year);
    
    LeaveBalance updatedBalance;
    switch (leaveRequest.type) {
      case LeaveType.annual:
        updatedBalance = balance.copyWith(
          annualLeaveUsed: balance.annualLeaveUsed - leaveRequest.totalDays,
          annualLeaveRemaining: balance.annualLeaveRemaining + leaveRequest.totalDays,
          updatedAt: DateTime.now(),
        );
        break;
      case LeaveType.sick:
        updatedBalance = balance.copyWith(
          sickLeaveUsed: balance.sickLeaveUsed - leaveRequest.totalDays,
          sickLeaveRemaining: balance.sickLeaveRemaining + leaveRequest.totalDays,
          updatedAt: DateTime.now(),
        );
        break;
      case LeaveType.personal:
        updatedBalance = balance.copyWith(
          personalLeaveUsed: balance.personalLeaveUsed - leaveRequest.totalDays,
          personalLeaveRemaining: balance.personalLeaveRemaining + leaveRequest.totalDays,
          updatedAt: DateTime.now(),
        );
        break;
      case LeaveType.emergency:
        updatedBalance = balance.copyWith(
          emergencyLeaveUsed: balance.emergencyLeaveUsed - leaveRequest.totalDays,
          emergencyLeaveRemaining: balance.emergencyLeaveRemaining + leaveRequest.totalDays,
          updatedAt: DateTime.now(),
        );
        break;
      default:
        return; // No balance update for other types
    }

    await _leaveDao.updateLeaveBalance(updatedBalance);
  }

  /// Check if staff member has sufficient leave balance
  bool _hasSufficientBalance(LeaveBalance balance, LeaveType type, int requestedDays) {
    switch (type) {
      case LeaveType.annual:
        return balance.annualLeaveRemaining >= requestedDays;
      case LeaveType.sick:
        return balance.sickLeaveRemaining >= requestedDays;
      case LeaveType.personal:
        return balance.personalLeaveRemaining >= requestedDays;
      case LeaveType.emergency:
        return balance.emergencyLeaveRemaining >= requestedDays;
      default:
        return true; // No balance check for other types
    }
  }

  /// Get leave calendar for a month
  Future<Map<DateTime, List<LeaveRequest>>> getLeaveCalendar({
    required int year,
    required int month,
  }) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);
    
    final requests = await getLeaveRequestsByDateRange(
      startDate: startDate,
      endDate: endDate,
    );

    final calendar = <DateTime, List<LeaveRequest>>{};
    
    for (final request in requests) {
      if (request.status == LeaveStatus.approved) {
        var currentDate = request.startDate;
        while (currentDate.isBefore(request.endDate) || currentDate.isAtSameMomentAs(request.endDate)) {
          final dateKey = DateTime(currentDate.year, currentDate.month, currentDate.day);
          calendar.putIfAbsent(dateKey, () => []).add(request);
          currentDate = currentDate.add(const Duration(days: 1));
        }
      }
    }

    return calendar;
  }

  /// Get leave statistics for a staff member
  Future<Map<String, dynamic>> getLeaveStatistics({
    required String staffMemberId,
    required int year,
  }) async {
    final balance = await getLeaveBalance(staffMemberId, year);
    final requests = await getLeaveRequestsByStaffMember(staffMemberId);
    
    final yearRequests = requests.where((request) => 
      request.startDate.year == year
    ).toList();

    final approvedRequests = yearRequests.where((request) => 
      request.status == LeaveStatus.approved
    ).toList();

    final pendingRequests = yearRequests.where((request) => 
      request.status == LeaveStatus.pending
    ).toList();

    final totalDaysTaken = approvedRequests.fold<int>(
      0, (sum, request) => sum + request.totalDays
    );

    return {
      'balance': balance,
      'totalRequests': yearRequests.length,
      'approvedRequests': approvedRequests.length,
      'pendingRequests': pendingRequests.length,
      'totalDaysTaken': totalDaysTaken,
      'requestsByType': _groupRequestsByType(approvedRequests),
    };
  }

  /// Group requests by type
  Map<LeaveType, int> _groupRequestsByType(List<LeaveRequest> requests) {
    final Map<LeaveType, int> grouped = {};
    for (final request in requests) {
      grouped[request.type] = (grouped[request.type] ?? 0) + request.totalDays;
    }
    return grouped;
  }
}
