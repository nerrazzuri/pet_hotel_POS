import 'package:flutter/material.dart';
import '../../../../core/services/loyalty_dao.dart';
import '../../domain/entities/loyalty_transaction.dart';

class LoyaltyTransactionsTab extends StatefulWidget {
  final LoyaltyDao loyaltyDao;

  const LoyaltyTransactionsTab({super.key, required this.loyaltyDao});

  @override
  State<LoyaltyTransactionsTab> createState() => _LoyaltyTransactionsTabState();
}

class _LoyaltyTransactionsTabState extends State<LoyaltyTransactionsTab> {
  List<LoyaltyTransaction> _transactions = [];
  bool _isLoading = true;
  String _searchQuery = '';
  LoyaltyTransactionType? _selectedType;
  LoyaltyTransactionStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      final transactions = await widget.loyaltyDao.getAllLoyaltyTransactions();
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading transactions: $e')),
        );
      }
    }
  }

  List<LoyaltyTransaction> get _filteredTransactions {
    return _transactions.where((tx) {
      final matchesSearch = tx.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tx.customerId.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _selectedType == null || tx.type == _selectedType;
      final matchesStatus = _selectedStatus == null || tx.status == _selectedStatus;
      return matchesSearch && matchesType && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _buildFilters(),
        Expanded(
          child: _filteredTransactions.isEmpty
              ? const Center(child: Text('No transactions found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
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

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Search transactions',
              hintText: 'Search by description or customer ID',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<LoyaltyTransactionType>(
                  decoration: const InputDecoration(
                    labelText: 'Transaction Type',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedType,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Types'),
                    ),
                    ...LoyaltyTransactionType.values.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(_getTransactionTypeDisplay(type)),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<LoyaltyTransactionStatus>(
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
                    ...LoyaltyTransactionStatus.values.map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(_getTransactionStatusDisplay(status)),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(LoyaltyTransaction transaction) {
    final isEarned = transaction.type == LoyaltyTransactionType.earned;
    final isRedeemed = transaction.type == LoyaltyTransactionType.redeemed;
    final isExpired = transaction.type == LoyaltyTransactionType.expired;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTransactionTypeColor(transaction.type),
          child: Icon(
            _getTransactionTypeIcon(transaction.type),
            color: Colors.white,
          ),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer ID: ${transaction.customerId}'),
            if (transaction.referenceId != null)
              Text('Reference: ${transaction.referenceId}'),
            Text('Date: ${_formatDate(transaction.createdAt)}'),
          ],
        ),
        trailing: SizedBox(
          width: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${isEarned ? '+' : ''}${transaction.points}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isEarned ? Colors.green : isRedeemed ? Colors.red : Colors.orange,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: _getTransactionStatusColor(transaction.status),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getTransactionStatusDisplay(transaction.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }

  Color _getTransactionTypeColor(LoyaltyTransactionType type) {
    switch (type) {
      case LoyaltyTransactionType.earned:
        return Colors.green;
      case LoyaltyTransactionType.redeemed:
        return Colors.red;
      case LoyaltyTransactionType.expired:
        return Colors.orange;
      case LoyaltyTransactionType.adjusted:
        return Colors.blue;
      case LoyaltyTransactionType.bonus:
        return Colors.purple;
    }
  }

  IconData _getTransactionTypeIcon(LoyaltyTransactionType type) {
    switch (type) {
      case LoyaltyTransactionType.earned:
        return Icons.add_circle;
      case LoyaltyTransactionType.redeemed:
        return Icons.remove_circle;
      case LoyaltyTransactionType.expired:
        return Icons.timer_off;
      case LoyaltyTransactionType.adjusted:
        return Icons.edit;
      case LoyaltyTransactionType.bonus:
        return Icons.star;
    }
  }

  Color _getTransactionStatusColor(LoyaltyTransactionStatus status) {
    switch (status) {
      case LoyaltyTransactionStatus.pending:
        return Colors.orange;
      case LoyaltyTransactionStatus.completed:
        return Colors.green;
      case LoyaltyTransactionStatus.cancelled:
        return Colors.red;
      case LoyaltyTransactionStatus.failed:
        return Colors.grey;
    }
  }

  String _getTransactionTypeDisplay(LoyaltyTransactionType type) {
    switch (type) {
      case LoyaltyTransactionType.earned:
        return 'Earned';
      case LoyaltyTransactionType.redeemed:
        return 'Redeemed';
      case LoyaltyTransactionType.expired:
        return 'Expired';
      case LoyaltyTransactionType.adjusted:
        return 'Adjusted';
      case LoyaltyTransactionType.bonus:
        return 'Bonus';
    }
  }

  String _getTransactionStatusDisplay(LoyaltyTransactionStatus status) {
    switch (status) {
      case LoyaltyTransactionStatus.pending:
        return 'Pending';
      case LoyaltyTransactionStatus.completed:
        return 'Completed';
      case LoyaltyTransactionStatus.cancelled:
        return 'Cancelled';
      case LoyaltyTransactionStatus.failed:
        return 'Failed';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showTransactionDetails(LoyaltyTransaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transaction Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('ID', transaction.id),
            _buildDetailRow('Customer ID', transaction.customerId),
            _buildDetailRow('Type', _getTransactionTypeDisplay(transaction.type)),
            _buildDetailRow('Status', _getTransactionStatusDisplay(transaction.status)),
            _buildDetailRow('Points', '${transaction.points}'),
            _buildDetailRow('Description', transaction.description),
            if (transaction.referenceId != null)
              _buildDetailRow('Reference ID', transaction.referenceId!),
            if (transaction.referenceType != null)
              _buildDetailRow('Reference Type', transaction.referenceType!),
            _buildDetailRow('Created', _formatDate(transaction.createdAt)),
            if (transaction.processedAt != null)
              _buildDetailRow('Processed', _formatDate(transaction.processedAt!)),
            if (transaction.expiresAt != null)
              _buildDetailRow('Expires', _formatDate(transaction.expiresAt!)),
            if (transaction.notes != null)
              _buildDetailRow('Notes', transaction.notes!),
          ],
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
            width: 100,
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
}
