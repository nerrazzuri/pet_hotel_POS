import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/booking.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/payment.dart';
import 'package:cat_hotel_pos/features/booking/domain/services/booking_payment_service.dart';
import 'package:cat_hotel_pos/features/booking/presentation/providers/booking_providers.dart';

class BookingPaymentDialog extends ConsumerStatefulWidget {
  final Booking booking;
  
  const BookingPaymentDialog({super.key, required this.booking});

  @override
  ConsumerState<BookingPaymentDialog> createState() => _BookingPaymentDialogState();
}

class _BookingPaymentDialogState extends ConsumerState<BookingPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  PaymentType _selectedPaymentType = PaymentType.full;
  bool _isLoading = false;
  BookingPaymentSummary? _paymentSummary;

  @override
  void initState() {
    super.initState();
    _loadPaymentSummary();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentSummary() async {
    try {
      final paymentService = BookingPaymentService(
        bookingDao: ref.read(bookingDaoProvider),
        paymentDao: ref.read(paymentDaoProvider),
        transactionDao: ref.read(transactionDaoProvider),
      );
      
      final summary = await paymentService.getBookingPaymentSummary(widget.booking.id);
      setState(() {
        _paymentSummary = summary;
      });
      
      // Set default amount based on payment type
      _updateAmountForPaymentType();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading payment summary: $e')),
      );
    }
  }

  void _updateAmountForPaymentType() {
    if (_paymentSummary == null) return;
    
    switch (_selectedPaymentType) {
      case PaymentType.full:
        _amountController.text = _paymentSummary!.remainingBalance.toStringAsFixed(2);
        break;
      case PaymentType.deposit:
        _amountController.text = _paymentSummary!.depositAmount.toStringAsFixed(2);
        break;
      case PaymentType.balance:
        _amountController.text = _paymentSummary!.remainingBalance.toStringAsFixed(2);
        break;
      case PaymentType.refund:
        _amountController.text = _paymentSummary!.totalPaid.toStringAsFixed(2);
        break;
    }
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final paymentService = BookingPaymentService(
        bookingDao: ref.read(bookingDaoProvider),
        paymentDao: ref.read(paymentDaoProvider),
        transactionDao: ref.read(transactionDaoProvider),
      );

      final amount = double.parse(_amountController.text);
      final notes = _notesController.text.trim();

      Payment payment;
      
      switch (_selectedPaymentType) {
        case PaymentType.full:
          payment = await paymentService.processBookingPayment(
            bookingId: widget.booking.id,
            amount: amount,
            paymentMethod: _selectedPaymentMethod,
            customerName: widget.booking.customerName,
            notes: notes,
            processedBy: 'Staff', // TODO: Get from user session
          );
          break;
          
        case PaymentType.deposit:
          payment = await paymentService.processBookingDeposit(
            bookingId: widget.booking.id,
            depositAmount: amount,
            paymentMethod: _selectedPaymentMethod,
            customerName: widget.booking.customerName,
            notes: notes,
            processedBy: 'Staff',
          );
          break;
          
        case PaymentType.balance:
          payment = await paymentService.processRemainingBalance(
            bookingId: widget.booking.id,
            paymentMethod: _selectedPaymentMethod,
            customerName: widget.booking.customerName,
            notes: notes,
            processedBy: 'Staff',
          );
          break;
          
        case PaymentType.refund:
          payment = await paymentService.processBookingRefund(
            bookingId: widget.booking.id,
            refundAmount: amount,
            reason: notes,
            customerName: widget.booking.customerName,
            processedBy: 'Staff',
          );
          break;
      }

      if (mounted) {
        Navigator.of(context).pop(payment);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment processed successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing payment: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.payment,
                    color: Colors.green[800],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Process Payment - ${widget.booking.bookingNumber}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Process payment for booking',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: Colors.grey[600],
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Payment Summary
            if (_paymentSummary != null) ...[
              _buildPaymentSummary(),
              const SizedBox(height: 24),
            ],
            
            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Payment Type
                      DropdownButtonFormField<PaymentType>(
                        value: _selectedPaymentType,
                        decoration: InputDecoration(
                          labelText: 'Payment Type *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.category),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: PaymentType.values.map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(_getPaymentTypeDisplayName(type)),
                        )).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedPaymentType = value;
                            });
                            _updateAmountForPaymentType();
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Payment Method
                      DropdownButtonFormField<PaymentMethod>(
                        value: _selectedPaymentMethod,
                        decoration: InputDecoration(
                          labelText: 'Payment Method *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.payment),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: PaymentMethod.values.map((method) => DropdownMenuItem(
                          value: method,
                          child: Text(method.name.toUpperCase()),
                        )).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedPaymentMethod = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Amount
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'Amount (MYR) *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.attach_money),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Amount is required';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Amount must be a positive number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: 'Notes',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.note),
                          filled: true,
                          fillColor: Colors.grey[50],
                          hintText: _selectedPaymentType == PaymentType.refund 
                              ? 'Refund reason...'
                              : 'Payment notes...',
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(_getPaymentButtonText()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Payment Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem('Total Amount', 'MYR ${_paymentSummary!.totalAmount.toStringAsFixed(2)}'),
              ),
              Expanded(
                child: _buildSummaryItem('Total Paid', 'MYR ${_paymentSummary!.totalPaid.toStringAsFixed(2)}'),
              ),
              Expanded(
                child: _buildSummaryItem('Remaining', 'MYR ${_paymentSummary!.remainingBalance.toStringAsFixed(2)}'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getPaymentStatusColor(_paymentSummary!.paymentStatus).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getPaymentStatusColor(_paymentSummary!.paymentStatus),
                width: 1,
              ),
            ),
            child: Text(
              _paymentSummary!.paymentStatus.name.toUpperCase(),
              style: TextStyle(
                color: _getPaymentStatusColor(_paymentSummary!.paymentStatus),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getPaymentTypeDisplayName(PaymentType type) {
    switch (type) {
      case PaymentType.full:
        return 'Full Payment';
      case PaymentType.deposit:
        return 'Deposit Payment';
      case PaymentType.balance:
        return 'Remaining Balance';
      case PaymentType.refund:
        return 'Refund';
    }
  }

  String _getPaymentButtonText() {
    switch (_selectedPaymentType) {
      case PaymentType.full:
        return 'Process Full Payment';
      case PaymentType.deposit:
        return 'Process Deposit';
      case PaymentType.balance:
        return 'Process Balance';
      case PaymentType.refund:
        return 'Process Refund';
    }
  }

  Color _getPaymentStatusColor(BookingPaymentStatus status) {
    switch (status) {
      case BookingPaymentStatus.pending:
        return Colors.orange;
      case BookingPaymentStatus.depositPaid:
        return Colors.blue;
      case BookingPaymentStatus.partiallyPaid:
        return Colors.yellow[700]!;
      case BookingPaymentStatus.paid:
        return Colors.green;
      case BookingPaymentStatus.refunded:
        return Colors.red;
      case BookingPaymentStatus.cancelled:
        return Colors.grey;
    }
  }
}
