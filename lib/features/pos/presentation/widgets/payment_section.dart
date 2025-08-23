import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/pos/presentation/providers/pos_providers.dart';

class PaymentSection extends ConsumerStatefulWidget {
  const PaymentSection({super.key});

  @override
  ConsumerState<PaymentSection> createState() => _PaymentSectionState();
}

class _PaymentSectionState extends ConsumerState<PaymentSection> {
  String _selectedPaymentMethod = 'cash';
  final TextEditingController _amountPaidController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountPaidController.addListener(_updateChangeAmount);
  }

  @override
  void dispose() {
    _amountPaidController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateChangeAmount() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cartTotal = ref.watch(cartTotalProvider);
    final cartItems = ref.watch(cartItemsProvider);
    final amountPaid = double.tryParse(_amountPaidController.text) ?? 0.0;
    final changeAmount = amountPaid - cartTotal;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.payment,
                  color: Colors.teal,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Payment & Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Customer Information
            if (cartItems.isNotEmpty) ...[
              _buildCustomerSection(),
              const SizedBox(height: 20),
            ],
            
            // Payment Method
            if (cartItems.isNotEmpty) ...[
              _buildPaymentMethodSection(),
              const SizedBox(height: 20),
            ],
            
            // Amount Paid
            if (cartItems.isNotEmpty) ...[
              _buildAmountPaidSection(changeAmount),
              const SizedBox(height: 20),
            ],
            
            // Action Buttons
            if (cartItems.isNotEmpty) ...[
              _buildActionButtons(),
            ] else ...[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.payment_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Add items to cart to enable payment',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.person,
              size: 20,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              'Customer Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _customerNameController,
          decoration: InputDecoration(
            labelText: 'Customer Name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.teal, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          onChanged: (value) {
            ref.read(currentCartProvider.notifier).setCustomerInfo(
              null,
              value.isEmpty ? null : value,
              _customerPhoneController.text.isEmpty ? null : _customerPhoneController.text,
            );
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _customerPhoneController,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.teal, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          onChanged: (value) {
            ref.read(currentCartProvider.notifier).setCustomerInfo(
              null,
              _customerNameController.text.isEmpty ? null : _customerNameController.text,
              value.isEmpty ? null : value,
            );
          },
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.credit_card,
              size: 20,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedPaymentMethod,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.teal, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          items: const [
            DropdownMenuItem(value: 'cash', child: Text('Cash')),
            DropdownMenuItem(value: 'card', child: Text('Card')),
            DropdownMenuItem(value: 'e_wallet', child: Text('E-Wallet')),
            DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedPaymentMethod = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAmountPaidSection(double changeAmount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.attach_money,
              size: 20,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              'Amount Paid',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _amountPaidController,
          decoration: InputDecoration(
            labelText: 'Amount',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.teal, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            prefixText: '\$',
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          keyboardType: TextInputType.number,
        ),
        if (changeAmount > 0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.attach_money, color: Colors.green[600]),
                const SizedBox(width: 8),
                Text(
                  'Change: \$${changeAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Notes
        Row(
          children: [
            Icon(
              Icons.note,
              size: 20,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              'Notes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          decoration: InputDecoration(
            labelText: 'Add notes...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.teal, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          maxLines: 2,
          onChanged: (value) {
            ref.read(currentCartProvider.notifier).addNotes(value);
          },
        ),
        
        const SizedBox(height: 20),
        
        // Action Buttons
        Row(
          children: [
            // Hold Cart Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showHoldCartDialog(),
                icon: const Icon(Icons.pause_circle_outline),
                label: const Text('Hold'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Complete Transaction Button
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _canCompleteTransaction() ? _completeTransaction : null,
                icon: const Icon(Icons.payment),
                label: const Text('Complete Sale'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _canCompleteTransaction() {
    final cartItems = ref.read(cartItemsProvider);
    final amountPaid = double.tryParse(_amountPaidController.text) ?? 0.0;
    final cartTotal = ref.read(cartTotalProvider);
    
    return cartItems.isNotEmpty && amountPaid >= cartTotal;
  }

  void _showHoldCartDialog() {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hold Cart'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter a reason for holding this cart:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                ref.read(currentCartProvider.notifier).holdCart(reasonController.text);
                Navigator.of(context).pop();
                
                // Clear form
                _clearForm();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cart held successfully'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: const Text('Hold'),
          ),
        ],
      ),
    );
  }

  void _completeTransaction() async {
    final amountPaid = double.tryParse(_amountPaidController.text) ?? 0.0;
    
    try {
      final transaction = await ref.read(currentCartProvider.notifier).completeTransaction({
        'paymentMethod': _selectedPaymentMethod,
        'amountPaid': amountPaid,
        'cashierId': 'current_user_id', // TODO: Get from auth
        'cashierName': 'Current User', // TODO: Get from auth
      });

      if (transaction != null) {
        // Clear form
        _clearForm();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction completed! Receipt: ${transaction.receiptNumber}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Show receipt dialog
        _showReceiptDialog(context, transaction);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error completing transaction: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearForm() {
    _amountPaidController.clear();
    _customerNameController.clear();
    _customerPhoneController.clear();
    _notesController.clear();
    setState(() {
      _selectedPaymentMethod = 'cash';
    });
  }

  void _showReceiptDialog(BuildContext context, dynamic transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.receipt, color: Colors.teal),
            const SizedBox(width: 8),
            const Text('Transaction Receipt'),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Receipt Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'Cat Hotel POS',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Receipt #${transaction.receiptNumber}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Date: ${DateTime.now().toString().substring(0, 19)}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Transaction Details
              Text(
                'Transaction Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              
              // TODO: Add actual transaction items here
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Transaction items will be displayed here'),
              ),
              
              const SizedBox(height: 16),
              
              // Payment Information
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Payment Method:'),
                  Text(
                    _selectedPaymentMethod.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Amount Paid:'),
                  Text(
                    '\$${_amountPaidController.text}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              // TODO: Send via WhatsApp
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('WhatsApp receipt sent!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.message, color: Colors.green),
            label: const Text('Send WhatsApp'),
          ),
          TextButton.icon(
            onPressed: () {
              // TODO: Send via Email
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Email receipt sent!'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            icon: const Icon(Icons.email, color: Colors.blue),
            label: const Text('Send Email'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Print receipt
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Receipt printed!'),
                  backgroundColor: Colors.teal,
                ),
              );
            },
            icon: const Icon(Icons.print),
            label: const Text('Print'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
