import 'package:freezed_annotation/freezed_annotation.dart';

part 'financial_account.freezed.dart';
part 'financial_account.g.dart';

@freezed
class FinancialAccount with _$FinancialAccount {
  const factory FinancialAccount({
    required String id,
    required String accountName,
    required String accountNumber,
    required AccountType accountType,
    required AccountStatus status,
    required double balance,
    required String currency,
    String? description,
    String? bankName,
    String? branchCode,
    String? swiftCode,
    String? iban,
    double? creditLimit,
    double? interestRate,
    DateTime? lastReconciliation,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FinancialAccount;

  factory FinancialAccount.fromJson(Map<String, dynamic> json) =>
      _$FinancialAccountFromJson(json);

  factory FinancialAccount.create({
    required String accountName,
    required String accountNumber,
    required AccountType accountType,
    String? description,
    String? bankName,
    String? branchCode,
    String? swiftCode,
    String? iban,
    double? creditLimit,
    double? interestRate,
  }) {
    return FinancialAccount(
      id: 'ACC_${DateTime.now().millisecondsSinceEpoch}',
      accountName: accountName,
      accountNumber: accountNumber,
      accountType: accountType,
      status: AccountStatus.active,
      balance: 0.0,
      currency: 'MYR',
      description: description,
      bankName: bankName,
      branchCode: branchCode,
      swiftCode: swiftCode,
      iban: iban,
      creditLimit: creditLimit,
      interestRate: interestRate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

enum AccountType {
  @JsonValue('checking')
  checking,
  @JsonValue('savings')
  savings,
  @JsonValue('credit')
  credit,
  @JsonValue('loan')
  loan,
  @JsonValue('investment')
  investment,
  @JsonValue('petty_cash')
  pettyCash,
  @JsonValue('escrow')
  escrow,
}

enum AccountStatus {
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
  @JsonValue('frozen')
  frozen,
  @JsonValue('closed')
  closed,
}

extension AccountTypeExtension on AccountType {
  String get displayName {
    switch (this) {
      case AccountType.checking:
        return 'Checking Account';
      case AccountType.savings:
        return 'Savings Account';
      case AccountType.credit:
        return 'Credit Account';
      case AccountType.loan:
        return 'Loan Account';
      case AccountType.investment:
        return 'Investment Account';
      case AccountType.pettyCash:
        return 'Petty Cash';
      case AccountType.escrow:
        return 'Escrow Account';
    }
  }

  String get shortName {
    switch (this) {
      case AccountType.checking:
        return 'Checking';
      case AccountType.savings:
        return 'Savings';
      case AccountType.credit:
        return 'Credit';
      case AccountType.loan:
        return 'Loan';
      case AccountType.investment:
        return 'Investment';
      case AccountType.pettyCash:
        return 'Petty Cash';
      case AccountType.escrow:
        return 'Escrow';
    }
  }
}

extension AccountStatusExtension on AccountStatus {
  String get displayName {
    switch (this) {
      case AccountStatus.active:
        return 'Active';
      case AccountStatus.inactive:
        return 'Inactive';
      case AccountStatus.frozen:
        return 'Frozen';
      case AccountStatus.closed:
        return 'Closed';
    }
  }
}
