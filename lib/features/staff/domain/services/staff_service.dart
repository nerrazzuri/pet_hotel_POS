import 'package:cat_hotel_pos/core/services/staff_dao.dart';
import 'package:cat_hotel_pos/features/staff/domain/entities/staff_member.dart';
import 'package:cat_hotel_pos/features/staff/domain/entities/shift.dart';

class StaffService {
  final StaffDao _staffDao;

  StaffService(this._staffDao);

  // Staff Member operations
  Future<List<StaffMember>> getAllStaffMembers() async {
    return await _staffDao.getAll();
  }

  Future<StaffMember?> getStaffMemberById(String id) async {
    return await _staffDao.getById(id);
  }

  Future<StaffMember?> getStaffMemberByEmployeeId(String employeeId) async {
    return await _staffDao.getByEmployeeId(employeeId);
  }

  Future<StaffMember?> getStaffMemberByEmail(String email) async {
    return await _staffDao.getByEmail(email);
  }

  Future<List<StaffMember>> getStaffMembersByRole(StaffRole role) async {
    return await _staffDao.getByRole(role);
  }

  Future<List<StaffMember>> getStaffMembersByStatus(StaffStatus status) async {
    return await _staffDao.getByStatus(status);
  }

  Future<StaffMember> createStaffMember(StaffMember staffMember) async {
    // Validate employee ID uniqueness
    final existing = await _staffDao.getByEmployeeId(staffMember.employeeId);
    if (existing != null) {
      throw Exception('Employee ID already exists');
    }

    // Validate email uniqueness
    final existingEmail = await _staffDao.getByEmail(staffMember.email);
    if (existingEmail != null) {
      throw Exception('Email already exists');
    }

    return await _staffDao.create(staffMember);
  }

  Future<StaffMember> updateStaffMember(StaffMember staffMember) async {
    // Check if staff member exists
    final existing = await _staffDao.getById(staffMember.id);
    if (existing == null) {
      throw Exception('Staff member not found');
    }

    // Validate email uniqueness (excluding current staff member)
    final existingEmail = await _staffDao.getByEmail(staffMember.email);
    if (existingEmail != null && existingEmail.id != staffMember.id) {
      throw Exception('Email already exists');
    }

    return await _staffDao.update(staffMember);
  }

  Future<bool> deleteStaffMember(String id) async {
    // Check if staff member has active shifts
    final shifts = await _staffDao.getShiftsByStaffMember(id);
    final hasActiveShifts = shifts.any((shift) => 
        shift.status == ShiftStatus.scheduled || shift.status == ShiftStatus.active);
    
    if (hasActiveShifts) {
      throw Exception('Cannot delete staff member with active shifts');
    }

    return await _staffDao.delete(id);
  }

  Future<List<StaffMember>> searchStaffMembers(String query) async {
    if (query.trim().isEmpty) {
      return await _staffDao.getAll();
    }
    return await _staffDao.search(query);
  }

  // Shift operations
  Future<List<Shift>> getAllShifts() async {
    return await _staffDao.getAllShifts();
  }

  Future<List<Shift>> getShiftsByStaffMember(String staffMemberId) async {
    return await _staffDao.getShiftsByStaffMember(staffMemberId);
  }

  Future<List<Shift>> getShiftsByDateRange(DateTime startDate, DateTime endDate) async {
    if (startDate.isAfter(endDate)) {
      throw Exception('Start date cannot be after end date');
    }
    return await _staffDao.getShiftsByDateRange(startDate, endDate);
  }

  Future<Shift> createShift(Shift shift) async {
    // Validate staff member exists
    final staffMember = await _staffDao.getById(shift.staffMemberId);
    if (staffMember == null) {
      throw Exception('Staff member not found');
    }

    // Check for shift conflicts
    final existingShifts = await _staffDao.getShiftsByStaffMember(shift.staffMemberId);
    final hasConflict = existingShifts.any((existingShift) {
      if (existingShift.status == ShiftStatus.cancelled) return false;
      
      final shiftStart = shift.startTime;
      final shiftEnd = shift.startTime.add(const Duration(hours: 8)); // Default 8-hour shift
      final existingStart = existingShift.startTime;
      final existingEnd = existingShift.endTime ?? existingShift.startTime.add(const Duration(hours: 8));
      
      return (shiftStart.isBefore(existingEnd) && shiftEnd.isAfter(existingStart));
    });

    if (hasConflict) {
      throw Exception('Shift conflicts with existing schedule');
    }

    return await _staffDao.createShift(shift);
  }

