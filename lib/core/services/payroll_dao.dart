import 'package:cat_hotel_pos/features/staff/domain/entities/payroll.dart';
import 'package:cat_hotel_pos/core/services/web_storage_service.dart';

class PayrollDao {
  static const String _payrollRecordsKey = 'payroll_records';
  static const String _allowancesKey = 'payroll_allowances';
  static const String _deductionsKey = 'payroll_deductions';

  /// Get all payroll records
  Future<List<PayrollRecord>> getAllPayrollRecords() async {
    try {
      final data = WebStorageService.getData(_payrollRecordsKey);
      if (data == null || data.isEmpty) {
        return [];
      }
      
      final List<dynamic> jsonList = data;
      return jsonList
          .map((json) => PayrollRecord.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting payroll records: $e');
      return [];
    }
  }

  /// Get payroll record by ID
  Future<PayrollRecord?> getPayrollRecordById(String id) async {
    try {
      final records = await getAllPayrollRecords();
      return records.where((record) => record.id == id).firstOrNull;
    } catch (e) {
      print('Error getting payroll record by ID: $e');
      return null;
    }
  }

  /// Get payroll records for a specific staff member
  Future<List<PayrollRecord>> getPayrollRecordsByStaffMember(String staffMemberId) async {
    try {
      final records = await getAllPayrollRecords();
      return records.where((record) => record.staffMemberId == staffMemberId).toList();
    } catch (e) {
      print('Error getting payroll records by staff member: $e');
      return [];
    }
  }

  /// Get payroll records by date range
  Future<List<PayrollRecord>> getPayrollRecordsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? staffMemberId,
  }) async {
    try {
      final records = await getAllPayrollRecords();
      return records.where((record) {
        final inDateRange = (record.payPeriodStart.isAfter(startDate) || record.payPeriodStart.isAtSameMomentAs(startDate)) &&
                           (record.payPeriodEnd.isBefore(endDate) || record.payPeriodEnd.isAtSameMomentAs(endDate));
        
        if (staffMemberId != null) {
          return inDateRange && record.staffMemberId == staffMemberId;
        }
        return inDateRange;
      }).toList();
    } catch (e) {
      print('Error getting payroll records by date range: $e');
      return [];
    }
  }

  /// Create a new payroll record
  Future<PayrollRecord> createPayrollRecord(PayrollRecord payrollRecord) async {
    try {
      final records = await getAllPayrollRecords();
      records.add(payrollRecord);
      await _savePayrollRecords(records);
      return payrollRecord;
    } catch (e) {
      throw Exception('Failed to create payroll record: $e');
    }
  }

  /// Update an existing payroll record
  Future<PayrollRecord> updatePayrollRecord(PayrollRecord payrollRecord) async {
    try {
      final records = await getAllPayrollRecords();
      final index = records.indexWhere((record) => record.id == payrollRecord.id);
      if (index == -1) {
        throw Exception('Payroll record not found');
      }
      
      records[index] = payrollRecord;
      await _savePayrollRecords(records);
      return payrollRecord;
    } catch (e) {
      throw Exception('Failed to update payroll record: $e');
    }
  }

  /// Delete a payroll record
  Future<bool> deletePayrollRecord(String id) async {
    try {
      final records = await getAllPayrollRecords();
      records.removeWhere((record) => record.id == id);
      await _savePayrollRecords(records);
      return true;
    } catch (e) {
      print('Error deleting payroll record: $e');
      return false;
    }
  }

  /// Get all allowances
  Future<List<PayrollAllowance>> getAllAllowances() async {
    try {
      final data = WebStorageService.getData(_allowancesKey);
      if (data == null || data.isEmpty) {
        return [];
      }
      
      final List<dynamic> jsonList = data;
      return jsonList
          .map((json) => PayrollAllowance.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting allowances: $e');
      return [];
    }
  }

  /// Get allowances for a specific payroll record
  Future<List<PayrollAllowance>> getAllowances(String payrollRecordId) async {
    try {
      final allowances = await getAllAllowances();
      return allowances.where((allowance) => allowance.payrollRecordId == payrollRecordId).toList();
    } catch (e) {
      print('Error getting allowances: $e');
      return [];
    }
  }

  /// Create a new allowance
  Future<PayrollAllowance> createAllowance(PayrollAllowance allowance) async {
    try {
      final allowances = await getAllAllowances();
      allowances.add(allowance);
      await _saveAllowances(allowances);
      return allowance;
    } catch (e) {
      throw Exception('Failed to create allowance: $e');
    }
  }

  /// Update an existing allowance
  Future<PayrollAllowance> updateAllowance(PayrollAllowance allowance) async {
    try {
      final allowances = await getAllAllowances();
      final index = allowances.indexWhere((a) => a.id == allowance.id);
      if (index == -1) {
        throw Exception('Allowance not found');
      }
      
      allowances[index] = allowance;
      await _saveAllowances(allowances);
      return allowance;
    } catch (e) {
      throw Exception('Failed to update allowance: $e');
    }
  }

  /// Delete an allowance
  Future<bool> deleteAllowance(String id) async {
    try {
      final allowances = await getAllAllowances();
      allowances.removeWhere((allowance) => allowance.id == id);
      await _saveAllowances(allowances);
      return true;
    } catch (e) {
      print('Error deleting allowance: $e');
      return false;
    }
  }

  /// Get all deductions
  Future<List<PayrollDeduction>> getAllDeductions() async {
    try {
      final data = WebStorageService.getData(_deductionsKey);
      if (data == null || data.isEmpty) {
        return [];
      }
      
      final List<dynamic> jsonList = data;
      return jsonList
          .map((json) => PayrollDeduction.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting deductions: $e');
      return [];
    }
  }

  /// Get deductions for a specific payroll record
  Future<List<PayrollDeduction>> getDeductions(String payrollRecordId) async {
    try {
      final deductions = await getAllDeductions();
      return deductions.where((deduction) => deduction.payrollRecordId == payrollRecordId).toList();
    } catch (e) {
      print('Error getting deductions: $e');
      return [];
    }
  }

  /// Create a new deduction
  Future<PayrollDeduction> createDeduction(PayrollDeduction deduction) async {
    try {
      final deductions = await getAllDeductions();
      deductions.add(deduction);
      await _saveDeductions(deductions);
      return deduction;
    } catch (e) {
      throw Exception('Failed to create deduction: $e');
    }
  }

  /// Update an existing deduction
  Future<PayrollDeduction> updateDeduction(PayrollDeduction deduction) async {
    try {
      final deductions = await getAllDeductions();
      final index = deductions.indexWhere((d) => d.id == deduction.id);
      if (index == -1) {
        throw Exception('Deduction not found');
      }
      
      deductions[index] = deduction;
      await _saveDeductions(deductions);
      return deduction;
    } catch (e) {
      throw Exception('Failed to update deduction: $e');
    }
  }

  /// Delete a deduction
  Future<bool> deleteDeduction(String id) async {
    try {
      final deductions = await getAllDeductions();
      deductions.removeWhere((deduction) => deduction.id == id);
      await _saveDeductions(deductions);
      return true;
    } catch (e) {
      print('Error deleting deduction: $e');
      return false;
    }
  }

  /// Save payroll records to storage
  Future<void> _savePayrollRecords(List<PayrollRecord> records) async {
    try {
      final jsonList = records.map((record) => record.toJson()).toList();
      WebStorageService.saveData(_payrollRecordsKey, jsonList);
    } catch (e) {
      throw Exception('Failed to save payroll records: $e');
    }
  }

  /// Save allowances to storage
  Future<void> _saveAllowances(List<PayrollAllowance> allowances) async {
    try {
      final jsonList = allowances.map((allowance) => allowance.toJson()).toList();
      WebStorageService.saveData(_allowancesKey, jsonList);
    } catch (e) {
      throw Exception('Failed to save allowances: $e');
    }
  }

  /// Save deductions to storage
  Future<void> _saveDeductions(List<PayrollDeduction> deductions) async {
    try {
      final jsonList = deductions.map((deduction) => deduction.toJson()).toList();
      WebStorageService.saveData(_deductionsKey, jsonList);
    } catch (e) {
      throw Exception('Failed to save deductions: $e');
    }
  }

  /// Clear all payroll data (for testing/reset)
  Future<void> clearAllPayrollData() async {
    try {
      WebStorageService.removeData(_payrollRecordsKey);
      WebStorageService.removeData(_allowancesKey);
      WebStorageService.removeData(_deductionsKey);
    } catch (e) {
      print('Error clearing payroll data: $e');
    }
  }
}
