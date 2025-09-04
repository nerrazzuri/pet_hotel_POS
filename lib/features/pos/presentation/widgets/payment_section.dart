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
  String _selectedCardType = 'visa';
  String _selectedEWallet = 'tng';
  final TextEditingController _amountPaidController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountPaidController.addListener(_updateChangeAmount);
  }

  @override
  void dispose() {
    _amountPaidController.dispose();
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
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Scrollable Content Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        
                        // Payment Method
                        if (cartItems.isNotEmpty) ...[
                          _buildPaymentMethodSection(constraints),
                          const SizedBox(height: 20),
                        ],
                        
                        // Amount Paid
                        if (cartItems.isNotEmpty) ...[
                          _buildAmountPaidSection(changeAmount),
                          const SizedBox(height: 20),
                        ],
                        
                                                 // Notes Section removed
                         if (cartItems.isEmpty) ...[
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
                                      fontSize: 14,
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
                  );
                },
              ),
            ),
          ),
          
          // Fixed Action Buttons at Bottom
          if (cartItems.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: _buildActionButtons(),
            ),
          ],
        ],
      ),
    );
  }



  Widget _buildPaymentMethodSection(BoxConstraints constraints) {
    final isCompact = constraints.maxWidth < 400;
    
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
            Flexible(
              child:             Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Payment Method Buttons - Responsive layout
        if (isCompact) ...[
          // Compact layout for narrow screens - 2x2 grid
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildPaymentMethodButton(
                      'cash',
                      'Cash',
                      Icons.money,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPaymentMethodButton(
                      'card',
                      'Card',
                      Icons.credit_card,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildPaymentMethodButton(
                      'e_wallet',
                      'E-Wallet',
                      Icons.account_balance_wallet,
                      Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPaymentMethodButton(
                      'bank_transfer',
                      'Bank Transfer',
                      Icons.account_balance,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ] else ...[
          // Regular layout for wider screens - single row
          Row(
            children: [
              Expanded(
                child: _buildPaymentMethodButton(
                  'cash',
                  'Cash',
                  Icons.money,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPaymentMethodButton(
                  'card',
                  'Card',
                  Icons.credit_card,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPaymentMethodButton(
                  'e_wallet',
                  'E-Wallet',
                  Icons.account_balance_wallet,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPaymentMethodButton(
                  'bank_transfer',
                  'Bank Transfer',
                  Icons.account_balance,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
        
        const SizedBox(height: 16),
        
        // Payment Method Specific Options
        if (_selectedPaymentMethod == 'card') _buildCardOptions(constraints),
        if (_selectedPaymentMethod == 'e_wallet') _buildEWalletOptions(constraints),
        if (_selectedPaymentMethod == 'bank_transfer') _buildBankTransferOptions(constraints),
      ],
    );
  }

  Widget _buildPaymentMethodButton(String value, String label, IconData icon, Color color) {
    final isSelected = _selectedPaymentMethod == value;
    
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedPaymentMethod = value;
            
            // Auto-fill amount for non-cash payments
            if (value != 'cash') {
              final cartTotal = ref.read(cartTotalProvider);
              _amountPaidController.text = cartTotal.toStringAsFixed(2);
            }
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? color : Colors.grey[100],
          foregroundColor: isSelected ? Colors.white : Colors.grey[700],
          elevation: isSelected ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardOptions(BoxConstraints constraints) {
    final isCompact = constraints.maxWidth < 400;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Card Type:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        if (isCompact) ...[
          // Compact layout - 2x2 grid
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildCardTypeButton('visa', 'Visa', Colors.blue[800]!)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildCardTypeButton('mastercard', 'Mastercard', Colors.red[600]!)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildCardTypeButton('amex', 'Amex', Colors.blue[600]!)),
                ],
              ),
            ],
          ),
        ] else ...[
          // Regular layout - single row
          Row(
            children: [
              Expanded(child: _buildCardTypeButton('visa', 'Visa', Colors.blue[800]!)),
              const SizedBox(width: 8),
              Expanded(child: _buildCardTypeButton('mastercard', 'Mastercard', Colors.red[600]!)),
              const SizedBox(width: 8),
              Expanded(child: _buildCardTypeButton('amex', 'Amex', Colors.blue[600]!)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCardTypeButton(String type, String label, Color color) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedCardType = type;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedCardType == type ? color : Colors.grey[100],
          foregroundColor: _selectedCardType == type ? Colors.white : Colors.grey[700],
          elevation: _selectedCardType == type ? 3 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildEWalletOptions(BoxConstraints constraints) {
    final isCompact = constraints.maxWidth < 400;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select E-Wallet:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        if (isCompact) ...[
          // Compact layout - 2x2 grid
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildEWalletButton('tng', 'Touch n Go', Colors.orange)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildEWalletButton('grabpay', 'GrabPay', Colors.green)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildEWalletButton('mae', 'MAE', Colors.blue)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildEWalletButton('boost', 'Boost', Colors.purple)),
                ],
              ),
            ],
          ),
        ] else ...[
          // Regular layout - single row
          Row(
            children: [
              Expanded(child: _buildEWalletButton('tng', 'Touch n Go', Colors.orange)),
              const SizedBox(width: 8),
              Expanded(child: _buildEWalletButton('grabpay', 'GrabPay', Colors.green)),
              const SizedBox(width: 8),
              Expanded(child: _buildEWalletButton('mae', 'MAE', Colors.blue)),
              const SizedBox(width: 8),
              Expanded(child: _buildEWalletButton('boost', 'Boost', Colors.purple)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildEWalletButton(String type, String label, Color color) {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedEWallet = type;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedEWallet == type ? color : Colors.grey[100],
          foregroundColor: _selectedEWallet == type ? Colors.white : Colors.grey[700],
          elevation: _selectedEWallet == type ? 3 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: _buildEWalletLogo(type, label),
      ),
    );
  }

  Widget _buildEWalletLogo(String type, String label) {
    // Standardized logo container for consistent sizing
    Widget _buildLogoContainer(String imagePath, String fallbackEmoji) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.white.withOpacity(0.1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.asset(
            imagePath,
            width: 20,
            height: 20,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to emoji if image not found
              return Center(
                child: Text(
                  fallbackEmoji,
                  style: const TextStyle(fontSize: 16),
                ),
              );
            },
          ),
        ),
      );
    }

    switch (type) {
      case 'tng':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogoContainer('assets/images/ewallet/tng.png', '📱'),
            const SizedBox(width: 6),
            Text(
              'TNG',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
        );
      case 'grabpay':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogoContainer('assets/images/ewallet/grabpay.png', '🚗'),
            const SizedBox(width: 6),
            Text(
              'Grab',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
        );
      case 'mae':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogoContainer('assets/images/ewallet/mae.png', '🏦'),
            const SizedBox(width: 6),
            Text(
              'MAE',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
        );
      case 'boost':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogoContainer('assets/images/ewallet/boost.svg', '⚡'),
            const SizedBox(width: 6),
            Text(
              'Boost',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
        );
      default:
        return Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        );
    }
  }

  Widget _buildBankTransferOptions(BoxConstraints constraints) {
    final isCompact = constraints.maxWidth < 400;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bank Transfer Details:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        if (isCompact) ...[
          // Compact layout - stacked vertically
          Column(
            children: [
              _buildBankInfoRow('Receiver Name:', 'Cat Hotel Pet Services'),
              const SizedBox(height: 8),
              _buildBankInfoRow('Bank Name:', 'Maybank Berhad'),
              const SizedBox(height: 8),
              _buildBankInfoRow('Account Number:', '1234-5678-9012-3456'),
            ],
          ),
        ] else ...[
          // Regular layout - single row
          Row(
            children: [
              Expanded(child: _buildBankInfoRow('Receiver Name:', 'Cat Hotel Pet Services')),
              const SizedBox(width: 8),
              Expanded(child: _buildBankInfoRow('Bank Name:', 'Maybank Berhad')),
              const SizedBox(width: 8),
              Expanded(child: _buildBankInfoRow('Account Number:', '1234-5678-9012-3456')),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBankInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[800],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Amount Display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[50],
          ),
          child: Column(
            children: [
              Text(
                '\$${_amountPaidController.text.isEmpty ? '0.00' : _amountPaidController.text}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Click numbers to enter amount',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Calculator Keypad - only show for cash payments
        if (_selectedPaymentMethod == 'cash') _buildCalculatorKeypad(),
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
                    fontSize: 12,
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
    return Row(
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
                        fontSize: 14,
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
                  fontSize: 14,
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

  Widget _buildCalculatorKeypad() {
    return Column(
      children: [
        // Row 1: 1, 2, 3
        Row(
          children: [
            Expanded(child: _buildCalculatorButton('1')),
            const SizedBox(width: 8),
            Expanded(child: _buildCalculatorButton('2')),
            const SizedBox(width: 8),
            Expanded(child: _buildCalculatorButton('3')),
          ],
        ),
        const SizedBox(height: 8),
        // Row 2: 4, 5, 6
        Row(
          children: [
            Expanded(child: _buildCalculatorButton('4')),
            const SizedBox(width: 8),
            Expanded(child: _buildCalculatorButton('5')),
            const SizedBox(width: 8),
            Expanded(child: _buildCalculatorButton('6')),
          ],
        ),
        const SizedBox(height: 8),
        // Row 3: 7, 8, 9
        Row(
          children: [
            Expanded(child: _buildCalculatorButton('7')),
            const SizedBox(width: 8),
            Expanded(child: _buildCalculatorButton('8')),
            const SizedBox(width: 8),
            Expanded(child: _buildCalculatorButton('9')),
          ],
        ),
        const SizedBox(height: 8),
        // Row 4: 0, Exact, Clear
        Row(
          children: [
            Expanded(child: _buildCalculatorButton('0')),
            const SizedBox(width: 8),
            Expanded(child: _buildCalculatorButton('=')),
            const SizedBox(width: 8),
            Expanded(child: _buildCalculatorButton('C')),
          ],
        ),
      ],
    );
  }

  Widget _buildCalculatorButton(String text) {
    bool isClearButton = text == 'C';
    bool isExactButton = text == '=';
    
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: () => _onCalculatorButtonPressed(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: isClearButton 
              ? Colors.red[100] 
              : isExactButton 
                  ? Colors.teal[100] 
                  : Colors.grey[100],
          foregroundColor: isClearButton 
              ? Colors.red[700] 
              : isExactButton 
                  ? Colors.teal[700] 
                  : Colors.grey[700],
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          isExactButton ? 'Exact' : text,
          style: TextStyle(
            fontSize: isExactButton ? 12 : 18,
            fontWeight: FontWeight.bold,
            color: isClearButton 
                ? Colors.red[700] 
                : isExactButton 
                    ? Colors.teal[700] 
                    : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  void _onCalculatorButtonPressed(String button) {
    if (button == 'C') {
      // Clear the amount
      _amountPaidController.clear();
    } else if (button == '=') {
      // Set exact amount (cart total)
      final cartTotal = ref.read(cartTotalProvider);
      _amountPaidController.text = cartTotal.toStringAsFixed(2);
    } else {
      // Add digit to amount with shifting logic
      String currentAmount = _amountPaidController.text;
      
      if (currentAmount.isEmpty) {
        // First digit - start with 0.0
        _amountPaidController.text = '0.0$button';
      } else {
        // Remove the $ prefix if present and parse
        String cleanAmount = currentAmount.replaceAll('\$', '');
        
        if (cleanAmount.contains('.')) {
          // Already has decimal, implement shifting logic
          List<String> parts = cleanAmount.split('.');
          String wholePart = parts[0];
          String decimalPart = parts[1];
          
          // Shift logic: move decimal part left and add new digit
          if (decimalPart.length >= 2) {
            // If we already have 2 decimal places, shift everything left
            String newWholePart = wholePart + decimalPart[0];
            String newDecimalPart = decimalPart[1] + button;
            
            // Remove leading zeros from whole part
            newWholePart = newWholePart.replaceFirst(RegExp(r'^0+'), '');
            if (newWholePart.isEmpty) newWholePart = '0';
            
            _amountPaidController.text = '$newWholePart.$newDecimalPart';
          } else {
            // Add to decimal part
            _amountPaidController.text = '$wholePart.${decimalPart}${button}';
          }
        } else {
          // No decimal yet, add one and append
          _amountPaidController.text = '$cleanAmount.0$button';
        }
      }
    }
    
    setState(() {});
  }
}





