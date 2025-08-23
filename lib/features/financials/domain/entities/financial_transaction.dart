import 'package:freezed_annotation/freezed_annotation.dart';

part 'financial_transaction.freezed.dart';
part 'financial_transaction.g.dart';

@freezed
class FinancialTransaction with _$FinancialTransaction {
  const factory FinancialTransaction({
    required String id,
    required String accountId,
    required TransactionType type,
    required TransactionCategory category,
    required double amount,
    required String currency,
    required DateTime transactionDate,
    String? description,
    String? reference,
                  String? relatedTransactionId,
              TransactionStatus? status,
              String? notes,
    String? attachmentUrl,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FinancialTransaction;

  factory FinancialTransaction.fromJson(Map<String, dynamic> json) =>
      _$FinancialTransactionFromJson(json);

  factory FinancialTransaction.create({
    required String accountId,
    required TransactionType type,
    required TransactionCategory category,
    required double amount,
    required DateTime transactionDate,
    String? description,
    String? reference,
    String? relatedTransactionId,
    String? notes,
  }) {
    return FinancialTransaction(
      id: 'TXN_${DateTime.now().millisecondsSinceEpoch}',
      accountId: accountId,
      type: type,
      category: category,
      amount: amount,
      currency: 'MYR',
      transactionDate: transactionDate,
      description: description,
      reference: reference,
      relatedTransactionId: relatedTransactionId,
      status: TransactionStatus.completed,
      notes: notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

enum TransactionType {
  @JsonValue('deposit')
  deposit,
  @JsonValue('withdrawal')
  withdrawal,
  @JsonValue('transfer')
  transfer,
  @JsonValue('payment')
  payment,
  @JsonValue('refund')
  refund,
  @JsonValue('fee')
  fee,
  @JsonValue('interest')
  interest,
  @JsonValue('adjustment')
  adjustment,
}

enum TransactionCategory {
  @JsonValue('sales')
  sales,
  @JsonValue('purchases')
  purchases,
  @JsonValue('payroll')
  payroll,
  @JsonValue('utilities')
  utilities,
  @JsonValue('rent')
  rent,
  @JsonValue('insurance')
  insurance,
  @JsonValue('maintenance')
  maintenance,
  @JsonValue('marketing')
  marketing,
  @JsonValue('professional_services')
  professionalServices,
  @JsonValue('travel')
  travel,
  @JsonValue('office_supplies')
  officeSupplies,
  @JsonValue('equipment')
  equipment,
  @JsonValue('software')
  software,
  @JsonValue('other')
  other,
}

enum TransactionStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('reversed')
  reversed,
}

extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.transfer:
        return 'Transfer';
      case TransactionType.payment:
        return 'Payment';
      case TransactionType.refund:
        return 'Refund';
      case TransactionType.fee:
        return 'Fee';
      case TransactionType.interest:
        return 'Interest';
      case TransactionType.adjustment:
        return 'Adjustment';
    }
  }

  bool get isCredit {
    switch (this) {
      case TransactionType.deposit:
      case TransactionType.refund:
      case TransactionType.interest:
        return true;
      case TransactionType.withdrawal:
      case TransactionType.payment:
      case TransactionType.fee:
        return false;
      case TransactionType.transfer:
      case TransactionType.adjustment:
        return false; // Depends on context
    }
  }
}

extension TransactionCategoryExtension on TransactionCategory {
  String get displayName {
    switch (this) {
      case TransactionCategory.sales:
        return 'Sales';
      case TransactionCategory.purchases:
        return 'Purchases';
      case TransactionCategory.payroll:
        return 'Payroll';
      case TransactionCategory.utilities:
        return 'Utilities';
      case TransactionCategory.rent:
        return 'Rent';
      case TransactionCategory.insurance:
        return 'Insurance';
      case TransactionCategory.maintenance:
        return 'Maintenance';
      case TransactionCategory.marketing:
        return 'Marketing';
      case TransactionCategory.professionalServices:
        return 'Professional Services';
      case TransactionCategory.travel:
        return 'Travel';
      case TransactionCategory.officeSupplies:
        return 'Office Supplies';
      case TransactionCategory.equipment:
        return 'Equipment';
      case TransactionCategory.software:
        return 'Software';
      case TransactionCategory.other:
        return 'Other';
    }
  }
}

extension TransactionStatusExtension on TransactionStatus {
  String get displayName {
    switch (this) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
      case TransactionStatus.reversed:
        return 'Reversed';
    }
  }
}
