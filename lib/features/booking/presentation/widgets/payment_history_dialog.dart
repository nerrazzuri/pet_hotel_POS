import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/booking.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/payment.dart';
import 'package:cat_hotel_pos/features/booking/domain/services/booking_payment_service.dart';
import 'package:cat_hotel_pos/features/booking/presentation/providers/booking_providers.dart';

class PaymentHistoryDialog extends ConsumerStatefulWidget {
  final Booking booking;
  
  const PaymentHistoryDialog({super.key, required this.booking});

  @override
  ConsumerState<PaymentHistoryDialog> createState() => _PaymentHistoryDialogState();
}

class _PaymentHistoryDialogState extends ConsumerState<PaymentHistoryDialog> {
  bool _isLoading = true;
  List<Payment> _payments = [];
  BookingPaymentSummary? _paymentSummary;

  @override
  void initState() {
    super.initState();
    _loadPaymentHistory();
  }

  Future<void> _loadPaymentHistory() async {
    try {
      final paymentService = BookingPaymentService(
        bookingDao: ref.read(bookingDaoProvider),
        paymentDao: ref.read(paymentDaoProvider),
        transactionDao: ref.read(transactionDaoProvider),
      );
      
      final payments = await paymentService.getBookingPaymentHistory(widget.booking.id);
      final summary = await paymentService.getBookingPaymentSummary(widget.booking.id);
      
      setState(() {
        _payments = payments;
        _paymentSummary = summary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading payment history: $e')),
      );
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
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
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
                    color: Colors.purple[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.history,
                    color: Colors.purple[800],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment History - ${widget.booking.bookingNumber}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'View all payment transactions for this booking',
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
            
            // Payment History
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _payments.isEmpty
                      ? _buildEmptyState()
                      : _buildPaymentList(),
            ),
            
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Close'),
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
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assessment, color: Colors.purple[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Payment Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Amount',
                  'MYR ${_paymentSummary!.totalAmount.toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Total Paid',
                  'MYR ${_paymentSummary!.totalPaid.toStringAsFixed(2)}',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Remaining',
                  'MYR ${_paymentSummary!.remainingBalance.toStringAsFixed(2)}',
                  Icons.pending,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getPaymentStatusColor(_paymentSummary!.paymentStatus).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
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

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payment_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Payment History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No payments have been processed for this booking yet',
            style: TextStyle(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.list, color: Colors.purple[700], size: 20),
            const SizedBox(width: 8),
            Text(
              'Payment Transactions (${_payments.length})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.purple[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: _payments.length,
            itemBuilder: (context, index) {
              final payment = _payments[index];
              return _PaymentCard(payment: payment);
            },
          ),
        ),
      ],
    );
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

class _PaymentCard extends StatelessWidget {
  final Payment payment;

  const _PaymentCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final isRefund = payment.amount < 0;
    final amount = payment.amount.abs();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isRefund ? Colors.red : Colors.green,
            width: 1,
          ),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isRefund ? Colors.red[100] : Colors.green[100],
            child: Icon(
              isRefund ? Icons.receipt_long : Icons.payment,
              color: isRefund ? Colors.red[800] : Colors.green[800],
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  '${isRefund ? 'Refund' : 'Payment'} - ${payment.paymentType?.name.toUpperCase() ?? 'FULL'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPaymentMethodColor(payment.paymentMethod).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  payment.paymentMethod.name.toUpperCase(),
                  style: TextStyle(
                    color: _getPaymentMethodColor(payment.paymentMethod),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Amount: ${isRefund ? '-' : '+'}MYR ${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isRefund ? Colors.red[700] : Colors.green[700],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Date: ${_formatDateTime(payment.processedAt)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              if (payment.notes?.isNotEmpty == true) ...[
                const SizedBox(height: 4),
                Text(
                  'Notes: ${payment.notes}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
          trailing: Icon(
            isRefund ? Icons.arrow_upward : Icons.arrow_downward,
            color: isRefund ? Colors.red : Colors.green,
          ),
        ),
      ),
    );
  }

  Color _getPaymentMethodColor(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Colors.green;
      case PaymentMethod.card:
        return Colors.blue;
      case PaymentMethod.bankTransfer:
        return Colors.purple;
      case PaymentMethod.eWallet:
        return Colors.orange;
      case PaymentMethod.refund:
        return Colors.red;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
