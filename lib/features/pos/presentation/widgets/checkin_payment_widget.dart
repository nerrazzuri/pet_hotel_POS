import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/payments/domain/entities/payment_method.dart';
import 'package:cat_hotel_pos/features/payments/domain/entities/payment_transaction.dart';
import 'package:cat_hotel_pos/features/payments/domain/services/payment_service.dart';
import 'package:cat_hotel_pos/features/pos/domain/services/checkin_payment_service.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/booking.dart';

class CheckInPaymentWidget extends ConsumerStatefulWidget {
  final Booking? booking;
  final String customerId;
  final String customerName;
  final String checkInId;
  final List<String> selectedServices;
  final Map<String, double>? servicePrices;
  final Function(PaymentTransaction) onPaymentCompleted;
  final VoidCallback? onSkip;
  final bool allowSkip;

  const CheckInPaymentWidget({
    super.key,
    this.booking,
    required this.customerId,
    required this.customerName,
    required this.checkInId,
    this.selectedServices = const [],
    this.servicePrices,
    required this.onPaymentCompleted,
    this.onSkip,
    this.allowSkip = false,
  });

  @override
  ConsumerState<CheckInPaymentWidget> createState() => _CheckInPaymentWidgetState();
}

class _CheckInPaymentWidgetState extends ConsumerState<CheckInPaymentWidget> {
  late CheckInPaymentService _paymentService;
  
  List<PaymentMethod> _availablePaymentMethods = [];
  PaymentMethod? _selectedPaymentMethod;
  CheckInPaymentSummary? _paymentSummary;
  bool _isLoading = true;
  bool _isProcessing = false;
  
