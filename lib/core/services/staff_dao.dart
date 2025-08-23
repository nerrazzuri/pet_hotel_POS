import 'package:cat_hotel_pos/features/staff/domain/entities/staff_member.dart';
import 'package:cat_hotel_pos/features/staff/domain/entities/shift.dart';

class StaffDao {
  static final List<StaffMember> _staffMembers = [
    StaffMember.create(
      employeeId: 'EMP001',
      fullName: 'Sarah Johnson',
      email: 'sarah.johnson@cathotel.com',
      phone: '+60123456789',
      role: StaffRole.manager,
      department: 'Management',
      position: 'General Manager',
      hourlyRate: 25.0,
      emergencyContact: 'John Johnson',
      emergencyPhone: '+60123456788',
      address: '123 Main Street, Kuala Lumpur',
      notes: 'Experienced manager with 5+ years in hospitality',
    ),
    StaffMember.create(
      employeeId: 'EMP002',
      fullName: 'Ahmad Rahman',
      email: 'ahmad.rahman@cathotel.com',
      phone: '+60123456790',
      role: StaffRole.cashier,
      department: 'Front Office',
      position: 'Senior Cashier',
      hourlyRate: 18.0,
      emergencyContact: 'Fatimah Rahman',
      emergencyPhone: '+60123456791',
      address: '456 Oak Avenue, Petaling Jaya',
      notes: 'Excellent customer service skills',
    ),
    StaffMember.create(
      employeeId: 'EMP003',
      fullName: 'Lisa Chen',
      email: 'lisa.chen@cathotel.com',
      phone: '+60123456792',
      role: StaffRole.groomer,
      department: 'Grooming',
      position: 'Master Groomer',
      hourlyRate: 22.0,
      emergencyContact: 'David Chen',
      emergencyPhone: '+60123456793',
      address: '789 Pine Road, Subang Jaya',
      notes: 'Certified pet groomer with 8+ years experience',
    ),
    StaffMember.create(
      employeeId: 'EMP004',
      fullName: 'Raj Kumar',
      email: 'raj.kumar@cathotel.com',
      phone: '+60123456794',
      role: StaffRole.housekeeper,
      department: 'Housekeeping',
      position: 'Senior Housekeeper',
      hourlyRate: 16.0,
      emergencyContact: 'Priya Kumar',
      emergencyPhone: '+60123456795',
      address: '321 Elm Street, Shah Alam',
      notes: 'Dedicated and thorough in cleaning duties',
    ),
    StaffMember.create(
      employeeId: 'EMP005',
      fullName: 'Nurul Huda',
      email: 'nurul.huda@cathotel.com',
      phone: '+60123456796',
      role: StaffRole.receptionist,
      department: 'Front Office',
      position: 'Receptionist',
      hourlyRate: 17.0,
      emergencyContact: 'Ahmad Huda',
      emergencyPhone: '+60123456797',
      address: '654 Maple Drive, Klang',
      notes: 'Friendly and efficient front desk service',
    ),
    StaffMember.create(
      employeeId: 'EMP006',
      fullName: 'Dr. Michael Wong',
      email: 'michael.wong@cathotel.com',
      phone: '+60123456798',
      role: StaffRole.veterinarian,
      department: 'Medical',
      position: 'Veterinarian',
      hourlyRate: 35.0,
      emergencyContact: 'Jennifer Wong',
      emergencyPhone: '+60123456799',
      address: '987 Cedar Lane, Damansara',
      notes: 'Licensed veterinarian with 10+ years experience',
    ),
  ];

  static final List<Shift> _shifts = [
    Shift.create(
      staffMemberId: _staffMembers[0].id,
      startTime: DateTime.now().add(const Duration(days: 1)),
      notes: 'Morning shift',
    ),
    Shift.create(
      staffMemberId: _staffMembers[1].id,
      startTime: DateTime.now().add(const Duration(days: 1)),
      notes: 'Cashier shift',
    ),
    Shift.create(
      staffMemberId: _staffMembers[2].id,
      startTime: DateTime.now().add(const Duration(days: 1)),
      notes: 'Grooming appointments',
    ),
  ];

