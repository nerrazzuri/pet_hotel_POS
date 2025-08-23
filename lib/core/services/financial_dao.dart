import 'package:cat_hotel_pos/features/financials/domain/entities/financial_account.dart';
import 'package:cat_hotel_pos/features/financials/domain/entities/financial_transaction.dart';
import 'package:cat_hotel_pos/features/financials/domain/entities/budget.dart';

class FinancialDao {
  static final List<FinancialAccount> _accounts = [
    FinancialAccount.create(
      accountName: 'Main Business Account',
      accountNumber: '1234567890',
      accountType: AccountType.checking,
      bankName: 'Maybank',
      branchCode: 'KL001',
      swiftCode: 'MBBEMYKL',
      iban: 'MY123456789012345678901234',
    ),
    FinancialAccount.create(
      accountName: 'Petty Cash',
      accountNumber: 'PC001',
      accountType: AccountType.pettyCash,
      description: 'Daily operational expenses',
    ),
    FinancialAccount.create(
      accountName: 'Savings Account',
      accountNumber: '9876543210',
      accountType: AccountType.savings,
      bankName: 'CIMB Bank',
      branchCode: 'KL002',
      swiftCode: 'CIBBMYKL',
      iban: 'MY987654321098765432109876',
      interestRate: 3.5,
    ),
  ];

  static final List<FinancialTransaction> _transactions = [
    FinancialTransaction.create(
      accountId: _accounts[0].id,
      type: TransactionType.deposit,
      category: TransactionCategory.sales,
      amount: 5000.0,
      transactionDate: DateTime.now().subtract(const Duration(days: 1)),
      description: 'Daily sales deposit',
      reference: 'SALES_001',
    ),
    FinancialTransaction.create(
      accountId: _accounts[0].id,
      type: TransactionType.withdrawal,
      category: TransactionCategory.purchases,
      amount: 1500.0,
      transactionDate: DateTime.now().subtract(const Duration(days: 2)),
      description: 'Pet food supplies',
      reference: 'PURCHASE_001',
    ),
    FinancialTransaction.create(
      accountId: _accounts[1].id,
      type: TransactionType.withdrawal,
      category: TransactionCategory.officeSupplies,
      amount: 50.0,
      transactionDate: DateTime.now().subtract(const Duration(days: 3)),
      description: 'Office supplies',
      reference: 'OFFICE_001',
    ),
  ];

  static final List<Budget> _budgets = [
    Budget.create(
      name: 'Q4 2024 Operating Budget',
      period: BudgetPeriod.quarterly,
      startDate: DateTime(2024, 10, 1),
      endDate: DateTime(2024, 12, 31),
      totalAmount: 50000.0,
      description: 'Fourth quarter operating budget',
      categories: [
        BudgetCategory.create(
          name: 'Payroll',
          allocatedAmount: 25000.0,
          description: 'Staff salaries and benefits',
        ),
        BudgetCategory.create(
          name: 'Supplies',
          allocatedAmount: 10000.0,
          description: 'Pet food and supplies',
        ),
        BudgetCategory.create(
          name: 'Utilities',
          allocatedAmount: 5000.0,
          description: 'Electricity, water, internet',
        ),
        BudgetCategory.create(
          name: 'Marketing',
          allocatedAmount: 5000.0,
          description: 'Advertising and promotions',
        ),
        BudgetCategory.create(
          name: 'Maintenance',
          allocatedAmount: 5000.0,
          description: 'Equipment and facility maintenance',
        ),
      ],
    ),
  ];

