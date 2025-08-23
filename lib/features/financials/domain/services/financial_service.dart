import 'package:cat_hotel_pos/core/services/financial_dao.dart';
import 'package:cat_hotel_pos/features/financials/domain/entities/financial_account.dart';
import 'package:cat_hotel_pos/features/financials/domain/entities/financial_transaction.dart';
import 'package:cat_hotel_pos/features/financials/domain/entities/budget.dart';

class FinancialService {
  final FinancialDao _financialDao;

  FinancialService(this._financialDao);

  // Account Management
  Future<List<FinancialAccount>> getAllAccounts() async {
    return await _financialDao.getAllAccounts();
  }

  Future<FinancialAccount?> getAccountById(String id) async {
    return await _financialDao.getAccountById(id);
  }

  Future<FinancialAccount> createAccount(FinancialAccount account) async {
    // Validate account details
    if (account.accountName.trim().isEmpty) {
      throw Exception('Account name is required');
    }

    if (account.accountNumber.trim().isEmpty) {
      throw Exception('Account number is required');
    }

    if (account.accountName.length < 3) {
      throw Exception('Account name must be at least 3 characters long');
    }

    if (account.accountNumber.length < 5) {
      throw Exception('Account number must be at least 5 characters long');
    }

    // Check if account number already exists
    final existingAccounts = await _financialDao.getAllAccounts();
    final accountExists = existingAccounts.any(
      (acc) => acc.accountNumber == account.accountNumber && acc.id != account.id,
    );

    if (accountExists) {
      throw Exception('Account number already exists');
    }

    return await _financialDao.createAccount(account);
  }

  Future<FinancialAccount> updateAccount(FinancialAccount account) async {
    // Validate account details
    if (account.accountName.trim().isEmpty) {
      throw Exception('Account name is required');
    }

    if (account.accountNumber.trim().isEmpty) {
      throw Exception('Account number is required');
    }

    // Check if account number already exists for other accounts
    final existingAccounts = await _financialDao.getAllAccounts();
    final accountExists = existingAccounts.any(
      (acc) => acc.accountNumber == account.accountNumber && acc.id != account.id,
    );

    if (accountExists) {
      throw Exception('Account number already exists');
    }

    return await _financialDao.updateAccount(account);
  }

  Future<bool> deleteAccount(String id) async {
    // Check if account has transactions
    final transactions = await _financialDao.getTransactionsByAccount(id);
    if (transactions.isNotEmpty) {
      throw Exception('Cannot delete account with existing transactions');
    }

    return await _financialDao.deleteAccount(id);
  }

  Future<bool> freezeAccount(String id) async {
    final account = await _financialDao.getAccountById(id);
    if (account == null) {
      throw Exception('Account not found');
    }

    if (account.status == AccountStatus.frozen) {
      throw Exception('Account is already frozen');
    }

    final updatedAccount = account.copyWith(
      status: AccountStatus.frozen,
      updatedAt: DateTime.now(),
    );

    await _financialDao.updateAccount(updatedAccount);
    return true;
  }

  Future<bool> activateAccount(String id) async {
    final account = await _financialDao.getAccountById(id);
    if (account == null) {
      throw Exception('Account not found');
    }

    if (account.status == AccountStatus.active) {
      throw Exception('Account is already active');
    }

    final updatedAccount = account.copyWith(
      status: AccountStatus.active,
      updatedAt: DateTime.now(),
    );

    await _financialDao.updateAccount(updatedAccount);
    return true;
  }

  // Transaction Management
  Future<List<FinancialTransaction>> getAllTransactions() async {
    return await _financialDao.getAllTransactions();
  }

  Future<List<FinancialTransaction>> getTransactionsByAccount(String accountId) async {
    return await _financialDao.getTransactionsByAccount(accountId);
  }

  Future<List<FinancialTransaction>> getTransactionsByDateRange(DateTime startDate, DateTime endDate) async {
    if (startDate.isAfter(endDate)) {
      throw Exception('Start date cannot be after end date');
    }

    return await _financialDao.getTransactionsByDateRange(startDate, endDate);
  }

  Future<FinancialTransaction> createTransaction(FinancialTransaction transaction) async {
    // Validate transaction details
    if (transaction.amount <= 0) {
      throw Exception('Transaction amount must be greater than 0');
    }

    if (transaction.description?.trim().isEmpty ?? true) {
      throw Exception('Transaction description is required');
    }

    // Validate account exists and is active
    final account = await _financialDao.getAccountById(transaction.accountId);
    if (account == null) {
      throw Exception('Account not found');
    }

    if (account.status != AccountStatus.active) {
      throw Exception('Cannot create transaction for inactive account');
    }

    // Check if withdrawal would exceed account balance (for non-credit accounts)
    if (!transaction.type.isCredit && 
        account.accountType != AccountType.credit && 
        account.accountType != AccountType.loan) {
      if (account.balance < transaction.amount) {
        throw Exception('Insufficient funds in account');
      }
    }

    return await _financialDao.createTransaction(transaction);
  }

