import 'package:uuid/uuid.dart';
import 'package:cat_hotel_pos/features/payments/domain/services/payment_service.dart';
import 'package:cat_hotel_pos/features/payments/domain/entities/payment_method.dart';
import 'package:cat_hotel_pos/features/payments/domain/entities/payment_transaction.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/checkin_request.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/booking.dart';

enum CheckInPaymentType {
  deposit,
  fullPayment,
  additional,
  refund,
}

class CheckInPaymentRequest {
  final String checkInId;
  final String? bookingId;
  final String customerId;
  final String customerName;
  final double amount;
  final CheckInPaymentType paymentType;
  final PaymentMethod paymentMethod;
  final String? notes;
  final Map<String, dynamic>? metadata;

  const CheckInPaymentRequest({
    required this.checkInId,
    this.bookingId,
    required this.customerId,
    required this.customerName,
    required this.amount,
    required this.paymentType,
    required this.paymentMethod,
    this.notes,
    this.metadata,
  });
}

class CheckInPaymentResult {
  final bool success;
  final PaymentTransaction? transaction;
  final String? error;
  final double? changeAmount;
  final String? receiptId;

  const CheckInPaymentResult({
    required this.success,
    this.transaction,
    this.error,
    this.changeAmount,
    this.receiptId,
  });
}

class CheckInPaymentService {
  final PaymentService _paymentService;
  final Uuid _uuid = const Uuid();

  CheckInPaymentService({
    required PaymentService paymentService,
  }) : _paymentService = paymentService;

  /// Process payment during check-in
  Future<CheckInPaymentResult> processCheckInPayment(CheckInPaymentRequest request) async {
    try {
      // Validate payment method
      if (!request.paymentMethod.isActive) {
        return CheckInPaymentResult(
          success: false,
          error: 'Selected payment method is not active',
        );
      }

      // Validate amount
      if (request.amount <= 0) {
        return CheckInPaymentResult(
          success: false,
          error: 'Payment amount must be greater than zero',
        );
      }

      // Check minimum/maximum amounts
      if (request.paymentMethod.minimumAmount != null && 
          request.amount < request.paymentMethod.minimumAmount!) {
        return CheckInPaymentResult(
          success: false,
          error: 'Amount is below minimum for ${request.paymentMethod.name}',
        );
      }

      if (request.paymentMethod.maximumAmount != null && 
          request.amount > request.paymentMethod.maximumAmount!) {
        return CheckInPaymentResult(
          success: false,
          error: 'Amount exceeds maximum for ${request.paymentMethod.name}',
        );
      }

      // Generate transaction ID
      final transactionId = 'CHK-${DateTime.now().millisecondsSinceEpoch}-${_uuid.v4().substring(0, 8)}';
      final receiptId = 'RCP-${DateTime.now().millisecondsSinceEpoch}';

      // Create payment transaction
      final transaction = await _paymentService.processPayment(
        transactionId: transactionId,
        type: _mapPaymentTypeToTransactionType(request.paymentType),
        amount: request.amount,
        paymentMethod: request.paymentMethod,
        customerId: request.customerId,
        customerName: request.customerName,
        orderId: request.checkInId,
        receiptId: receiptId,
        notes: _buildPaymentNotes(request),
        currency: 'MYR',
        processedBy: 'staff', // TODO: Get from auth context
      );

      // Complete the payment (simulate processing)
      final completedTransaction = await _paymentService.completePayment(transaction.id);

      // Calculate change for cash payments
      double? changeAmount;
      if (request.paymentMethod.type == PaymentType.cash) {
        // For cash payments, the amount might be more than required
        // This would be handled in the UI, but we'll return 0 for now
        changeAmount = 0.0;
      }

      return CheckInPaymentResult(
        success: true,
        transaction: completedTransaction,
        changeAmount: changeAmount,
        receiptId: receiptId,
      );

    } catch (e) {
      return CheckInPaymentResult(
        success: false,
        error: 'Payment processing failed: $e',
      );
    }
  }

  /// Calculate payment amounts for check-in
  Future<CheckInPaymentSummary> calculateCheckInPayments({
    required Booking? booking,
    required List<String> selectedServices,
    Map<String, double>? servicePrices,
    double? additionalAmount,
  }) async {
    double accommodationAmount = 0.0;
    double servicesAmount = 0.0;
    double totalAmount = 0.0;
    double paidAmount = 0.0;
    double remainingAmount = 0.0;

    // Calculate accommodation costs
    if (booking != null) {
      accommodationAmount = booking.totalAmount;
      paidAmount = booking.depositAmount ?? 0.0;
    }

    // Calculate services costs
    if (selectedServices.isNotEmpty && servicePrices != null) {
      for (final service in selectedServices) {
        servicesAmount += servicePrices[service] ?? 0.0;
      }
    }

    // Add any additional amounts
    if (additionalAmount != null) {
      servicesAmount += additionalAmount;
    }

    totalAmount = accommodationAmount + servicesAmount;
    remainingAmount = totalAmount - paidAmount;

    return CheckInPaymentSummary(
      accommodationAmount: accommodationAmount,
      servicesAmount: servicesAmount,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      remainingAmount: remainingAmount,
      requiresPayment: remainingAmount > 0,
    );
  }

