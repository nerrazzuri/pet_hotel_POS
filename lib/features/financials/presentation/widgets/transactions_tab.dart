import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/financials/domain/entities/financial_transaction.dart';
import 'package:cat_hotel_pos/features/financials/domain/entities/financial_account.dart';
import 'package:cat_hotel_pos/core/services/financial_dao.dart';
import 'package:cat_hotel_pos/features/financials/presentation/widgets/add_transaction_dialog.dart';

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
        // Header with search and filters
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search transactions by description, reference, or ID...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              const SizedBox(height: 16),
              
              // Filter row 1
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: DropdownButtonFormField<TransactionType>(
                        decoration: const InputDecoration(
                          labelText: 'Type',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
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
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: DropdownButtonFormField<TransactionCategory>(
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
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
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Filter row 2
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: DropdownButtonFormField<TransactionStatus>(
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
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
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Account',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
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
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Date range
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDateRange(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _startDate == null || _endDate == null
                                    ? 'Select Date Range'
                                    : '${_startDate!.toString().split(' ')[0]} - ${_endDate!.toString().split(' ')[0]}',
                                style: TextStyle(
                                  color: _startDate == null || _endDate == null 
                                      ? Colors.grey[500] 
                                      : Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton.icon(
                    onPressed: () => setState(() {
                      _startDate = null;
                      _endDate = null;
                    }),
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              // Results count
              if (_filteredTransactions.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      '${_filteredTransactions.length} transaction${_filteredTransactions.length == 1 ? '' : 's'} found',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _showAddTransactionDialog,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Transaction'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'No transactions found',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _showAddTransactionDialog,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Transaction'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // Transactions list
        Expanded(
          child: _isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[800]!),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading transactions...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : _filteredTransactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No transactions found',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isNotEmpty || _selectedType != null || _selectedCategory != null || _selectedStatus != null || _selectedAccountId != null || _startDate != null
                                ? 'Try adjusting your search or filters'
                                : 'No transactions recorded yet',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = _filteredTransactions[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildTransactionCard(transaction),
                        );
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

    final isCredit = transaction.type.isCredit;
    final amountColor = isCredit ? Colors.green[700]! : Colors.red[700]!;
    final status = transaction.status ?? TransactionStatus.pending;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showTransactionDetails(transaction),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getTransactionTypeColor(transaction.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getTransactionTypeIcon(transaction.type),
                      color: _getTransactionTypeColor(transaction.type),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.description ?? 'No Description',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Account: ${account.accountName}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Transaction details
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Category',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          transaction.category.displayName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Type',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          transaction.type.displayName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Amount',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${transaction.currency} ${transaction.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: amountColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Date and reference
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${transaction.transactionDate.toString().split(' ')[0]} at ${transaction.transactionDate.toString().split(' ')[1].substring(0, 5)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (transaction.reference != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.receipt, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ref: ${transaction.reference}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showTransactionDetails(transaction),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('View Details'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: BorderSide(color: Colors.blue.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (status == TransactionStatus.pending) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _approveTransaction(transaction),
                        icon: const Icon(Icons.check_circle, size: 16),
                        label: const Text('Approve'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: BorderSide(color: Colors.green.withOpacity(0.3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (status == TransactionStatus.completed) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _reverseTransaction(transaction),
                        icon: const Icon(Icons.undo, size: 16),
                        label: const Text('Reverse'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: BorderSide(color: Colors.orange.withOpacity(0.3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                    onSelected: (value) => _handleTransactionAction(value, transaction),
                    itemBuilder: (context) => [
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
            ],
          ),
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

  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(
        accounts: _accounts,
        onTransactionAdded: (transaction) {
          _loadData();
        },
      ),
    );
  }
}