  Future<FinancialTransaction> updateTransaction(FinancialTransaction transaction) async {
    // Validate transaction details
    if (transaction.amount <= 0) {
      throw Exception('Transaction amount must be greater than 0');
    }

    if (transaction.description?.trim().isEmpty ?? true) {
      throw Exception('Transaction description is required');
    }

    // Check if transaction can be modified
    if (transaction.status == TransactionStatus.completed) {
      throw Exception('Completed transactions cannot be modified');
    }

    return await _financialDao.updateTransaction(transaction);
  }

  Future<bool> deleteTransaction(String id) async {
    final transaction = await _getTransactionById(id);
    if (transaction == null) {
      throw Exception('Transaction not found');
    }

    // Check if transaction can be deleted
    if (transaction.status == TransactionStatus.completed) {
      throw Exception('Completed transactions cannot be deleted');
    }

    return await _financialDao.deleteTransaction(id);
  }

  Future<bool> approveTransaction(String id) async {
    final transaction = await _getTransactionById(id);
    if (transaction == null) {
      throw Exception('Transaction not found');
    }

    if (transaction.status != TransactionStatus.pending) {
      throw Exception('Only pending transactions can be approved');
    }

    final updatedTransaction = transaction.copyWith(
      status: TransactionStatus.completed,
      updatedAt: DateTime.now(),
    );

    await _financialDao.updateTransaction(updatedTransaction);
    return true;
  }

  Future<bool> reverseTransaction(String id) async {
    final transaction = await _getTransactionById(id);
    if (transaction == null) {
      throw Exception('Transaction not found');
    }

    if (transaction.status != TransactionStatus.completed) {
      throw Exception('Only completed transactions can be reversed');
    }

    final updatedTransaction = transaction.copyWith(
      status: TransactionStatus.reversed,
      updatedAt: DateTime.now(),
    );

    await _financialDao.updateTransaction(updatedTransaction);
    return true;
  }

  // Budget Management
  Future<List<Budget>> getAllBudgets() async {
    return await _financialDao.getAllBudgets();
  }

  Future<Budget?> getBudgetById(String id) async {
    return await _financialDao.getBudgetById(id);
  }

  Future<Budget> createBudget(Budget budget) async {
    // Validate budget details
    if (budget.name.trim().isEmpty) {
      throw Exception('Budget name is required');
    }

    if (budget.totalAmount <= 0) {
      throw Exception('Budget amount must be greater than 0');
    }

    if (budget.startDate.isAfter(budget.endDate)) {
      throw Exception('Start date cannot be after end date');
    }

    if (budget.categories != null && budget.categories!.isNotEmpty) {
      final totalAllocated = budget.categories!.fold<double>(
        0.0, (sum, cat) => sum + cat.allocatedAmount);
      
      if (totalAllocated > budget.totalAmount) {
        throw Exception('Total allocated amount cannot exceed budget amount');
      }
    }

    return await _financialDao.createBudget(budget);
  }

  Future<Budget> updateBudget(Budget budget) async {
    // Validate budget details
    if (budget.name.trim().isEmpty) {
      throw Exception('Budget name is required');
    }

    if (budget.totalAmount <= 0) {
      throw Exception('Budget amount must be greater than 0');
    }

    if (budget.startDate.isAfter(budget.endDate)) {
      throw Exception('Start date cannot be after end date');
    }

    if (budget.categories != null && budget.categories!.isNotEmpty) {
      final totalAllocated = budget.categories!.fold<double>(
        0.0, (sum, cat) => sum + cat.allocatedAmount);
      
      if (totalAllocated > budget.totalAmount) {
        throw Exception('Total allocated amount cannot exceed budget amount');
      }
    }

    return await _financialDao.updateBudget(budget);
  }

  Future<bool> deleteBudget(String id) async {
    final budget = await _financialDao.getBudgetById(id);
    if (budget == null) {
      throw Exception('Budget not found');
    }

    if (budget.status == BudgetStatus.active) {
      throw Exception('Cannot delete active budget');
    }

    return await _financialDao.deleteBudget(id);
  }

  Future<bool> activateBudget(String id) async {
    final budget = await _financialDao.getBudgetById(id);
    if (budget == null) {
      throw Exception('Budget not found');
    }

    if (budget.status == BudgetStatus.active) {
      throw Exception('Budget is already active');
    }

    // Check if there are overlapping active budgets for the same period
    final activeBudgets = await _financialDao.getAllBudgets();
    final hasOverlap = activeBudgets.any((b) =>
        b.id != id &&
        b.status == BudgetStatus.active &&
        _hasDateOverlap(budget.startDate, budget.endDate, b.startDate, b.endDate));

    if (hasOverlap) {
      throw Exception('Budget period overlaps with existing active budget');
    }

    final updatedBudget = budget.copyWith(
      status: BudgetStatus.active,
      updatedAt: DateTime.now(),
    );

    await _financialDao.updateBudget(updatedBudget);
    return true;
  }

