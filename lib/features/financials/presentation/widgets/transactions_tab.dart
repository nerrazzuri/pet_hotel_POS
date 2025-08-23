import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/financials/domain/entities/financial_transaction.dart';
import 'package:cat_hotel_pos/features/financials/domain/entities/financial_account.dart';
import 'package:cat_hotel_pos/core/services/financial_dao.dart';

class TransactionsTab extends ConsumerStatefulWidget {
  const TransactionsTab({super.key});

  @override
  ConsumerState<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends ConsumerState<TransactionsTab> {
  final FinancialDao _financialDao = FinancialDao();
  List<FinancialTransaction> _transactions = [];
  List<FinancialAccount> _accounts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  TransactionType? _selectedType;
  TransactionCategory? _selectedCategory;
  TransactionStatus? _selectedStatus;
  String? _selectedAccountId;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final futures = await Future.wait([
        _financialDao.getAllTransactions(),
        _financialDao.getAllAccounts(),
      ]);
      
      setState(() {
        _transactions = futures[0] as List<FinancialTransaction>;
        _accounts = futures[1] as List<FinancialAccount>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  List<FinancialTransaction> get _filteredTransactions {
    return _transactions.where((transaction) {
      final matchesSearch = (transaction.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (transaction.reference?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          transaction.id.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesType = _selectedType == null || transaction.type == _selectedType;
      final matchesCategory = _selectedCategory == null || transaction.category == _selectedCategory;
      final matchesStatus = _selectedStatus == null || (transaction.status ?? TransactionStatus.pending) == _selectedStatus;
      final matchesAccount = _selectedAccountId == null || transaction.accountId == _selectedAccountId;
      
      final matchesDate = _startDate == null || _endDate == null ||
          (transaction.transactionDate.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
           transaction.transactionDate.isBefore(_endDate!.add(const Duration(days: 1))));
      
      return matchesSearch && matchesType && matchesCategory && matchesStatus && matchesAccount && matchesDate;
    }).toList()
      ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and filters
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search transactions...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
              const SizedBox(height: 16),
              
              // Filter row 1
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<TransactionType>(
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedType,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Types'),
                        ),
                        ...TransactionType.values.map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.displayName),
                        )),
                      ],
                      onChanged: (value) => setState(() => _selectedType = value),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<TransactionCategory>(
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedCategory,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Categories'),
                        ),
                        ...TransactionCategory.values.map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category.displayName),
                        )),
                      ],
                      onChanged: (value) => setState(() => _selectedCategory = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Filter row 2
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<TransactionStatus>(
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedStatus,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Statuses'),
                        ),
                        ...TransactionStatus.values.map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.displayName),
                        )),
                      ],
                      onChanged: (value) => setState(() => _selectedStatus = value),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Account',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedAccountId,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Accounts'),
                        ),
                        ..._accounts.map((account) => DropdownMenuItem(
                          value: account.id,
                          child: Text(account.accountName),
                        )),
                      ],
                      onChanged: (value) => setState(() => _selectedAccountId = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Date range
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDateRange(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              _startDate == null || _endDate == null
                                  ? 'Select Date Range'
                                  : '${_startDate!.toString().split(' ')[0]} - ${_endDate!.toString().split(' ')[0]}',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () => setState(() {
                      _startDate = null;
                      _endDate = null;
                    }),
                    child: const Text('Clear Dates'),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Transactions list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredTransactions.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No transactions found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = _filteredTransactions[index];
                        return _buildTransactionCard(transaction);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(FinancialTransaction transaction) {
    final account = _accounts.firstWhere(
      (acc) => acc.id == transaction.accountId,
      orElse: () => FinancialAccount.create(
        accountName: 'Unknown Account',
        accountNumber: 'N/A',
        accountType: AccountType.checking,
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _getTransactionTypeColor(transaction.type),
          child: Icon(
            _getTransactionTypeIcon(transaction.type),
            color: Colors.white,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                transaction.description ?? 'No Description',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(transaction.status ?? TransactionStatus.pending),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                (transaction.status ?? TransactionStatus.pending).displayName,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Account: ${account.accountName}'),
            Text('Category: ${transaction.category.displayName}'),
            if (transaction.reference != null) Text('Reference: ${transaction.reference}'),
            Row(
              children: [
                Text('Date: ${transaction.transactionDate.toString().split(' ')[0]}'),
                const SizedBox(width: 16),
                Text('Time: ${transaction.transactionDate.toString().split(' ')[1].substring(0, 5)}'),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${transaction.currency} ${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: transaction.type.isCredit ? Colors.green[700] : Colors.red[700],
              ),
            ),
            Text(
              transaction.type.displayName,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) => _handleTransactionAction(value, transaction),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                if ((transaction.status ?? TransactionStatus.pending) == TransactionStatus.pending)
                  const PopupMenuItem(
                    value: 'approve',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Approve'),
                      ],
                    ),
                  ),
                if ((transaction.status ?? TransactionStatus.pending) == TransactionStatus.completed)
                  const PopupMenuItem(
                    value: 'reverse',
                    child: Row(
                      children: [
                        Icon(Icons.undo, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Reverse'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTransactionTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return Colors.green;
      case TransactionType.withdrawal:
        return Colors.red;
      case TransactionType.transfer:
        return Colors.blue;
      case TransactionType.payment:
        return Colors.orange;
      case TransactionType.refund:
        return Colors.teal;
      case TransactionType.fee:
        return Colors.purple;
      case TransactionType.interest:
        return Colors.indigo;
      case TransactionType.adjustment:
        return Colors.grey;
    }
  }

  IconData _getTransactionTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return Icons.add_circle;
      case TransactionType.withdrawal:
        return Icons.remove_circle;
      case TransactionType.transfer:
        return Icons.swap_horiz;
      case TransactionType.payment:
        return Icons.payment;
      case TransactionType.refund:
        return Icons.money_off;
      case TransactionType.fee:
        return Icons.receipt;
      case TransactionType.interest:
        return Icons.trending_up;
      case TransactionType.adjustment:
        return Icons.tune;
    }
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.completed:
        return Colors.green;
      case TransactionStatus.failed:
        return Colors.red;
      case TransactionStatus.cancelled:
        return Colors.grey;
      case TransactionStatus.reversed:
        return Colors.purple;
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _handleTransactionAction(String action, FinancialTransaction transaction) {
    switch (action) {
      case 'view':
        _showTransactionDetails(transaction);
        break;
      case 'edit':
        _showEditTransactionDialog(transaction);
        break;
      case 'approve':
        _approveTransaction(transaction);
        break;
      case 'reverse':
        _reverseTransaction(transaction);
        break;
      case 'delete':
        _deleteTransaction(transaction);
        break;
    }
  }

  void _showTransactionDetails(FinancialTransaction transaction) {
    final account = _accounts.firstWhere(
      (acc) => acc.id == transaction.accountId,
      orElse: () => FinancialAccount.create(
        accountName: 'Unknown Account',
        accountNumber: 'N/A',
        accountType: AccountType.checking,
      ),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transaction Details - ${transaction.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Transaction ID', transaction.id),
              _buildDetailRow('Account', account.accountName),
              _buildDetailRow('Type', transaction.type.displayName),
              _buildDetailRow('Category', transaction.category.displayName),
              _buildDetailRow('Amount', '${transaction.currency} ${transaction.amount.toStringAsFixed(2)}'),
              _buildDetailRow('Date', transaction.transactionDate.toString().split(' ')[0]),
              _buildDetailRow('Time', transaction.transactionDate.toString().split(' ')[1].substring(0, 5)),
              _buildDetailRow('Status', (transaction.status ?? TransactionStatus.pending).displayName),
              if (transaction.description != null) _buildDetailRow('Description', transaction.description!),
              if (transaction.reference != null) _buildDetailRow('Reference', transaction.reference!),
              if (transaction.relatedTransactionId != null) _buildDetailRow('Related Transaction', transaction.relatedTransactionId!),
              if (transaction.notes != null) _buildDetailRow('Notes', transaction.notes!),
              _buildDetailRow('Created', transaction.createdAt.toString().split(' ')[0]),
              _buildDetailRow('Last Updated', transaction.updatedAt.toString().split(' ')[0]),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showEditTransactionDialog(FinancialTransaction transaction) {
    // TODO: Implement edit transaction dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit transaction functionality coming soon!')),
    );
  }

  Future<void> _approveTransaction(FinancialTransaction transaction) async {
    try {
      final updatedTransaction = transaction.copyWith(
        status: TransactionStatus.completed,
        updatedAt: DateTime.now(),
      );
      await _financialDao.updateTransaction(updatedTransaction);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction has been approved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error approving transaction: $e')),
        );
      }
    }
  }

  Future<void> _reverseTransaction(FinancialTransaction transaction) async {
    try {
      final updatedTransaction = transaction.copyWith(
        status: TransactionStatus.reversed,
        updatedAt: DateTime.now(),
      );
      await _financialDao.updateTransaction(updatedTransaction);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction has been reversed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error reversing transaction: $e')),
        );
      }
    }
  }

  Future<void> _deleteTransaction(FinancialTransaction transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text(
          'Are you sure you want to delete this transaction? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _financialDao.deleteTransaction(transaction.id);
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction has been deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting transaction: $e')),
          );
        }
      }
    }
  }
}