  // Staff Member operations
  Future<List<StaffMember>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_staffMembers);
  }

  Future<StaffMember?> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _staffMembers.firstWhere((staff) => staff.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<StaffMember?> getByEmployeeId(String employeeId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _staffMembers.firstWhere((staff) => staff.employeeId == employeeId);
    } catch (e) {
      return null;
    }
  }

  Future<StaffMember?> getByEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _staffMembers.firstWhere((staff) => staff.email == email);
    } catch (e) {
      return null;
    }
  }

  Future<List<StaffMember>> getByRole(StaffRole role) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _staffMembers.where((staff) => staff.role == role).toList();
  }

  Future<List<StaffMember>> getByStatus(StaffStatus status) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _staffMembers.where((staff) => staff.status == status).toList();
  }

  Future<StaffMember> create(StaffMember staffMember) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _staffMembers.add(staffMember);
    return staffMember;
  }

  Future<StaffMember> update(StaffMember staffMember) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _staffMembers.indexWhere((staff) => staff.id == staffMember.id);
    if (index != -1) {
      _staffMembers[index] = staffMember;
    }
    return staffMember;
  }

  Future<bool> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _staffMembers.indexWhere((staff) => staff.id == id);
    if (index != -1) {
      _staffMembers.removeAt(index);
      return true;
    }
    return false;
  }

  Future<List<StaffMember>> search(String query) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final lowercaseQuery = query.toLowerCase();
    return _staffMembers.where((staff) {
      return staff.fullName.toLowerCase().contains(lowercaseQuery) ||
          staff.employeeId.toLowerCase().contains(lowercaseQuery) ||
          staff.email.toLowerCase().contains(lowercaseQuery) ||
          staff.phone.contains(query);
    }).toList();
  }

  // Shift operations
  Future<List<Shift>> getAllShifts() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_shifts);
  }

  Future<List<Shift>> getShiftsByStaffMember(String staffMemberId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _shifts.where((shift) => shift.staffMemberId == staffMemberId).toList();
  }

  Future<List<Shift>> getShiftsByDateRange(DateTime startDate, DateTime endDate) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _shifts.where((shift) {
      return shift.startTime.isAfter(startDate.subtract(const Duration(days: 1))) &&
          shift.startTime.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  Future<Shift> createShift(Shift shift) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _shifts.add(shift);
    return shift;
  }

  Future<Shift> updateShift(Shift shift) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _shifts.indexWhere((s) => s.id == shift.id);
    if (index != -1) {
      _shifts[index] = shift;
    }
    return shift;
  }

  Future<bool> deleteShift(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _shifts.indexWhere((shift) => shift.id == id);
    if (index != -1) {
      _shifts.removeAt(index);
      return true;
    }
    return false;
  }

  // Statistics
  Future<Map<String, dynamic>> getStaffStatistics() async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final totalStaff = _staffMembers.length;
    final activeStaff = _staffMembers.where((staff) => staff.status == StaffStatus.active).length;
    final roleDistribution = <StaffRole, int>{};
    
    for (final staff in _staffMembers) {
      roleDistribution[staff.role] = (roleDistribution[staff.role] ?? 0) + 1;
    }
    
    final totalShifts = _shifts.length;
    final completedShifts = _shifts.where((shift) => shift.status == ShiftStatus.completed).length;
    
    return {
      'totalStaff': totalStaff,
      'activeStaff': activeStaff,
      'roleDistribution': roleDistribution.map((key, value) => MapEntry(key.displayName, value)),
      'totalShifts': totalShifts,
      'completedShifts': completedShifts,
      'completionRate': totalShifts > 0 ? (completedShifts / totalShifts * 100).roundToDouble() : 0.0,
    };
  }
}