  Future<bool> completeBudget(String id) async {
    final budget = await _financialDao.getBudgetById(id);
    if (budget == null) {
      throw Exception('Budget not found');
    }

    if (budget.status != BudgetStatus.active) {
      throw Exception('Only active budgets can be completed');
    }

    final updatedBudget = budget.copyWith(
      status: BudgetStatus.completed,
      updatedAt: DateTime.now(),
    );

    await _financialDao.updateBudget(updatedBudget);
    return true;
  }

  // Analytics and Reporting
  Future<Map<String, dynamic>> getFinancialSummary() async {
    return await _financialDao.getFinancialSummary();
  }

  Future<Map<String, dynamic>> getAccountSummary(String accountId) async {
    return await _financialDao.getAccountSummary(accountId);
  }

  Future<List<Map<String, dynamic>>> getCategoryBreakdown() async {
    return await _financialDao.getCategoryBreakdown();
  }

  Future<Map<String, dynamic>> getBudgetPerformance(String budgetId) async {
    final budget = await _financialDao.getBudgetById(budgetId);
    if (budget == null) {
      throw Exception('Budget not found');
    }

    final transactions = await _financialDao.getTransactionsByDateRange(
      budget.startDate,
      budget.endDate,
    );

    final categorySpending = <String, double>{};
    
    for (final transaction in transactions) {
      if (!transaction.type.isCredit) {
        final category = transaction.category.displayName;
        categorySpending[category] = (categorySpending[category] ?? 0.0) + transaction.amount;
      }
    }

    final budgetCategories = budget.categories ?? [];
    final performance = <String, Map<String, dynamic>>{};

    for (final category in budgetCategories) {
      final spent = categorySpending[category.name] ?? 0.0;
      final allocated = category.allocatedAmount;
      final remaining = allocated - spent;
      final utilization = allocated > 0 ? (spent / allocated) : 0.0;
      final isOverBudget = spent > allocated;

      performance[category.name] = {
        'allocated': allocated,
        'spent': spent,
        'remaining': remaining,
        'utilization': utilization,
        'isOverBudget': isOverBudget,
        'percentage': (utilization * 100).roundToDouble(),
      };
    }

    return {
      'budget': budget,
      'performance': performance,
      'totalAllocated': budgetCategories.fold<double>(0.0, (sum, cat) => sum + cat.allocatedAmount),
      'totalSpent': categorySpending.values.fold<double>(0.0, (sum, amount) => sum + amount),
      'overallUtilization': budgetCategories.fold<double>(0.0, (sum, cat) => sum + cat.allocatedAmount) > 0
          ? (categorySpending.values.fold<double>(0.0, (sum, amount) => sum + amount) /
             budgetCategories.fold<double>(0.0, (sum, cat) => sum + cat.allocatedAmount))
          : 0.0,
    };
  }

  // Utility Methods
  Future<FinancialTransaction?> _getTransactionById(String id) async {
    final transactions = await _financialDao.getAllTransactions();
    try {
      return transactions.firstWhere((txn) => txn.id == id);
    } catch (e) {
      return null;
    }
  }

  bool _hasDateOverlap(DateTime start1, DateTime end1, DateTime start2, DateTime end2) {
    return start1.isBefore(end2) && start2.isBefore(end1);
  }

  // Validation Methods
  bool isValidAccountNumber(String accountNumber) {
    // Basic validation - can be enhanced based on specific requirements
    return accountNumber.trim().length >= 5 && 
           RegExp(r'^[A-Za-z0-9\-_]+$').hasMatch(accountNumber);
  }

  bool isValidBankDetails(String? swiftCode, String? iban) {
    if (swiftCode != null && swiftCode.isNotEmpty) {
      if (swiftCode.length != 8 && swiftCode.length != 11) {
        return false;
      }
      if (!RegExp(r'^[A-Z]{4}[A-Z]{2}[A-Z0-9]{2}[A-Z0-9]{3}?$').hasMatch(swiftCode)) {
        return false;
      }
    }

    if (iban != null && iban.isNotEmpty) {
      if (iban.length < 15 || iban.length > 34) {
        return false;
      }
      if (!RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z0-9]{4}[0-9]{7}([A-Z0-9]?){0,16}$').hasMatch(iban)) {
        return false;
      }
    }

    return true;
  }

  bool isValidTransactionAmount(double amount) {
    return amount > 0 && amount <= 999999999.99; // Reasonable upper limit
  }

  bool isValidBudgetPeriod(DateTime startDate, DateTime endDate) {
    final now = DateTime.now();
    final maxPeriod = DateTime(now.year + 5, now.month, now.day);
    
    return startDate.isAfter(now.subtract(const Duration(days: 1))) &&
           endDate.isBefore(maxPeriod) &&
           startDate.isBefore(endDate) &&
           endDate.difference(startDate).inDays <= 365 * 5; // Max 5 years
  }
}