  CheckInPaymentType _selectedPaymentType = CheckInPaymentType.fullPayment;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _cashReceivedController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _paymentService = CheckInPaymentService(
      paymentService: ref.read(paymentServiceProvider),
    );
    _loadPaymentData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _cashReceivedController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentData() async {
    try {
      final paymentMethods = await _paymentService.getAvailablePaymentMethods();
      final summary = await _paymentService.calculateCheckInPayments(
        booking: widget.booking,
        selectedServices: widget.selectedServices,
        servicePrices: widget.servicePrices,
      );

      setState(() {
        _availablePaymentMethods = paymentMethods;
        _selectedPaymentMethod = paymentMethods.isNotEmpty ? paymentMethods.first : null;
        _paymentSummary = summary;
        _isLoading = false;
        
        // Set default amount to remaining amount
        if (summary.requiresPayment) {
          _amountController.text = summary.remainingAmount.toStringAsFixed(2);
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading payment data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_paymentSummary == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text('Error loading payment information'),
              const SizedBox(height: 16),
              if (widget.allowSkip)
                TextButton(
                  onPressed: widget.onSkip,
                  child: const Text('Skip Payment'),
                ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment Summary
            _buildPaymentSummary(),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            
            // Payment Options
            if (_paymentSummary!.requiresPayment) ...[
              _buildPaymentOptions(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ] else ...[
              _buildNoPaymentRequired(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    final summary = _paymentSummary!;
    
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
          const Text(
            'Payment Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          if (summary.accommodationAmount > 0) ...[
            _buildSummaryRow('Accommodation', summary.accommodationAmount),
            const SizedBox(height: 4),
          ],
          
          if (summary.servicesAmount > 0) ...[
            _buildSummaryRow('Additional Services', summary.servicesAmount),
            const SizedBox(height: 4),
          ],
          
          const Divider(),
          _buildSummaryRow('Total Amount', summary.totalAmount, isTotal: true),
          
          if (summary.paidAmount > 0) ...[
            const SizedBox(height: 4),
            _buildSummaryRow('Paid Amount', summary.paidAmount, isCredit: true),
          ],
          
          if (summary.remainingAmount > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Amount Due',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                  Text(
                    'RM ${summary.remainingAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false, bool isCredit = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          '${isCredit ? '-' : ''}RM ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
            color: isCredit ? Colors.green : null,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Details',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        // Payment Type Selection
        _buildPaymentTypeSelection(),
        const SizedBox(height: 16),
        
        // Payment Method Selection
        _buildPaymentMethodSelection(),
        const SizedBox(height: 16),
        
        // Amount Input
        _buildAmountInput(),
        const SizedBox(height: 16),
        
        // Cash Received Input (for cash payments)
        if (_selectedPaymentMethod?.type == PaymentType.cash) ...[
          _buildCashReceivedInput(),
          const SizedBox(height: 16),
        ],
        
        // Notes Input
        _buildNotesInput(),
      ],
    );
  }

  Widget _buildPaymentTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payment Type', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        DropdownButtonFormField<CheckInPaymentType>(
          value: _selectedPaymentType,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          items: [
            const DropdownMenuItem(
              value: CheckInPaymentType.fullPayment,
              child: Text('Full Payment'),
            ),
            const DropdownMenuItem(
              value: CheckInPaymentType.deposit,
              child: Text('Deposit Payment'),
            ),
            if (widget.selectedServices.isNotEmpty)
              const DropdownMenuItem(
                value: CheckInPaymentType.additional,
                child: Text('Additional Services Only'),
              ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedPaymentType = value;
                _updateAmountForPaymentType();
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSelection() {
    if (_availablePaymentMethods.isEmpty) {
      return const Text('No payment methods available');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        DropdownButtonFormField<PaymentMethod>(
          value: _selectedPaymentMethod,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          items: _availablePaymentMethods.map((method) {
            return DropdownMenuItem(
              value: method,
              child: Row(
                children: [
                  Icon(_getPaymentMethodIcon(method.type)),
                  const SizedBox(width: 8),
                  Text(method.name),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedPaymentMethod = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payment Amount', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixText: 'RM ',
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter payment amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCashReceivedInput() {
    final paymentAmount = double.tryParse(_amountController.text) ?? 0.0;
    final cashReceived = double.tryParse(_cashReceivedController.text) ?? 0.0;
    final change = cashReceived - paymentAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Cash Received', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _cashReceivedController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixText: 'RM ',
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          onChanged: (value) {
            setState(() {}); // Trigger rebuild to update change amount
          },
        ),
        if (change > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Change: RM ${change.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNotesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Notes (Optional)', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Additional payment notes...',
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildNoPaymentRequired() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.check_circle, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            'No Payment Required',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'This booking is already fully paid.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Create a mock successful transaction for tracking
              final mockTransaction = PaymentTransaction(
                id: 'mock-${DateTime.now().millisecondsSinceEpoch}',
                transactionId: 'PREPAID-${widget.checkInId}',
                type: TransactionType.sale,
                amount: 0.0,
                paymentMethod: _availablePaymentMethods.first, // Mock payment method
                status: PaymentStatus.completed,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                customerId: widget.customerId,
                customerName: widget.customerName,
                orderId: widget.checkInId,
                notes: 'Pre-paid booking - no additional payment required',
              );
              widget.onPaymentCompleted(mockTransaction);
            },
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Continue'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (widget.allowSkip)
          TextButton.icon(
            onPressed: widget.onSkip,
            icon: const Icon(Icons.skip_next),
            label: const Text('Skip Payment'),
          )
        else
          const SizedBox.shrink(),

        _isProcessing
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                onPressed: _processPayment,
                icon: const Icon(Icons.payment),
                label: const Text('Process Payment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
      ],
    );
  }

  void _updateAmountForPaymentType() {
    final summary = _paymentSummary!;
    
    switch (_selectedPaymentType) {
      case CheckInPaymentType.fullPayment:
        _amountController.text = summary.remainingAmount.toStringAsFixed(2);
        break;
      case CheckInPaymentType.deposit:
        _amountController.text = (summary.remainingAmount * 0.5).toStringAsFixed(2);
        break;
      case CheckInPaymentType.additional:
        _amountController.text = summary.servicesAmount.toStringAsFixed(2);
        break;
      case CheckInPaymentType.refund:
        _amountController.text = '0.00';
        break;
    }
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid payment amount')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final request = CheckInPaymentRequest(
        checkInId: widget.checkInId,
        bookingId: widget.booking?.id,
        customerId: widget.customerId,
        customerName: widget.customerName,
        amount: amount,
        paymentType: _selectedPaymentType,
        paymentMethod: _selectedPaymentMethod!,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      final result = await _paymentService.processCheckInPayment(request);

      if (result.success && result.transaction != null) {
        widget.onPaymentCompleted(result.transaction!);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment processed successfully! Receipt: ${result.receiptId}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment failed: ${result.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment processing error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  IconData _getPaymentMethodIcon(PaymentType type) {
    switch (type) {
      case PaymentType.cash:
        return Icons.money;
      case PaymentType.creditCard:
        return Icons.credit_card;
      case PaymentType.debitCard:
        return Icons.credit_card;
      case PaymentType.digitalWallet:
        return Icons.phone_android;
      case PaymentType.bankTransfer:
        return Icons.account_balance;
      case PaymentType.voucher:
        return Icons.card_giftcard;
      case PaymentType.deposit:
        return Icons.account_balance_wallet;
      case PaymentType.partialPayment:
        return Icons.payment;
    }
  }
}

// Placeholder providers - these should be implemented properly
final paymentServiceProvider = Provider<PaymentService>((ref) {
  throw UnimplementedError('PaymentService provider not implemented');
});