import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/pos_cart.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/partial_payment.dart';
import 'package:cat_hotel_pos/features/pos/domain/services/partial_payment_service.dart';
import 'package:cat_hotel_pos/features/pos/presentation/providers/pos_providers.dart';

class PartialPaymentWidget extends ConsumerStatefulWidget {
  const PartialPaymentWidget({super.key});

  @override
  ConsumerState<PartialPaymentWidget> createState() => _PartialPaymentWidgetState();
}

class _PartialPaymentWidgetState extends ConsumerState<PartialPaymentWidget> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  String _selectedPaymentMethod = 'cash';
  bool _showPartialPaymentForm = false;
  bool _showSplitBillForm = false;

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(currentCartProvider);
    final cartItems = ref.watch(cartItemsProvider);

    if (cart == null || cartItems.isEmpty) {
      return const SizedBox.shrink();
    }

    final paymentSummary = PartialPaymentService.calculatePaymentSummary(cart);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: Colors.indigo, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Payment Management',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (!paymentSummary.isFullyPaid) ...[
                  IconButton(
                    icon: Icon(_showPartialPaymentForm ? Icons.close : Icons.add),
                    onPressed: () {
                      setState(() {
                        _showPartialPaymentForm = !_showPartialPaymentForm;
                        _showSplitBillForm = false;
                        if (!_showPartialPaymentForm) {
                          _clearForm();
                        }
                      });
                    },
                    tooltip: _showPartialPaymentForm ? 'Close Form' : 'Add Payment',
                  ),
                  IconButton(
                    icon: Icon(Icons.call_split),
                    onPressed: () {
                      setState(() {
                        _showSplitBillForm = !_showSplitBillForm;
                        _showPartialPaymentForm = false;
                        if (!_showSplitBillForm) {
                          _clearForm();
                        }
                      });
                    },
                    tooltip: 'Split Bill',
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // Payment Summary
            _buildPaymentSummary(paymentSummary),

            const SizedBox(height: 16),

            // Partial Payment Form
            if (_showPartialPaymentForm) ...[
              _buildPartialPaymentForm(cart, paymentSummary),
              const SizedBox(height: 16),
            ],

            // Split Bill Form
            if (_showSplitBillForm) ...[
              _buildSplitBillForm(cart, paymentSummary),
              const SizedBox(height: 16),
            ],

            // Partial Payments List
            if (cart.partialPayments != null && cart.partialPayments!.isNotEmpty) ...[
              _buildPartialPaymentsList(cart.partialPayments!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary(PaymentSummary summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: summary.isFullyPaid ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: summary.isFullyPaid ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                summary.isFullyPaid ? Icons.check_circle : Icons.pending,
                color: summary.isFullyPaid ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(
                summary.isFullyPaid ? 'Payment Complete' : 'Payment Pending',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: summary.isFullyPaid ? Colors.green.shade700 : Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildSummaryItem('Total Amount', 'RM${summary.totalAmount.toStringAsFixed(2)}'),
              ),
              Expanded(
                child: _buildSummaryItem('Amount Paid', 'RM${summary.amountPaid.toStringAsFixed(2)}'),
              ),
            ],
          ),

          Row(
            children: [
              Expanded(
                child: _buildSummaryItem('Remaining', 'RM${summary.remainingBalance.toStringAsFixed(2)}'),
              ),
              Expanded(
                child: _buildSummaryItem('Change', 'RM${summary.changeAmount.toStringAsFixed(2)}'),
              ),
            ],
          ),

          if (summary.paymentsByMethod.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Payment Methods:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            ...summary.paymentsByMethod.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _formatPaymentMethod(entry.key),
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  Text(
                    'RM${entry.value.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildPartialPaymentForm(POSCart cart, PaymentSummary summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.indigo.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Partial Payment',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade700,
            ),
          ),
          const SizedBox(height: 16),

          // Payment Method and Amount
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedPaymentMethod,
                  decoration: InputDecoration(
                    labelText: 'Payment Method',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'cash', child: Text('Cash')),
                    DropdownMenuItem(value: 'card', child: Text('Card')),
                    DropdownMenuItem(value: 'e_wallet', child: Text('E-Wallet')),
                    DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer')),
                    DropdownMenuItem(value: 'duitnow', child: Text('DuitNow')),
                    DropdownMenuItem(value: 'tng', child: Text('Touch n Go')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount (RM)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixText: 'RM ',
                    hintText: 'Max: ${summary.remainingBalance.toStringAsFixed(2)}',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Reference and Notes
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _referenceController,
                  decoration: InputDecoration(
                    labelText: 'Reference (Optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'e.g., Card auth code',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'Notes (Optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'e.g., Customer request',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _addPartialPayment,
                  icon: Icon(Icons.add),
                  label: Text('Add Payment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearForm,
                  icon: Icon(Icons.clear),
                  label: Text('Clear'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSplitBillForm(POSCart cart, PaymentSummary summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Split Bill',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total to split: RM${summary.totalAmount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),

          // Split Options
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _splitBillEqually(cart, summary),
                  icon: Icon(Icons.equalizer),
                  label: Text('Split Equally'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showCustomSplitDialog(cart, summary),
                  icon: Icon(Icons.edit),
                  label: Text('Custom Split'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartialPaymentsList(List<PartialPayment> payments) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Payment History',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...payments.map((payment) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_formatPaymentMethod(payment.paymentMethod)} - RM${payment.amount.toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        _formatDateTime(payment.paidAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (payment.notes != null && payment.notes!.isNotEmpty)
                        Text(
                          payment.notes!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.remove_circle, color: Colors.red, size: 20),
                  onPressed: () => _removePartialPayment(payment),
                  tooltip: 'Remove payment',
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _addPartialPayment() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount');
      return;
    }

    final cart = ref.read(currentCartProvider);
    if (cart == null) return;

    final result = PartialPaymentService.addPartialPayment(
      cart,
      _selectedPaymentMethod,
      amount,
      cart.cashierId ?? 'system',
      reference: _referenceController.text.isNotEmpty ? _referenceController.text : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    if (result.success) {
      ref.read(currentCartProvider.notifier).addPartialPayment(result);
      _clearForm();
      setState(() {
        _showPartialPaymentForm = false;
      });
      _showSuccess('Partial payment added successfully!');
    } else {
      _showError(result.errorMessage ?? 'Failed to add payment');
    }
  }

  void _splitBillEqually(POSCart cart, PaymentSummary summary) {
    final totalAmount = summary.totalAmount;
    final numberOfSplits = 2; // Default to 2 splits
    final amountPerSplit = totalAmount / numberOfSplits;

    final splitItems = [
      BillSplitItem(
        id: '1',
        paymentMethod: 'cash',
        amount: amountPerSplit,
        paidBy: cart.cashierId ?? 'system',
      ),
      BillSplitItem(
        id: '2',
        paymentMethod: 'card',
        amount: amountPerSplit,
        paidBy: cart.cashierId ?? 'system',
      ),
    ];

    final result = PartialPaymentService.splitBill(cart, splitItems);
    if (result.success) {
      ref.read(currentCartProvider.notifier).splitBill(result);
      _showSuccess('Bill split equally!');
    } else {
      _showError(result.errorMessage ?? 'Failed to split bill');
    }
  }

  void _showCustomSplitDialog(POSCart cart, PaymentSummary summary) {
    final totalAmount = summary.totalAmount;
    final amountController1 = TextEditingController();
    final amountController2 = TextEditingController();
    final paymentMethod1 = TextEditingController(text: 'cash');
    final paymentMethod2 = TextEditingController(text: 'card');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Custom Bill Split'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total: RM${totalAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('Payment 1'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: 'cash',
                        decoration: InputDecoration(
                          labelText: 'Method',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'cash', child: Text('Cash')),
                          DropdownMenuItem(value: 'card', child: Text('Card')),
                          DropdownMenuItem(value: 'e_wallet', child: Text('E-Wallet')),
                        ],
                        onChanged: (value) {
                          if (value != null) paymentMethod1.text = value;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: amountController1,
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          border: OutlineInputBorder(),
                          prefixText: 'RM ',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      Text('Payment 2'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: 'card',
                        decoration: InputDecoration(
                          labelText: 'Method',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'cash', child: Text('Cash')),
                          DropdownMenuItem(value: 'card', child: Text('Card')),
                          DropdownMenuItem(value: 'e_wallet', child: Text('E-Wallet')),
                        ],
                        onChanged: (value) {
                          if (value != null) paymentMethod2.text = value;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: amountController2,
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          border: OutlineInputBorder(),
                          prefixText: 'RM ',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount1 = double.tryParse(amountController1.text);
              final amount2 = double.tryParse(amountController2.text);
              
              if (amount1 != null && amount2 != null && 
                  (amount1 + amount2 - totalAmount).abs() < 0.01) {
                final splitItems = [
                  BillSplitItem(
                    id: '1',
                    paymentMethod: paymentMethod1.text,
                    amount: amount1,
                    paidBy: cart.cashierId ?? 'system',
                  ),
                  BillSplitItem(
                    id: '2',
                    paymentMethod: paymentMethod2.text,
                    amount: amount2,
                    paidBy: cart.cashierId ?? 'system',
                  ),
                ];

                final result = PartialPaymentService.splitBill(cart, splitItems);
                if (result.success) {
                  ref.read(currentCartProvider.notifier).splitBill(result);
                  Navigator.pop(context);
                  _showSuccess('Bill split successfully!');
                } else {
                  _showError(result.errorMessage ?? 'Failed to split bill');
                }
              } else {
                _showError('Split amounts must equal total amount');
              }
            },
            child: Text('Split'),
          ),
        ],
      ),
    );
  }

  void _removePartialPayment(PartialPayment payment) {
    ref.read(currentCartProvider.notifier).removePartialPayment(payment);
    _showSuccess('Payment removed');
  }

  void _clearForm() {
    _amountController.clear();
    _referenceController.clear();
    _notesController.clear();
    setState(() {
      _selectedPaymentMethod = 'cash';
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _formatPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Cash';
      case 'card':
        return 'Credit/Debit Card';
      case 'e_wallet':
        return 'E-Wallet';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'duitnow':
        return 'DuitNow';
      case 'tng':
        return 'Touch n Go';
      default:
        return method.replaceAll('_', ' ').toUpperCase();
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