  // Account operations
  Future<List<FinancialAccount>> getAllAccounts() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_accounts);
  }

  Future<FinancialAccount?> getAccountById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _accounts.firstWhere((account) => account.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<FinancialAccount> createAccount(FinancialAccount account) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _accounts.add(account);
    return account;
  }

  Future<FinancialAccount> updateAccount(FinancialAccount account) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _accounts.indexWhere((acc) => acc.id == account.id);
    if (index != -1) {
      _accounts[index] = account;
    }
    return account;
  }

  Future<bool> deleteAccount(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _accounts.indexWhere((account) => account.id == id);
    if (index != -1) {
      _accounts.removeAt(index);
      return true;
    }
    return false;
  }

  // Transaction operations
  Future<List<FinancialTransaction>> getAllTransactions() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_transactions);
  }

  Future<List<FinancialTransaction>> getTransactionsByAccount(String accountId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _transactions.where((txn) => txn.accountId == accountId).toList();
  }

  Future<List<FinancialTransaction>> getTransactionsByDateRange(DateTime startDate, DateTime endDate) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _transactions.where((txn) {
      return txn.transactionDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
             txn.transactionDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  Future<FinancialTransaction> createTransaction(FinancialTransaction transaction) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _transactions.add(transaction);
    
    // Update account balance
    final account = _accounts.firstWhere((acc) => acc.id == transaction.accountId);
    final updatedAccount = account.copyWith(
      balance: account.balance + (transaction.type.isCredit ? transaction.amount : -transaction.amount),
      updatedAt: DateTime.now(),
    );
    await updateAccount(updatedAccount);
    
    return transaction;
  }

  Future<FinancialTransaction> updateTransaction(FinancialTransaction transaction) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _transactions.indexWhere((txn) => txn.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
    }
    return transaction;
  }

  Future<bool> deleteTransaction(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _transactions.indexWhere((txn) => txn.id == id);
    if (index != -1) {
      _transactions.removeAt(index);
      return true;
    }
    return false;
  }

  // Budget operations
  Future<List<Budget>> getAllBudgets() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_budgets);
  }

  Future<Budget?> getBudgetById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _budgets.firstWhere((budget) => budget.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<Budget> createBudget(Budget budget) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _budgets.add(budget);
    return budget;
  }

  Future<Budget> updateBudget(Budget budget) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _budgets.indexWhere((b) => b.id == budget.id);
    if (index != -1) {
      _budgets[index] = budget;
    }
    return budget;
  }

  Future<bool> deleteBudget(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _budgets.indexWhere((budget) => budget.id == id);
    if (index != -1) {
      _budgets.removeAt(index);
      return true;
    }
    return false;
  }

  // Analytics and reporting
  Future<Map<String, dynamic>> getFinancialSummary() async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final totalBalance = _accounts.fold<double>(0.0, (sum, account) => sum + account.balance);
    final totalTransactions = _transactions.length;
    final totalIncome = _transactions
        .where((txn) => txn.type.isCredit)
        .fold<double>(0.0, (sum, txn) => sum + txn.amount);
    final totalExpenses = _transactions
        .where((txn) => !txn.type.isCredit)
        .fold<double>(0.0, (sum, txn) => sum + txn.amount);
    
    return {
      'totalBalance': totalBalance,
      'totalAccounts': _accounts.length,
      'totalTransactions': totalTransactions,
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'netIncome': totalIncome - totalExpenses,
      'activeBudgets': _budgets.where((b) => b.status == BudgetStatus.active).length,
    };
  }

  Future<Map<String, dynamic>> getAccountSummary(String accountId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    
    final account = await getAccountById(accountId);
    if (account == null) throw Exception('Account not found');
    
    final transactions = await getTransactionsByAccount(accountId);
    final income = transactions
        .where((txn) => txn.type.isCredit)
        .fold<double>(0.0, (sum, txn) => sum + txn.amount);
    final expenses = transactions
        .where((txn) => !txn.type.isCredit)
        .fold<double>(0.0, (sum, txn) => sum + txn.amount);
    
    return {
      'account': account,
      'totalTransactions': transactions.length,
      'totalIncome': income,
      'totalExpenses': expenses,
      'netFlow': income - expenses,
      'lastTransaction': transactions.isNotEmpty ? transactions.last : null,
    };
  }

  Future<List<Map<String, dynamic>>> getCategoryBreakdown() async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final Map<String, double> categoryTotals = {};
    
    for (final transaction in _transactions) {
      final category = transaction.category.displayName;
      categoryTotals[category] = (categoryTotals[category] ?? 0.0) + transaction.amount;
    }
    
    return categoryTotals.entries.map((entry) => {
      'category': entry.key,
      'amount': entry.value,
      'percentage': (entry.value / _transactions.fold<double>(0.0, (sum, txn) => sum + txn.amount) * 100).roundToDouble(),
    }).toList()
      ..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));
  }
}