  /// Get available payment methods for check-in
  Future<List<PaymentMethod>> getAvailablePaymentMethods() async {
    try {
      final allMethods = await _paymentService.getActivePaymentMethods();
      
      // Filter methods suitable for check-in (exclude certain types if needed)
      return allMethods.where((method) {
        // Include all active methods for now
        return method.isActive;
      }).toList();
    } catch (e) {
      throw Exception('Error retrieving payment methods: $e');
    }
  }

  /// Process deposit payment during check-in
  Future<CheckInPaymentResult> processDepositPayment({
    required String checkInId,
    required String customerId,
    required String customerName,
    required double depositAmount,
    required PaymentMethod paymentMethod,
    String? bookingId,
    String? notes,
  }) async {
    final request = CheckInPaymentRequest(
      checkInId: checkInId,
      bookingId: bookingId,
      customerId: customerId,
      customerName: customerName,
      amount: depositAmount,
      paymentType: CheckInPaymentType.deposit,
      paymentMethod: paymentMethod,
      notes: notes ?? 'Check-in deposit payment',
    );

    return await processCheckInPayment(request);
  }

  /// Process full payment during check-in
  Future<CheckInPaymentResult> processFullPayment({
    required String checkInId,
    required String customerId,
    required String customerName,
    required double totalAmount,
    required PaymentMethod paymentMethod,
    String? bookingId,
    String? notes,
  }) async {
    final request = CheckInPaymentRequest(
      checkInId: checkInId,
      bookingId: bookingId,
      customerId: customerId,
      customerName: customerName,
      amount: totalAmount,
      paymentType: CheckInPaymentType.fullPayment,
      paymentMethod: paymentMethod,
      notes: notes ?? 'Check-in full payment',
    );

    return await processCheckInPayment(request);
  }

  /// Process additional service payments during check-in
  Future<CheckInPaymentResult> processAdditionalPayment({
    required String checkInId,
    required String customerId,
    required String customerName,
    required double additionalAmount,
    required PaymentMethod paymentMethod,
    required String serviceDescription,
    String? bookingId,
  }) async {
    final request = CheckInPaymentRequest(
      checkInId: checkInId,
      bookingId: bookingId,
      customerId: customerId,
      customerName: customerName,
      amount: additionalAmount,
      paymentType: CheckInPaymentType.additional,
      paymentMethod: paymentMethod,
      notes: 'Additional services: $serviceDescription',
    );

    return await processCheckInPayment(request);
  }

  /// Get payment history for a booking
  Future<List<PaymentTransaction>> getBookingPaymentHistory(String bookingId) async {
    try {
      final allTransactions = await _paymentService.getAllTransactions();
      return allTransactions.where((transaction) => 
        transaction.orderId == bookingId ||
        transaction.invoiceId == bookingId
      ).toList();
    } catch (e) {
      throw Exception('Error retrieving payment history: $e');
    }
  }

  /// Validate payment before processing
  Future<List<String>> validatePayment(CheckInPaymentRequest request) async {
    final List<String> errors = [];

    if (request.amount <= 0) {
      errors.add('Payment amount must be greater than zero');
    }

    if (!request.paymentMethod.isActive) {
      errors.add('Selected payment method is not active');
    }

    if (request.paymentMethod.minimumAmount != null && 
        request.amount < request.paymentMethod.minimumAmount!) {
      errors.add('Amount is below minimum for ${request.paymentMethod.name}');
    }

    if (request.paymentMethod.maximumAmount != null && 
        request.amount > request.paymentMethod.maximumAmount!) {
      errors.add('Amount exceeds maximum for ${request.paymentMethod.name}');
    }

    if (request.customerName.trim().isEmpty) {
      errors.add('Customer name is required for payment processing');
    }

    return errors;
  }

  // Helper methods
  TransactionType _mapPaymentTypeToTransactionType(CheckInPaymentType paymentType) {
    switch (paymentType) {
      case CheckInPaymentType.deposit:
        return TransactionType.deposit;
      case CheckInPaymentType.fullPayment:
        return TransactionType.sale;
      case CheckInPaymentType.additional:
        return TransactionType.sale;
      case CheckInPaymentType.refund:
        return TransactionType.refund;
    }
  }

  String _buildPaymentNotes(CheckInPaymentRequest request) {
    final buffer = StringBuffer();
    
    switch (request.paymentType) {
      case CheckInPaymentType.deposit:
        buffer.write('Check-in deposit payment');
        break;
      case CheckInPaymentType.fullPayment:
        buffer.write('Check-in full payment');
        break;
      case CheckInPaymentType.additional:
        buffer.write('Additional services payment');
        break;
      case CheckInPaymentType.refund:
        buffer.write('Check-in refund');
        break;
    }

    if (request.bookingId != null) {
      buffer.write(' - Booking: ${request.bookingId}');
    }

    if (request.notes != null && request.notes!.isNotEmpty) {
      buffer.write(' - ${request.notes}');
    }

    return buffer.toString();
  }
}

/// Summary of check-in payment calculations
class CheckInPaymentSummary {
  final double accommodationAmount;
  final double servicesAmount;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final bool requiresPayment;

  const CheckInPaymentSummary({
    required this.accommodationAmount,
    required this.servicesAmount,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.requiresPayment,
  });

  @override
  String toString() {
    return 'CheckInPaymentSummary(total: $totalAmount, paid: $paidAmount, remaining: $remainingAmount)';
  }
}