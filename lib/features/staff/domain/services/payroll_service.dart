import 'package:cat_hotel_pos/features/staff/domain/entities/payroll.dart';
import 'package:cat_hotel_pos/features/staff/domain/entities/time_tracking.dart';
import 'package:cat_hotel_pos/core/services/payroll_dao.dart';
import 'package:cat_hotel_pos/core/services/time_tracking_dao.dart';

class PayrollService {
  final PayrollDao _payrollDao;
  final TimeTrackingDao _timeTrackingDao;

  PayrollService(this._payrollDao, this._timeTrackingDao);

  /// Generate payroll for a staff member for a specific period
  Future<PayrollRecord> generatePayroll({
    required String staffMemberId,
    required DateTime payPeriodStart,
    required DateTime payPeriodEnd,
    required double basicSalary,
    List<PayrollAllowance>? allowances,
    List<PayrollDeduction>? deductions,
    String? notes,
  }) async {
    // Calculate overtime pay from time tracking
    final overtimePay = await _calculateOvertimePay(
      staffMemberId,
      payPeriodStart,
      payPeriodEnd,
    );

    // Calculate total allowances
    final totalAllowances = allowances?.fold<double>(
      0.0, (sum, allowance) => sum + allowance.amount
    ) ?? 0.0;

    // Calculate total deductions
    final totalDeductions = deductions?.fold<double>(
      0.0, (sum, deduction) => sum + deduction.amount
    ) ?? 0.0;

    // Calculate gross and net pay
    final grossPay = basicSalary + overtimePay + totalAllowances;
    final netPay = grossPay - totalDeductions;

    final payrollRecord = PayrollRecord.create(
      staffMemberId: staffMemberId,
      payPeriodStart: payPeriodStart,
      payPeriodEnd: payPeriodEnd,
      basicSalary: basicSalary,
      overtimePay: overtimePay,
      allowances: totalAllowances,
      deductions: totalDeductions,
      notes: notes,
    );

    final createdRecord = await _payrollDao.createPayrollRecord(payrollRecord);

    // Save allowances and deductions
    if (allowances != null) {
      for (final allowance in allowances) {
        await _payrollDao.createAllowance(allowance.copyWith(
          payrollRecordId: createdRecord.id,
        ));
      }
    }

    if (deductions != null) {
      for (final deduction in deductions) {
        await _payrollDao.createDeduction(deduction.copyWith(
          payrollRecordId: createdRecord.id,
        ));
      }
    }

    return createdRecord;
  }

  /// Calculate overtime pay from time tracking records
  Future<double> _calculateOvertimePay(
    String staffMemberId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final timeRecords = await _timeTrackingDao.getTimeTrackingByDateRange(
      startDate: startDate,
      endDate: endDate,
      staffMemberId: staffMemberId,
    );

    double totalOvertimeHours = 0;
    for (final record in timeRecords) {
      if (record.overtimeHours != null) {
        totalOvertimeHours += record.overtimeHours!;
      }
    }

    // Assuming overtime rate is 1.5x hourly rate
    // This should be configurable in a real system
    const overtimeRate = 1.5;
    const hourlyRate = 20.0; // This should come from staff member's hourly rate
    
    return totalOvertimeHours * hourlyRate * overtimeRate;
  }

  /// Approve a payroll record
  Future<PayrollRecord> approvePayroll({
    required String payrollRecordId,
  }) async {
    final payrollRecord = await _payrollDao.getPayrollRecordById(payrollRecordId);
    if (payrollRecord == null) {
      throw Exception('Payroll record not found');
    }

    if (payrollRecord.status != PayrollStatus.pending) {
      throw Exception('Payroll record is not pending');
    }

    final updatedRecord = payrollRecord.copyWith(
      status: PayrollStatus.approved,
      updatedAt: DateTime.now(),
    );

    return await _payrollDao.updatePayrollRecord(updatedRecord);
  }

  /// Mark payroll as paid
  Future<PayrollRecord> markPayrollAsPaid({
    required String payrollRecordId,
    required String paymentMethod,
    String? bankAccount,
  }) async {
    final payrollRecord = await _payrollDao.getPayrollRecordById(payrollRecordId);
    if (payrollRecord == null) {
      throw Exception('Payroll record not found');
    }

    if (payrollRecord.status != PayrollStatus.approved) {
      throw Exception('Payroll record must be approved before payment');
    }

    final updatedRecord = payrollRecord.copyWith(
      status: PayrollStatus.paid,
      paidDate: DateTime.now(),
      paymentMethod: paymentMethod,
      bankAccount: bankAccount,
      updatedAt: DateTime.now(),
    );

    return await _payrollDao.updatePayrollRecord(updatedRecord);
  }

  /// Get payroll records for a staff member
  Future<List<PayrollRecord>> getPayrollRecordsByStaffMember(String staffMemberId) async {
    return await _payrollDao.getPayrollRecordsByStaffMember(staffMemberId);
  }

