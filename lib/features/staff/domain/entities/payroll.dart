import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'payroll.freezed.dart';
part 'payroll.g.dart';

@freezed
class PayrollRecord with _$PayrollRecord {
  const factory PayrollRecord({
    required String id,
    required String staffMemberId,
    required DateTime payPeriodStart,
    required DateTime payPeriodEnd,
    required double basicSalary,
    required double overtimePay,
    required double allowances,
    required double deductions,
    required double grossPay,
    required double netPay,
    required PayrollStatus status,
    DateTime? paidDate,
    String? paymentMethod,
    String? bankAccount,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PayrollRecord;

  factory PayrollRecord.fromJson(Map<String, dynamic> json) =>
      _$PayrollRecordFromJson(json);

  factory PayrollRecord.create({
    required String staffMemberId,
    required DateTime payPeriodStart,
    required DateTime payPeriodEnd,
    required double basicSalary,
    double? overtimePay,
    double? allowances,
    double? deductions,
    String? notes,
  }) {
    final overtime = overtimePay ?? 0.0;
    final allowance = allowances ?? 0.0;
    final deduction = deductions ?? 0.0;
    final gross = basicSalary + overtime + allowance;
    final net = gross - deduction;

    return PayrollRecord(
      id: const Uuid().v4(),
      staffMemberId: staffMemberId,
      payPeriodStart: payPeriodStart,
      payPeriodEnd: payPeriodEnd,
      basicSalary: basicSalary,
      overtimePay: overtime,
      allowances: allowance,
      deductions: deduction,
      grossPay: gross,
      netPay: net,
      status: PayrollStatus.pending,
      paidDate: null,
      paymentMethod: null,
      bankAccount: null,
      notes: notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

@freezed
class PayrollDeduction with _$PayrollDeduction {
  const factory PayrollDeduction({
    required String id,
    required String payrollRecordId,
    required String name,
    required double amount,
    required DeductionType type,
    String? description,
    required DateTime createdAt,
  }) = _PayrollDeduction;

  factory PayrollDeduction.fromJson(Map<String, dynamic> json) =>
      _$PayrollDeductionFromJson(json);

  factory PayrollDeduction.create({
    required String payrollRecordId,
    required String name,
    required double amount,
    required DeductionType type,
    String? description,
  }) {
    return PayrollDeduction(
      id: const Uuid().v4(),
      payrollRecordId: payrollRecordId,
      name: name,
      amount: amount,
      type: type,
      description: description,
      createdAt: DateTime.now(),
    );
  }
}

@freezed
class PayrollAllowance with _$PayrollAllowance {
  const factory PayrollAllowance({
    required String id,
    required String payrollRecordId,
    required String name,
    required double amount,
    required AllowanceType type,
    String? description,
    required DateTime createdAt,
  }) = _PayrollAllowance;

  factory PayrollAllowance.fromJson(Map<String, dynamic> json) =>
      _$PayrollAllowanceFromJson(json);

  factory PayrollAllowance.create({
    required String payrollRecordId,
    required String name,
    required double amount,
    required AllowanceType type,
    String? description,
  }) {
    return PayrollAllowance(
      id: const Uuid().v4(),
      payrollRecordId: payrollRecordId,
      name: name,
      amount: amount,
      type: type,
      description: description,
      createdAt: DateTime.now(),
    );
  }
}

enum PayrollStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('paid')
  paid,
  @JsonValue('cancelled')
  cancelled,
}

enum DeductionType {
  @JsonValue('tax')
  tax,
  @JsonValue('epf')
  epf,
  @JsonValue('socso')
  socso,
  @JsonValue('eis')
  eis,
  @JsonValue('loan')
  loan,
  @JsonValue('advance')
  advance,
  @JsonValue('other')
  other,
}

enum AllowanceType {
  @JsonValue('transport')
  transport,
  @JsonValue('meal')
  meal,
  @JsonValue('housing')
  housing,
  @JsonValue('medical')
  medical,
  @JsonValue('bonus')
  bonus,
  @JsonValue('commission')
  commission,
  @JsonValue('other')
  other,
}

extension PayrollStatusExtension on PayrollStatus {
  String get displayName {
    switch (this) {
      case PayrollStatus.pending:
        return 'Pending';
      case PayrollStatus.approved:
        return 'Approved';
      case PayrollStatus.paid:
        return 'Paid';
      case PayrollStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case PayrollStatus.pending:
        return Colors.orange;
      case PayrollStatus.approved:
        return Colors.blue;
      case PayrollStatus.paid:
        return Colors.green;
      case PayrollStatus.cancelled:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case PayrollStatus.pending:
        return Icons.schedule;
      case PayrollStatus.approved:
        return Icons.check_circle;
      case PayrollStatus.paid:
        return Icons.payment;
      case PayrollStatus.cancelled:
        return Icons.cancel;
    }
  }
}

extension DeductionTypeExtension on DeductionType {
  String get displayName {
    switch (this) {
      case DeductionType.tax:
        return 'Income Tax';
      case DeductionType.epf:
        return 'EPF';
      case DeductionType.socso:
        return 'SOCSO';
      case DeductionType.eis:
        return 'EIS';
      case DeductionType.loan:
        return 'Loan';
      case DeductionType.advance:
        return 'Advance';
      case DeductionType.other:
        return 'Other';
    }
  }

  Color get color {
    switch (this) {
      case DeductionType.tax:
        return Colors.red;
      case DeductionType.epf:
        return Colors.blue;
      case DeductionType.socso:
        return Colors.green;
      case DeductionType.eis:
        return Colors.orange;
      case DeductionType.loan:
        return Colors.purple;
      case DeductionType.advance:
        return Colors.teal;
      case DeductionType.other:
        return Colors.grey;
    }
  }
}

extension AllowanceTypeExtension on AllowanceType {
  String get displayName {
    switch (this) {
      case AllowanceType.transport:
        return 'Transport Allowance';
      case AllowanceType.meal:
        return 'Meal Allowance';
      case AllowanceType.housing:
        return 'Housing Allowance';
      case AllowanceType.medical:
        return 'Medical Allowance';
      case AllowanceType.bonus:
        return 'Bonus';
      case AllowanceType.commission:
        return 'Commission';
      case AllowanceType.other:
        return 'Other';
    }
  }

  Color get color {
    switch (this) {
      case AllowanceType.transport:
        return Colors.blue;
      case AllowanceType.meal:
        return Colors.orange;
      case AllowanceType.housing:
        return Colors.green;
      case AllowanceType.medical:
        return Colors.red;
      case AllowanceType.bonus:
        return Colors.purple;
      case AllowanceType.commission:
        return Colors.teal;
      case AllowanceType.other:
        return Colors.grey;
    }
  }
}
