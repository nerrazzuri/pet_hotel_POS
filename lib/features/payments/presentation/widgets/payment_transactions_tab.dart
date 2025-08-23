import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/payments/domain/entities/payment_transaction.dart';
import 'package:cat_hotel_pos/features/payments/domain/entities/payment_method.dart';
import 'package:cat_hotel_pos/features/payments/domain/services/payment_service.dart';

class PaymentTransactionsTab extends ConsumerStatefulWidget {
  const PaymentTransactionsTab({super.key});

  @override
  ConsumerState<PaymentTransactionsTab> createState() => _PaymentTransactionsTabState();
}

class _PaymentTransactionsTabState extends ConsumerState<PaymentTransactionsTab> {
  final PaymentService _paymentService = PaymentService();
  List<PaymentTransaction> _transactions = [];
  List<PaymentTransaction> _filteredTransactions = [];
  bool _isLoading = true;
  String _searchQuery = '';
  PaymentStatus? _selectedStatus;
  TransactionType? _selectedType;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final transactions = await _paymentService.getAllTransactions();
      setState(() {
        _transactions = transactions;
        _filteredTransactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading transactions: $e')),
        );
      }
    }
  }

  void _filterTransactions() {
    setState(() {
      _filteredTransactions = _transactions.where((transaction) {
        bool matchesSearch = _searchQuery.isEmpty ||
            transaction.transactionId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (transaction.customerName ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (transaction.notes ?? '').toLowerCase().contains(_searchQuery.toLowerCase());

        bool matchesStatus = _selectedStatus == null || transaction.status == _selectedStatus;
        bool matchesType = _selectedType == null || transaction.type == _selectedType;

        return matchesSearch && matchesStatus && matchesType;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
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
                ),
                onChanged: (value) {
                  _searchQuery = value;
                  _filterTransactions();
                },
              ),
              const SizedBox(height: 16),
              // Filters
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<PaymentStatus?>(
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
                        ...PaymentStatus.values.map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.name.toUpperCase()),
                        )),
                      ],
                      onChanged: (value) {
                        _selectedStatus = value;
                        _filterTransactions();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<TransactionType?>(
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
                          child: Text(type.name.toUpperCase()),
                        )),
                      ],
                      onChanged: (value) {
                        _selectedType = value;
                        _filterTransactions();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _filteredTransactions.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No transactions found'),
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

  Widget _buildTransactionCard(PaymentTransaction transaction) {
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
          transaction.transactionId,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transaction.customerName != null)
              Text('Customer: ${transaction.customerName}'),
            Text('Amount: RM ${transaction.amount.toStringAsFixed(2)}'),
            Text('Method: ${transaction.paymentMethod.name}'),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(transaction.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    transaction.status.name.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(transaction.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTransactionTypeColor(transaction.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    transaction.type.name.toUpperCase(),
                    style: TextStyle(
                      color: _getTransactionTypeColor(transaction.type),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'Date: ${_formatDate(transaction.createdAt)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            if (transaction.notes != null && transaction.notes!.isNotEmpty)
              Text(
                'Notes: ${transaction.notes}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
            ),
            if (transaction.status == PaymentStatus.pending)
              const PopupMenuItem(
                value: 'complete',
                child: Row(
                  children: [
                    Icon(Icons.check_circle),
                    SizedBox(width: 8),
                    Text('Complete'),
                  ],
                ),
              ),
            if (transaction.status == PaymentStatus.pending)
              const PopupMenuItem(
                value: 'fail',
                child: Row(
                  children: [
                    Icon(Icons.cancel),
                    SizedBox(width: 8),
                    Text('Mark Failed'),
                  ],
                ),
              ),
            if (transaction.status == PaymentStatus.completed)
              const PopupMenuItem(
                value: 'refund',
                child: Row(
                  children: [
                    Icon(Icons.undo),
                    SizedBox(width: 8),
                    Text('Process Refund'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'receipt',
              child: Row(
                children: [
                  Icon(Icons.receipt),
                  SizedBox(width: 8),
                  Text('View Receipt'),
                ],
              ),
            ),
          ],
          onSelected: (value) async {
            switch (value) {
              case 'view':
                _showTransactionDetailsDialog(context, transaction);
                break;
              case 'complete':
                await _completeTransaction(transaction.id);
                break;
              case 'fail':
                _showFailTransactionDialog(context, transaction);
                break;
              case 'refund':
                _showRefundDialog(context, transaction);
                break;
              case 'receipt':
                _showReceiptDialog(context, transaction);
                break;
            }
          },
        ),
      ),
    );
  }

  Color _getTransactionTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.sale:
        return Colors.green;
      case TransactionType.refund:
        return Colors.red;
      case TransactionType.partialRefund:
        return Colors.orange;
      case TransactionType.deposit:
        return Colors.blue;
      case TransactionType.withdrawal:
        return Colors.purple;
      case TransactionType.adjustment:
        return Colors.grey;
      case TransactionType.tip:
        return Colors.amber;
      case TransactionType.serviceCharge:
        return Colors.indigo;
    }
  }

  IconData _getTransactionTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.sale:
        return Icons.shopping_cart;
      case TransactionType.refund:
        return Icons.undo;
      case TransactionType.partialRefund:
        return Icons.undo;
      case TransactionType.deposit:
        return Icons.account_balance_wallet;
      case TransactionType.withdrawal:
        return Icons.account_balance;
      case TransactionType.adjustment:
        return Icons.tune;
      case TransactionType.tip:
        return Icons.tips_and_updates;
      case TransactionType.serviceCharge:
        return Icons.receipt;
    }
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.processing:
        return Colors.blue;
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.cancelled:
        return Colors.grey;
      case PaymentStatus.refunded:
        return Colors.purple;
      case PaymentStatus.partiallyRefunded:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _completeTransaction(String id) async {
    try {
      await _paymentService.completePayment(id);
      await _loadTransactions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction completed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error completing transaction: $e')),
        );
      }
    }
  }

  void _showTransactionDetailsDialog(BuildContext context, PaymentTransaction transaction) {
    // TODO: Implement transaction details dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction details functionality coming soon')),
    );
  }

  void _showFailTransactionDialog(BuildContext context, PaymentTransaction transaction) {
    // TODO: Implement fail transaction dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fail transaction functionality coming soon')),
    );
  }

  void _showRefundDialog(BuildContext context, PaymentTransaction transaction) {
    // TODO: Implement refund dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Refund functionality coming soon')),
    );
  }

  void _showReceiptDialog(BuildContext context, PaymentTransaction transaction) {
    // TODO: Implement receipt dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Receipt functionality coming soon')),
    );
  }
}
