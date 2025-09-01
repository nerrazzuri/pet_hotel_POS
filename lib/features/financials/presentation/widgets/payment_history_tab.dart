import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/payments/domain/entities/payment_transaction.dart';
import 'package:cat_hotel_pos/features/payments/domain/entities/payment_method.dart';
import 'package:cat_hotel_pos/core/services/payment_transaction_dao.dart';

class PaymentHistoryTab extends ConsumerStatefulWidget {
  const PaymentHistoryTab({super.key});

  @override
  ConsumerState<PaymentHistoryTab> createState() => _PaymentHistoryTabState();
}

class _PaymentHistoryTabState extends ConsumerState<PaymentHistoryTab> {
  final PaymentTransactionDao _paymentDao = PaymentTransactionDao();
  List<PaymentTransaction> _payments = [];
  bool _isLoading = true;
  String _searchQuery = '';
  PaymentStatus? _selectedStatus;
  TransactionType? _selectedType;
  PaymentType? _selectedPaymentType;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);
    try {
      final payments = await _paymentDao.getAll();
      setState(() {
        _payments = payments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading payments: $e')),
        );
      }
    }
  }

  List<PaymentTransaction> get _filteredPayments {
    return _payments.where((payment) {
      final matchesSearch = (payment.customerName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (payment.referenceNumber?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (payment.transactionId.toLowerCase().contains(_searchQuery.toLowerCase())) ||
          (payment.orderId?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      
      final matchesStatus = _selectedStatus == null || payment.status == _selectedStatus;
      final matchesType = _selectedType == null || payment.type == _selectedType;
      final matchesPaymentType = _selectedPaymentType == null || payment.paymentMethod.type == _selectedPaymentType;
      
      final matchesDate = _startDate == null || _endDate == null ||
          (payment.createdAt.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
           payment.createdAt.isBefore(_endDate!.add(const Duration(days: 1))));
      
      return matchesSearch && matchesStatus && matchesType && matchesPaymentType && matchesDate;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
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
                    hintText: 'Search payments by customer, reference, transaction ID...',
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
                      child: DropdownButtonFormField<PaymentStatus>(
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
                          ...PaymentStatus.values.map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(_getPaymentStatusDisplayName(status)),
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
                            child: Text(_getTransactionTypeDisplayName(type)),
                          )),
                        ],
                        onChanged: (value) => setState(() => _selectedType = value),
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
                      child: DropdownButtonFormField<PaymentType>(
                        decoration: const InputDecoration(
                          labelText: 'Payment Method',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        value: _selectedPaymentType,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Methods'),
                          ),
                          ...PaymentType.values.map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(_getPaymentTypeDisplayName(type)),
                          )),
                        ],
                        onChanged: (value) => setState(() => _selectedPaymentType = value),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
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
                ],
              ),
              
              // Results count and summary
              if (_filteredPayments.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      '${_filteredPayments.length} payment${_filteredPayments.length == 1 ? '' : 's'} found',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Total: MYR ${_getTotalAmount().toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // Payments list
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
                        'Loading payment history...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : _filteredPayments.isEmpty
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
                              Icons.payment_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No payments found',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isNotEmpty || _selectedStatus != null || _selectedType != null || _selectedPaymentType != null || _startDate != null
                                ? 'Try adjusting your search or filters'
                                : 'No payment transactions recorded yet',
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
                      itemCount: _filteredPayments.length,
                      itemBuilder: (context, index) {
                        final payment = _filteredPayments[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildPaymentCard(payment),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildPaymentCard(PaymentTransaction payment) {
    final isPositive = payment.type == TransactionType.sale || payment.type == TransactionType.deposit;
    final amountColor = isPositive ? Colors.green[700]! : Colors.red[700]!;
    
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
        onTap: () => _showPaymentDetails(payment),
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
                      color: _getPaymentTypeColor(payment.paymentMethod.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getPaymentTypeIcon(payment.paymentMethod.type),
                      color: _getPaymentTypeColor(payment.paymentMethod.type),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment.customerName ?? 'Unknown Customer',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Transaction: ${payment.transactionId}',
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
                      color: _getPaymentStatusColor(payment.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getPaymentStatusDisplayName(payment.status),
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
              
              // Payment details
              Row(
                children: [
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
                          _getTransactionTypeDisplayName(payment.type),
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
                          'Method',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getPaymentTypeDisplayName(payment.paymentMethod.type),
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
                          '${payment.currency} ${payment.amount.toStringAsFixed(2)}',
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
              
              // Additional info
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${payment.createdAt.toString().split(' ')[0]} at ${payment.createdAt.toString().split(' ')[1].substring(0, 5)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (payment.referenceNumber != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.receipt, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ref: ${payment.referenceNumber}',
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
                      onPressed: () => _showPaymentDetails(payment),
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
                  if (payment.status == PaymentStatus.completed && payment.type == TransactionType.sale) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showRefundDialog(payment),
                        icon: const Icon(Icons.money_off, size: 16),
                        label: const Text('Refund'),
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
                    onSelected: (value) => _handlePaymentAction(value, payment),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'print',
                        child: Row(
                          children: [
                            Icon(Icons.print, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Print Receipt'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'export',
                        child: Row(
                          children: [
                            Icon(Icons.file_download, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Export'),
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

  double _getTotalAmount() {
    return _filteredPayments.fold(0.0, (sum, payment) {
      if (payment.type == TransactionType.sale || payment.type == TransactionType.deposit) {
        return sum + payment.amount;
      } else {
        return sum - payment.amount;
      }
    });
  }

  String _getPaymentStatusDisplayName(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      case PaymentStatus.refunded:
        return 'Refunded';
      case PaymentStatus.partiallyRefunded:
        return 'Partially Refunded';
    }
  }

  String _getTransactionTypeDisplayName(TransactionType type) {
    switch (type) {
      case TransactionType.sale:
        return 'Sale';
      case TransactionType.refund:
        return 'Refund';
      case TransactionType.partialRefund:
        return 'Partial Refund';
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.adjustment:
        return 'Adjustment';
      case TransactionType.tip:
        return 'Tip';
      case TransactionType.serviceCharge:
        return 'Service Charge';
    }
  }

  String _getPaymentTypeDisplayName(PaymentType type) {
    switch (type) {
      case PaymentType.cash:
        return 'Cash';
      case PaymentType.creditCard:
        return 'Credit Card';
      case PaymentType.debitCard:
        return 'Debit Card';
      case PaymentType.digitalWallet:
        return 'Digital Wallet';
      case PaymentType.bankTransfer:
        return 'Bank Transfer';
      case PaymentType.voucher:
        return 'Voucher';
      case PaymentType.deposit:
        return 'Deposit';
      case PaymentType.partialPayment:
        return 'Partial Payment';
    }
  }

  Color _getPaymentStatusColor(PaymentStatus status) {
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
        return Colors.amber;
    }
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
        return Icons.attach_money;
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
        return Icons.savings;
      case PaymentType.partialPayment:
        return Icons.payment;
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

  void _showPaymentDetails(PaymentTransaction payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Details - ${payment.transactionId}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Transaction ID', payment.transactionId),
              _buildDetailRow('Customer', payment.customerName ?? 'Unknown'),
              _buildDetailRow('Type', _getTransactionTypeDisplayName(payment.type)),
              _buildDetailRow('Amount', '${payment.currency} ${payment.amount.toStringAsFixed(2)}'),
              _buildDetailRow('Payment Method', _getPaymentTypeDisplayName(payment.paymentMethod.type)),
              _buildDetailRow('Status', _getPaymentStatusDisplayName(payment.status)),
              _buildDetailRow('Date', payment.createdAt.toString().split(' ')[0]),
              _buildDetailRow('Time', payment.createdAt.toString().split(' ')[1].substring(0, 5)),
              if (payment.referenceNumber != null) _buildDetailRow('Reference', payment.referenceNumber!),
              if (payment.orderId != null) _buildDetailRow('Order ID', payment.orderId!),
              if (payment.invoiceId != null) _buildDetailRow('Invoice ID', payment.invoiceId!),
              if (payment.receiptId != null) _buildDetailRow('Receipt ID', payment.receiptId!),
              if (payment.authorizationCode != null) _buildDetailRow('Auth Code', payment.authorizationCode!),
              if (payment.transactionReference != null) _buildDetailRow('Transaction Ref', payment.transactionReference!),
              if (payment.cardType != null) _buildDetailRow('Card Type', payment.cardType!),
              if (payment.cardLast4 != null) _buildDetailRow('Card Last 4', payment.cardLast4!),
              if (payment.processedBy != null) _buildDetailRow('Processed By', payment.processedBy!),
              if (payment.processingFee != null) _buildDetailRow('Processing Fee', '${payment.currency} ${payment.processingFee!.toStringAsFixed(2)}'),
              if (payment.taxAmount != null) _buildDetailRow('Tax Amount', '${payment.currency} ${payment.taxAmount!.toStringAsFixed(2)}'),
              if (payment.tipAmount != null) _buildDetailRow('Tip Amount', '${payment.currency} ${payment.tipAmount!.toStringAsFixed(2)}'),
              if (payment.notes != null) _buildDetailRow('Notes', payment.notes!),
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
            width: 120,
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

  void _showRefundDialog(PaymentTransaction payment) {
    final amountController = TextEditingController(text: payment.amount.toStringAsFixed(2));
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Process Refund'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Original Amount: ${payment.currency} ${payment.amount.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Refund Amount',
                border: OutlineInputBorder(),
                prefixText: 'MYR ',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refund functionality coming soon!')),
              );
            },
            child: const Text('Process Refund'),
          ),
        ],
      ),
    );
  }

  void _handlePaymentAction(String action, PaymentTransaction payment) {
    switch (action) {
      case 'print':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Print receipt functionality coming soon!')),
        );
        break;
      case 'export':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export functionality coming soon!')),
        );
        break;
    }
  }
}