  Future<Shift> updateShift(Shift shift) async {
    // Check if shift exists
    final existing = await _staffDao.getAllShifts();
    final shiftExists = existing.any((s) => s.id == shift.id);
    if (!shiftExists) {
      throw Exception('Shift not found');
    }

    return await _staffDao.updateShift(shift);
  }

  Future<bool> deleteShift(String id) async {
    // Check if shift is active
    final shifts = await _staffDao.getAllShifts();
    final shift = shifts.firstWhere((s) => s.id == id);
    
    if (shift.status == ShiftStatus.active) {
      throw Exception('Cannot delete active shift');
    }

    return await _staffDao.deleteShift(id);
  }

  Future<Shift> startShift(String shiftId) async {
    final shifts = await _staffDao.getAllShifts();
    final shift = shifts.firstWhere((s) => s.id == shiftId);
    
    if (shift.status != ShiftStatus.scheduled) {
      throw Exception('Only scheduled shifts can be started');
    }

    final updatedShift = shift.copyWith(
      status: ShiftStatus.active,
      updatedAt: DateTime.now(),
    );

    return await _staffDao.updateShift(updatedShift);
  }

  Future<Shift> endShift(String shiftId, {double? actualHours, double? overtimeHours}) async {
    final shifts = await _staffDao.getAllShifts();
    final shift = shifts.firstWhere((s) => s.id == shiftId);
    
    if (shift.status != ShiftStatus.active) {
      throw Exception('Only active shifts can be ended');
    }

    final updatedShift = shift.copyWith(
      status: ShiftStatus.completed,
      endTime: DateTime.now(),
      actualHours: actualHours,
      overtimeHours: overtimeHours,
      updatedAt: DateTime.now(),
    );

    return await _staffDao.updateShift(updatedShift);
  }

  // Business logic operations
  Future<Map<String, dynamic>> getStaffStatistics() async {
    return await _staffDao.getStaffStatistics();
  }

  Future<double> calculatePayroll(DateTime startDate, DateTime endDate) async {
    final shifts = await _staffDao.getShiftsByDateRange(startDate, endDate);
    double totalPayroll = 0.0;

    for (final shift in shifts) {
      if (shift.status == ShiftStatus.completed && shift.actualHours != null) {
        final staffMember = await _staffDao.getById(shift.staffMemberId);
        if (staffMember?.hourlyRate != null) {
          double shiftPay = shift.actualHours! * staffMember!.hourlyRate!;
          
          // Add overtime pay (1.5x rate for hours over 8)
          if (shift.overtimeHours != null && shift.overtimeHours! > 0) {
            shiftPay += shift.overtimeHours! * staffMember.hourlyRate! * 0.5;
          }
          
          totalPayroll += shiftPay;
        }
      }
    }

    return totalPayroll;
  }

  Future<List<StaffMember>> getAvailableStaff(DateTime dateTime) async {
    final allStaff = await _staffDao.getAll();
    final activeStaff = allStaff.where((staff) => staff.status == StaffStatus.active).toList();
    
    // Filter out staff with conflicting shifts
    final availableStaff = <StaffMember>[];
    
    for (final staff in activeStaff) {
      final shifts = await _staffDao.getShiftsByStaffMember(staff.id);
      final hasConflict = shifts.any((shift) {
        if (shift.status == ShiftStatus.cancelled) return false;
        
        final shiftStart = shift.startTime;
        final shiftEnd = shift.endTime ?? shift.startTime.add(const Duration(hours: 8));
        
        return dateTime.isAfter(shiftStart.subtract(const Duration(hours: 1))) &&
               dateTime.isBefore(shiftEnd.add(const Duration(hours: 1)));
      });
      
      if (!hasConflict) {
        availableStaff.add(staff);
      }
    }
    
    return availableStaff;
  }

  Future<void> deactivateStaffMember(String id, String reason) async {
    final staffMember = await _staffDao.getById(id);
    if (staffMember == null) {
      throw Exception('Staff member not found');
    }

    final updatedStaffMember = staffMember.copyWith(
      status: StaffStatus.inactive,
      notes: '${staffMember.notes ?? ''}\n\nDeactivated: $reason',
      updatedAt: DateTime.now(),
    );

    await _staffDao.update(updatedStaffMember);
  }

  Future<void> reactivateStaffMember(String id) async {
    final staffMember = await _staffDao.getById(id);
    if (staffMember == null) {
      throw Exception('Staff member not found');
    }

    final updatedStaffMember = staffMember.copyWith(
      status: StaffStatus.active,
      notes: '${staffMember.notes ?? ''}\n\nReactivated: ${DateTime.now()}',
      updatedAt: DateTime.now(),
    );

    await _staffDao.update(updatedStaffMember);
  }
}
