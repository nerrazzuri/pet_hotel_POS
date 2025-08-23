import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/deposit.dart';
import 'package:cat_hotel_pos/features/pos/domain/services/deposit_service.dart';
import 'package:cat_hotel_pos/features/pos/presentation/providers/pos_providers.dart';

class DepositManagementWidget extends ConsumerStatefulWidget {
  const DepositManagementWidget({super.key});

  @override
  ConsumerState<DepositManagementWidget> createState() => _DepositManagementWidgetState();
}

class _DepositManagementWidgetState extends ConsumerState<DepositManagementWidget> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  
  DepositType _selectedDepositType = DepositType.advance;
  String _selectedPaymentMethod = 'cash';
  bool _isCreatingDeposit = false;
  bool _showDepositForm = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(currentCartProvider);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Colors.purple, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Deposits & Pre-Authorizations',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(_showDepositForm ? Icons.close : Icons.add),
                  onPressed: () {
                    setState(() {
                      _showDepositForm = !_showDepositForm;
                      if (!_showDepositForm) {
                        _clearForm();
                      }
                    });
                  },
                  tooltip: _showDepositForm ? 'Close Form' : 'Create Deposit',
                ),
              ],
            ),

            if (_showDepositForm) ...[
              const SizedBox(height: 16),
              _buildDepositForm(),
            ],

            const SizedBox(height: 16),

            // Available Deposits
            if (cart?.customerId != null) ...[
              _buildAvailableDeposits(),
              const SizedBox(height: 16),
            ],

            // Applied Deposits
            if (cart?.appliedDeposits != null && cart!.appliedDeposits!.isNotEmpty) ...[
              _buildAppliedDeposits(cart.appliedDeposits!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDepositForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create New Deposit',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade700,
            ),
          ),
          const SizedBox(height: 16),

          // Deposit Type
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<DepositType>(
                  value: _selectedDepositType,
                  decoration: InputDecoration(
                    labelText: 'Deposit Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: DepositType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_formatDepositType(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedDepositType = value;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
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
            ],
          ),

          const SizedBox(height: 16),

          // Amount and Description
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount (RM)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixText: 'RM ',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'e.g., Security deposit for room',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Reference (optional)
          TextField(
            controller: _referenceController,
            decoration: InputDecoration(
              labelText: 'Reference (Optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              hintText: 'e.g., Card auth code, bank reference',
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isCreatingDeposit ? null : _createDeposit,
                  icon: _isCreatingDeposit 
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.save),
                  label: Text(_isCreatingDeposit ? 'Creating...' : 'Create Deposit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
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

  Widget _buildAvailableDeposits() {
    final cart = ref.read(currentCartProvider);
    if (cart?.customerId == null) return const SizedBox.shrink();

    // For demo purposes, create sample deposits
    final sampleDeposits = _createSampleDeposits(cart!.customerId!);
    final availableDeposits = DepositService.getAvailableDeposits(sampleDeposits);

    if (availableDeposits.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              'No available deposits for this customer',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Available Deposits',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              const Spacer(),
              Text(
                'Total: RM${DepositService.calculateTotalAvailableDeposits(availableDeposits).toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...availableDeposits.map((deposit) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_formatDepositType(deposit.type)} - RM${deposit.amount.toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      if (deposit.description != null)
                        Text(
                          deposit.description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showApplyDepositDialog(deposit),
                  child: Text('Apply'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildAppliedDeposits(List<Deposit> appliedDeposits) {
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
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Applied Deposits',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...appliedDeposits.map((deposit) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${_formatDepositType(deposit.type)} - RM${deposit.amount.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.remove_circle, color: Colors.red, size: 20),
                  onPressed: () => _removeDeposit(deposit),
                  tooltip: 'Remove deposit',
                ),
              ],
            ),
          )).toList(),

          const SizedBox(height: 8),
          Text(
            'Total Applied: RM${appliedDeposits.fold(0.0, (sum, deposit) => sum + deposit.amount).toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createDeposit() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount');
      return;
    }

    final cart = ref.read(currentCartProvider);
    if (cart?.customerId == null || cart?.customerName == null || cart?.customerPhone == null) {
      _showError('Customer information is required');
      return;
    }

    setState(() {
      _isCreatingDeposit = true;
    });

    try {
      // Validate deposit
      final validation = DepositService.validateDeposit(
        _selectedDepositType,
        amount,
        _selectedPaymentMethod,
        cart!.customerId!,
        cart.customerName!,
        cart.customerPhone!,
      );

      if (!validation.isValid) {
        _showError(validation.errorMessage ?? 'Invalid deposit');
        return;
      }

      // Create deposit
      // final deposit = DepositService.createDeposit(
      //   customerId: cart.customerId!,
      //   customerName: cart.customerName!,
      //   customerPhone: cart.customerPhone!,
      //   type: _selectedDepositType,
      //   amount: amount,
      //   paymentMethod: _selectedPaymentMethod,
      //   processedBy: cart.cashierId ?? 'system',
      //   description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      //   reference: _referenceController.text.isNotEmpty ? _referenceController.text : null,
      // );

                        // Confirm deposit (in real implementation, this would wait for payment confirmation)
                  // final confirmedDeposit = DepositService.confirmDeposit(deposit);

                  // Store deposit (in real implementation, this would save to database)
                  // For now, just show success message

      // Clear form and show success
      _clearForm();
      setState(() {
        _showDepositForm = false;
      });

      _showSuccess('Deposit created successfully!');
    } catch (e) {
      _showError('Error creating deposit: $e');
    } finally {
      setState(() {
        _isCreatingDeposit = false;
      });
    }
  }

  void _showApplyDepositDialog(Deposit deposit) {
    final amountController = TextEditingController(
      text: deposit.amount.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Apply Deposit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('How much would you like to apply from this deposit?'),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Amount to Apply (RM)',
                border: OutlineInputBorder(),
                prefixText: 'RM ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            Text(
              'Available: RM${deposit.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
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
              final amountToApply = double.tryParse(amountController.text);
              if (amountToApply != null && amountToApply > 0) {
                _applyDeposit(deposit, amountToApply);
                Navigator.pop(context);
              }
            },
            child: Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _applyDeposit(Deposit deposit, double amountToApply) {
    final cart = ref.read(currentCartProvider);
    if (cart == null) return;

    final result = DepositService.applyDepositToCart(
      deposit,
      cart,
      amountToApply,
    );

    if (result.success) {
      ref.read(currentCartProvider.notifier).addDeposit(result);
      _showSuccess('Deposit applied successfully!');
    } else {
      _showError(result.errorMessage ?? 'Failed to apply deposit');
    }
  }

  void _removeDeposit(Deposit deposit) {
    ref.read(currentCartProvider.notifier).removeDeposit(deposit);
    _showSuccess('Deposit removed from cart');
  }

  void _clearForm() {
    _amountController.clear();
    _descriptionController.clear();
    _referenceController.clear();
    setState(() {
      _selectedDepositType = DepositType.advance;
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

  String _formatDepositType(DepositType type) {
    switch (type) {
      case DepositType.advance:
        return 'Advance Payment';
      case DepositType.security:
        return 'Security Deposit';
      case DepositType.preAuth:
        return 'Pre-Authorization';
      case DepositType.giftCard:
        return 'Gift Card';
      case DepositType.storeCredit:
        return 'Store Credit';
    }
  }

  List<Deposit> _createSampleDeposits(String customerId) {
    // Create sample deposits for demo
    return [
      Deposit(
        id: '1',
        customerId: customerId,
        customerName: 'John Doe',
        customerPhone: '+60123456789',
        type: DepositType.advance,
        status: DepositStatus.confirmed,
        amount: 100.0,
        paymentMethod: 'cash',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        description: 'Advance payment for grooming services',
        processedBy: 'cashier1',
      ),
      Deposit(
        id: '2',
        customerId: customerId,
        customerName: 'John Doe',
        customerPhone: '+60123456789',
        type: DepositType.security,
        status: DepositStatus.confirmed,
        amount: 200.0,
        paymentMethod: 'card',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        description: 'Security deposit for deluxe room',
        processedBy: 'cashier1',
      ),
      Deposit(
        id: '3',
        customerId: customerId,
        customerName: 'John Doe',
        customerPhone: '+60123456789',
        type: DepositType.giftCard,
        status: DepositStatus.confirmed,
        amount: 75.0,
        paymentMethod: 'cash',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        description: 'Gift card purchase',
        processedBy: 'cashier2',
      ),
    ];
  }
}