  /// Get payroll records by date range
  Future<List<PayrollRecord>> getPayrollRecordsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? staffMemberId,
  }) async {
    return await _payrollDao.getPayrollRecordsByDateRange(
      startDate: startDate,
      endDate: endDate,
      staffMemberId: staffMemberId,
    );
  }

  /// Get payroll record by ID
  Future<PayrollRecord?> getPayrollRecordById(String id) async {
    return await _payrollDao.getPayrollRecordById(id);
  }

  /// Get allowances for a payroll record
  Future<List<PayrollAllowance>> getAllowances(String payrollRecordId) async {
    return await _payrollDao.getAllowances(payrollRecordId);
  }

  /// Get deductions for a payroll record
  Future<List<PayrollDeduction>> getDeductions(String payrollRecordId) async {
    return await _payrollDao.getDeductions(payrollRecordId);
  }

  /// Create a payroll allowance
  Future<PayrollAllowance> createAllowance({
    required String payrollRecordId,
    required String name,
    required double amount,
    required AllowanceType type,
    String? description,
  }) async {
    final allowance = PayrollAllowance.create(
      payrollRecordId: payrollRecordId,
      name: name,
      amount: amount,
      type: type,
      description: description,
    );

    return await _payrollDao.createAllowance(allowance);
  }

  /// Create a payroll deduction
  Future<PayrollDeduction> createDeduction({
    required String payrollRecordId,
    required String name,
    required double amount,
    required DeductionType type,
    String? description,
  }) async {
    final deduction = PayrollDeduction.create(
      payrollRecordId: payrollRecordId,
      name: name,
      amount: amount,
      type: type,
      description: description,
    );

    return await _payrollDao.createDeduction(deduction);
  }

  /// Generate payroll summary for a period
  Future<Map<String, dynamic>> generatePayrollSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final records = await getPayrollRecordsByDateRange(
      startDate: startDate,
      endDate: endDate,
    );

    double totalBasicSalary = 0;
    double totalOvertimePay = 0;
    double totalAllowances = 0;
    double totalDeductions = 0;
    double totalGrossPay = 0;
    double totalNetPay = 0;
    int totalEmployees = 0;

    for (final record in records) {
      totalBasicSalary += record.basicSalary;
      totalOvertimePay += record.overtimePay;
      totalAllowances += record.allowances;
      totalDeductions += record.deductions;
      totalGrossPay += record.grossPay;
      totalNetPay += record.netPay;
      totalEmployees++;
    }

    return {
      'totalEmployees': totalEmployees,
      'totalBasicSalary': totalBasicSalary,
      'totalOvertimePay': totalOvertimePay,
      'totalAllowances': totalAllowances,
      'totalDeductions': totalDeductions,
      'totalGrossPay': totalGrossPay,
      'totalNetPay': totalNetPay,
      'averageGrossPay': totalEmployees > 0 ? totalGrossPay / totalEmployees : 0,
      'averageNetPay': totalEmployees > 0 ? totalNetPay / totalEmployees : 0,
    };
  }

  /// Get payroll statistics for a staff member
  Future<Map<String, dynamic>> getPayrollStatistics({
    required String staffMemberId,
    required int year,
  }) async {
    final startDate = DateTime(year, 1, 1);
    final endDate = DateTime(year, 12, 31);
    
    final records = await getPayrollRecordsByDateRange(
      startDate: startDate,
      endDate: endDate,
      staffMemberId: staffMemberId,
    );

    double totalBasicSalary = 0;
    double totalOvertimePay = 0;
    double totalAllowances = 0;
    double totalDeductions = 0;
    double totalGrossPay = 0;
    double totalNetPay = 0;
    int payPeriods = 0;

    for (final record in records) {
      totalBasicSalary += record.basicSalary;
      totalOvertimePay += record.overtimePay;
      totalAllowances += record.allowances;
      totalDeductions += record.deductions;
      totalGrossPay += record.grossPay;
      totalNetPay += record.netPay;
      payPeriods++;
    }

    return {
      'year': year,
      'payPeriods': payPeriods,
      'totalBasicSalary': totalBasicSalary,
      'totalOvertimePay': totalOvertimePay,
      'totalAllowances': totalAllowances,
      'totalDeductions': totalDeductions,
      'totalGrossPay': totalGrossPay,
      'totalNetPay': totalNetPay,
      'averageGrossPay': payPeriods > 0 ? totalGrossPay / payPeriods : 0,
      'averageNetPay': payPeriods > 0 ? totalNetPay / payPeriods : 0,
    };
  }

  /// Generate pay stub for a payroll record
  Future<Map<String, dynamic>> generatePayStub(String payrollRecordId) async {
    final payrollRecord = await getPayrollRecordById(payrollRecordId);
    if (payrollRecord == null) {
      throw Exception('Payroll record not found');
    }

    final allowances = await getAllowances(payrollRecordId);
    final deductions = await getDeductions(payrollRecordId);

    return {
      'payrollRecord': payrollRecord,
      'allowances': allowances,
      'deductions': deductions,
      'generatedAt': DateTime.now(),
    };
  }
}
