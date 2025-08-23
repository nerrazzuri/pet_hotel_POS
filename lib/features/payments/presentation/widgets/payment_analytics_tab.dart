import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/payments/domain/services/payment_service.dart';
import 'package:cat_hotel_pos/features/payments/domain/entities/payment_transaction.dart';
import 'package:cat_hotel_pos/features/payments/domain/entities/payment_method.dart';

class PaymentAnalyticsTab extends ConsumerStatefulWidget {
  const PaymentAnalyticsTab({super.key});

  @override
  ConsumerState<PaymentAnalyticsTab> createState() => _PaymentAnalyticsTabState();
}

class _PaymentAnalyticsTabState extends ConsumerState<PaymentAnalyticsTab> {
  final PaymentService _paymentService = PaymentService();
  Map<String, dynamic> _summaryData = {};
  List<PaymentTransaction> _recentTransactions = [];
  bool _isLoading = true;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final summary = await _paymentService.getPaymentSummary(_startDate, _endDate);
      final recent = await _paymentService.getRecentTransactions(limit: 10);
      
      setState(() {
        _summaryData = summary;
        _recentTransactions = recent;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading analytics: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateRangeSelector(),
          const SizedBox(height: 24),
          _buildSummaryCards(),
          const SizedBox(height: 24),
          _buildPaymentMethodBreakdown(),
          const SizedBox(height: 24),
          _buildStatusBreakdown(),
          const SizedBox(height: 24),
          _buildRecentTransactions(),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Date Range',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showDateRangePicker(),
              icon: const Icon(Icons.date_range),
              label: const Text('Change Range'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Transactions',
          '${_summaryData['totalTransactions'] ?? 0}',
          Icons.receipt_long,
          Colors.blue,
        ),
        _buildStatCard(
          'Total Amount',
          'RM ${(_summaryData['totalAmount'] ?? 0.0).toStringAsFixed(2)}',
          Icons.attach_money,
          Colors.green,
        ),
        _buildStatCard(
          'Processing Fees',
          'RM ${(_summaryData['totalProcessingFees'] ?? 0.0).toStringAsFixed(2)}',
          Icons.account_balance,
          Colors.orange,
        ),
        _buildStatCard(
          'Tax Amount',
          'RM ${(_summaryData['totalTaxAmount'] ?? 0.0).toStringAsFixed(2)}',
          Icons.receipt,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodBreakdown() {
    final amountByPaymentType = _summaryData['amountByPaymentType'] as Map<dynamic, dynamic>? ?? {};
    
    if (amountByPaymentType.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No payment method data available'),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Method Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...amountByPaymentType.entries.map((entry) {
              final paymentType = entry.key as PaymentType;
              final amount = entry.value as double;
              final percentage = _summaryData['totalAmount'] > 0 
                  ? (amount / _summaryData['totalAmount'] * 100)
                  : 0.0;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      _getPaymentTypeIcon(paymentType),
                      color: _getPaymentTypeColor(paymentType),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        paymentType.name.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      'RM ${amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${percentage.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBreakdown() {
    final countByStatus = _summaryData['countByStatus'] as Map<dynamic, dynamic>? ?? {};
    
    if (countByStatus.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No status data available'),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transaction Status Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...countByStatus.entries.map((entry) {
              final status = entry.key as PaymentStatus;
              final count = entry.value as int;
              final percentage = _summaryData['totalTransactions'] > 0 
                  ? (count / _summaryData['totalTransactions'] * 100)
                  : 0.0;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        status.name.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      count.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${percentage.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_recentTransactions.isEmpty)
              const Center(
                child: Text('No recent transactions'),
              )
            else
              ..._recentTransactions.map((transaction) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: _getTransactionTypeColor(transaction.type),
                      child: Icon(
                        _getTransactionTypeIcon(transaction.type),
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.transactionId,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            transaction.customerName ?? 'No Customer',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'RM ${transaction.amount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _formatDate(transaction.createdAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )).toList(),
          ],
        ),
      ),
    );
  }

  Color _getPaymentTypeColor(PaymentType type) {
    switch (type) {
      case PaymentType.cash:
        return Colors.green;
      case PaymentType.creditCard:
        return Colors.blue;
      case PaymentType.debitCard:
        return Colors.indigo;
      case PaymentType.digitalWallet:
        return Colors.purple;
      case PaymentType.bankTransfer:
        return Colors.teal;
      case PaymentType.voucher:
        return Colors.orange;
      case PaymentType.deposit:
        return Colors.amber;
      case PaymentType.partialPayment:
        return Colors.grey;
    }
  }

  IconData _getPaymentTypeIcon(PaymentType type) {
    switch (type) {
      case PaymentType.cash:
        return Icons.money;
      case PaymentType.creditCard:
        return Icons.credit_card;
      case PaymentType.debitCard:
        return Icons.credit_card;
      case PaymentType.digitalWallet:
        return Icons.account_balance_wallet;
      case PaymentType.bankTransfer:
        return Icons.account_balance;
      case PaymentType.voucher:
        return Icons.confirmation_number;
      case PaymentType.deposit:
        return Icons.account_balance_wallet;
      case PaymentType.partialPayment:
        return Icons.payment;
    }
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
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDateRangePicker() {
    // TODO: Implement date range picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Date range picker functionality coming soon')),
    );
  }
}
